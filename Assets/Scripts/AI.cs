using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Debug = UnityEngine.Debug;
using Random = UnityEngine.Random;
using Object = UnityEngine.Object;
using NaughtyAttributes;

public enum Difficulty{Easy, Normal, Hard, HighWizard, Lich};
public enum GamePlan{Bust, MaxDamage};
public struct CardRating
{
    public Card card;
    public int rating;
    public int ratingTargetDiff;
    public bool clearsTarget;
    public CardRating(Card card, int rating, int ratingTargetDiff, bool clearsTarget = false)
    {
        this.card = card;
        this.rating = rating;
        this.ratingTargetDiff = ratingTargetDiff;
        this.clearsTarget = clearsTarget;
    }
}
public class AI : Agent
{
    [Header("AI")]
    [SerializeField] protected float waitToChooseBehavior = 1f;
    [SerializeField] protected float waitAfterActivatingPower = 1f;
    [SerializeField] float cardInitialDistFromCam = 1.4f;
    [SerializeField] float cardInitialXOffsetFromMiddle = .5f;
    [SerializeField] float cardToFrontOfCamDelay = .7f;
    [SerializeField] float endTurnDelay = .3f;
    CardSlot[] CardSlots;
    CardSlot PrimalSlot;
    CardSlot DivineSlot;
    CardSlot ArcaneSlot;
    
    [SerializeField] const int defaultTargetRating = 6;
    [SerializeField] float delayBetweenActivateAndUsePower = .5f;
    [SerializeField] Difficulty difficulty;
    GamePlan currentGamePlan;
    [SerializeField] float[] ChanceToChooseCorrectSource = new float[Enum.GetValues(typeof(Difficulty)).Length];
    [SerializeField] float[] ChanceToPlayOptimally = new float[Enum.GetValues(typeof(Difficulty)).Length];
    
    public override void Start()
    {
        base.Start();
        foreach(Transform child in gameManager.AllCardSlots.transform)
        {
            CardSlot slot = child.GetComponent<CardSlot>();
            if(slot.isPlayerSlot)
            {
                continue;
            }
            switch(slot.source)
            {
                case MagicSource.Primal:
                    PrimalSlot = slot;
                    break;
                case MagicSource.Divine:
                    DivineSlot = slot;
                    break;
                case MagicSource.Arcane:
                    ArcaneSlot = slot;
                    break;
            }
        }
        CardSlots = new CardSlot[] {PrimalSlot, DivineSlot, ArcaneSlot};
    }

    protected override void Update()
    {
        base.Update();
    }

    public override void StartTurn()
    {
        base.StartTurn();
        StartCoroutine(ChooseBehavior(ChooseCardSlot()));
    }
    CardSlot ChooseCardSlot()
    {
        List<CardSlot> slotsToPlay = new List<CardSlot>(CardSlots);
        int randomRange = 1000;
        int chanceToChooseCorrectSlot = Random.Range(0, randomRange);
        CardSlot correctSlot = null;
        foreach(CardSlot slot in CardSlots)
        {
            if(slot.source == gameManager.SupremeSource)
            {
                correctSlot = slot;
                break;
            }
        }
        if(chanceToChooseCorrectSlot < randomRange * ChanceToChooseCorrectSource[(int)difficulty])
        {
            return correctSlot;
        } else
        {
            slotsToPlay.Remove(correctSlot);
            int randomSlot = Random.Range(0, slotsToPlay.Count);
            return slotsToPlay[randomSlot];
        }
    }
    IEnumerator ChooseBehavior(CardSlot slot)
    {
        int[] cardRatings = RateAllCards();
        // Choose Game Plan based on current mana and card ratings
        float agentRating = mana - (player.maxMana - player.mana);
        for(int i = 0; i < cardRatings.Length; i++)
        {
            agentRating += cardRatings[i];
        }        
        float gamePlanRatingThresh = defaultTargetRating * Hand.transform.childCount + 5;
        if(agentRating > gamePlanRatingThresh && gameManager.maxDuels - gameManager.currentDuelNum < player.mana)
        {
            currentGamePlan = GamePlan.MaxDamage;
        } else
        {
            currentGamePlan = GamePlan.Bust;
        }
        
        yield return new WaitForSeconds(waitToChooseBehavior);
        int randomRange = 1000;
        
        yield return ActivatePowers(cardRatings, randomRange);
        cardRatings = RateAllCards();
        int targetRating = gameManager.turn == 1 ? RateCard(player.cardBeingPlayed, player) : defaultTargetRating;
        Card optimalCard = ChooseOptimalCard(cardRatings, currentGamePlan, targetRating);
        float[] cardPickProbabilities = new float[cardRatings.Length];
        float unoptimalProbSum = 1 - ChanceToPlayOptimally[(int)difficulty];
        float rankDiffSum = 0;
        for(int i = 0; i < cardRatings.Length; i++)
        {
            if(HandOfCards[i] == optimalCard)
            {
                continue;
            }
            rankDiffSum += Mathf.Abs(cardRatings[i] - RateCard(optimalCard, this));
        }
        for(int i = 0; i < cardRatings.Length; i++)
        {
            if(HandOfCards[i] == optimalCard)
            {
                cardPickProbabilities[i] = ChanceToPlayOptimally[(int)difficulty];
                continue;
            }
            cardPickProbabilities[i] = Mathf.Abs(cardRatings[i] - RateCard(optimalCard, this)) / rankDiffSum * unoptimalProbSum;
        } 
        int rngCard = Random.Range(0, randomRange);
        float probSum = 0;
        Card ChosenCard = optimalCard;
        for(int i = 0; i < cardRatings.Length; i++)
        {
            probSum += cardPickProbabilities[i];
            if(rngCard < randomRange * probSum)
            {
                ChosenCard = HandOfCards[i];
                break;
            }
        }

        UseCard(ChosenCard, slot, fn: () =>
        {
            cam.GetComponent<Animator>().SetBool("GoToEnemy", false);
            cam.GetComponent<Animator>().SetBool("LookAtEnemyPlaceCard", false);
        });
    }
    IEnumerator ActivatePowers(int[] cardRatings, int randomRange)
    {
        yield return ActivateInitiative(cardRatings, randomRange);
        
        yield return ActivateRedraw(cardRatings, randomRange);
        cardRatings = RateAllCards();
        
        yield return ActivateMimicry(cardRatings, randomRange);
        
        yield return ActivateSupremeSwap(cardRatings, randomRange);
        cardRatings = RateAllCards();
        
        yield return ActivateDominate(cardRatings, randomRange);
        cardRatings = RateAllCards();
        
        yield return ActivateAdrenaline(cardRatings, randomRange);
        cardRatings = RateAllCards();
        
        yield return ActivateEnvigorate(cardRatings, randomRange);
    }
    IEnumerator ActivateInitiative(int[] cardRatings, int randomRange)
    {
        Power initiative = PowersTransform.Find("Initiative").GetComponent<Power>();
        if(initiative.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];
            if(gameManager.turn == 1)
            {   
                bool willWin = RateCard(ChooseOptimalCard(cardRatings, currentGamePlan, RateCard(player.cardBeingPlayed, player)),this) > RateCard(player.cardBeingPlayed, player);
                if(willWin) chanceToActivate = ChanceToPlayOptimally[(int)difficulty];
            }
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                initiative.OnSelect();
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    IEnumerator ActivateRedraw(int[] cardRatings, int randomRange)
    {
        Power redraw = PowersTransform.Find("Redraw").GetComponent<Power>();
        if(redraw.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];

            GamePlan oppositeGamePlan = currentGamePlan == GamePlan.Bust ? GamePlan.MaxDamage : GamePlan.Bust;
            const float conditionalChanceToActivate1 = .65f;
            
            if(GetCardRatingInfo(ChooseOptimalCard(cardRatings, oppositeGamePlan, goHighOnNoOptimalBustCard: false), oppositeGamePlan).clearsTarget)
            {
                chanceToActivate = ChanceToPlayOptimally[(int)difficulty] * conditionalChanceToActivate1;
            }
            if(gameManager.turn == 1)
            {
                const float conditionalChanceToActivate2 = .9f;
                bool clearsTarget = GetCardRatingInfo(ChooseOptimalCard(cardRatings, currentGamePlan, RateCard(player.cardBeingPlayed, player), false), currentGamePlan, RateCard(player.cardBeingPlayed, player)).clearsTarget;
                if(clearsTarget) 
                {
                    chanceToActivate = ChanceToPlayOptimally[(int)difficulty] * conditionalChanceToActivate2;
                }
            }
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                redraw.OnSelect();
                yield return new WaitForSeconds(delayBetweenActivateAndUsePower);
                yield return new WaitUntil(() => redraw.GetComponent<Redraw>().drawedCardInPlace);
                Card cardToRedraw = ChooseOptimalCard(cardRatings, oppositeGamePlan, goHighOnNoOptimalBustCard: false, goLowestOnBust: true);
                List<Card> HandOfCardsWithDrawnCard = new List<Card>(HandOfCards);
                if(cardToRedraw != ChooseOptimalCard(RateAllCards(HandOfCardsWithDrawnCard), oppositeGamePlan, goHighOnNoOptimalBustCard: false, goLowestOnBust: true, allCards: HandOfCardsWithDrawnCard.ToArray()))
                {
                    StartCoroutine(redraw.GetComponent<Redraw>().DumpCard());
                }
                yield return redraw.GetComponent<Redraw>().RedrawCard(cardToRedraw, this);
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    IEnumerator ActivateMimicry(int[] cardRatings, int randomRange)
    {
        Power mimicry = PowersTransform.Find("Mimicry").GetComponent<Power>();
        if(mimicry.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];
            if(gameManager.turn == 0)
            {
                int illusionCount = 0;
                int evocationCount = 0;
                int abjurationCount = 0;
                foreach(Card card in WonCards)
                {
                    switch(card.type)
                    {
                        case MagicType.Illusion:
                            illusionCount++;
                            break;
                        case MagicType.Evocation:
                            evocationCount++;
                            break;
                        case MagicType.Abjuration:
                            abjurationCount++;
                            break;
                    }
                }
                foreach(Card card in player.WonCards)
                {
                    switch(card.type)
                    {
                        case MagicType.Illusion:
                            illusionCount++;
                            break;
                        case MagicType.Evocation:
                            evocationCount++;
                            break;
                        case MagicType.Abjuration:
                            abjurationCount++;
                            break;
                    }
                }
                bool illusionInHand = false;
                bool evocationInHand = false;
                bool abjurationInHand = false;
                foreach(Card card in HandOfCards)
                {
                    switch(card.type)
                    {
                        case MagicType.Illusion:
                            illusionCount++;
                            illusionInHand = true;
                            break;
                        case MagicType.Evocation:
                            evocationCount++;
                            evocationInHand = true;
                            break;
                        case MagicType.Abjuration:
                            abjurationCount++;
                            abjurationInHand = true;
                            break;
                    }
                }
                int maxCount;
                MagicType maxType;
                if((illusionCount >= evocationCount || !evocationInHand) && (illusionCount >= abjurationCount || !abjurationInHand) && illusionInHand)
                {
                    maxCount = illusionCount;
                    maxType = MagicType.Illusion;
                } else if((evocationCount >= illusionCount || !illusionInHand) && (evocationCount >= abjurationCount || !abjurationInHand) && evocationInHand)
                {
                    maxCount = evocationCount;
                    maxType = MagicType.Evocation;
                } else
                {
                    maxCount = abjurationCount;
                    maxType = MagicType.Abjuration;
                }
                chanceToActivate = (float)maxCount/(float)GameManager.maxCardDenomination * ChanceToPlayOptimally[(int)difficulty];
            } else { chanceToActivate = 0; }
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                mimicry.OnSelect();
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    IEnumerator ActivateEnvigorate(int[] cardRatings, int randomRange)
    {
        Power envigorate = PowersTransform.Find("Envigorate").GetComponent<Power>();
        if(envigorate.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];
            if(gameManager.turn == 1)
            {
                CardRating optimalCardRating = GetCardRatingInfo(ChooseOptimalCard(cardRatings, currentGamePlan, RateCard(player.cardBeingPlayed, player), false), currentGamePlan, RateCard(player.cardBeingPlayed, player));
                if(optimalCardRating.ratingTargetDiff > 0)
                {
                    float manaRatio = 1-((float)mana/(float)maxMana);
                    chanceToActivate = ChanceToPlayOptimally[(int)difficulty] * manaRatio;
                }
            }
            if(adrenalineActive)
            {
                chanceToActivate = ChanceToPlayOptimally[(int)difficulty];
            }
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                envigorate.OnSelect();
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    IEnumerator ActivateSupremeSwap(int[] cardRatings, int randomRange)
    {
        Power supremeSwap = PowersTransform.Find("SupremeSwap").GetComponent<Power>();
        if(supremeSwap.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];
            
            int illusionCount = 0;
            int evocationCount = 0;
            int abjurationCount = 0;
            foreach(Card card in HandOfCards)
            {
                switch(card.type)
                {
                    case MagicType.Illusion:
                        illusionCount++;
                        break;
                    case MagicType.Evocation:
                        evocationCount++;
                        break;
                    case MagicType.Abjuration:
                        abjurationCount++;
                        break;
                }
            }
            int maxCount;
            MagicType maxCountType;
            if((illusionCount >= evocationCount && illusionCount >= abjurationCount && currentGamePlan == GamePlan.MaxDamage) || (illusionCount <= evocationCount && illusionCount <= abjurationCount && currentGamePlan == GamePlan.Bust))
            {
                maxCount = illusionCount;
                maxCountType = MagicType.Illusion;
            } else if((evocationCount >= illusionCount && evocationCount >= abjurationCount && currentGamePlan == GamePlan.MaxDamage) || (evocationCount <= illusionCount && evocationCount <= abjurationCount && currentGamePlan == GamePlan.Bust))
            {
                maxCount = evocationCount;
                maxCountType = MagicType.Evocation;
            } else
            {
                maxCount = abjurationCount;
                maxCountType = MagicType.Abjuration;
            }
            int supremeCount = 0;
            switch(gameManager.SupremeCard.type)
            {
                case MagicType.Illusion:
                    supremeCount = illusionCount;
                    break;
                case MagicType.Evocation:
                    supremeCount = evocationCount;
                    break;
                case MagicType.Abjuration:
                    supremeCount = abjurationCount;
                    break;
            }
            if(maxCountType != gameManager.SupremeCard.type && maxCount > 2)
            {
                if(currentGamePlan == GamePlan.MaxDamage)
                {
                    chanceToActivate = Mathf.Clamp(1-(float)supremeCount/(float)maxCount, 0f, 1f) * ChanceToPlayOptimally[(int)difficulty];
                } else
                {
                    chanceToActivate = Mathf.Clamp(1-(float)maxCount/(float)supremeCount, 0f, 1f) * ChanceToPlayOptimally[(int)difficulty];
                }
            } 
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                supremeSwap.OnSelect();
                yield return new WaitForSeconds(delayBetweenActivateAndUsePower);
                List<Card> cardsOfType = HandOfCards.Where(card => card.type == maxCountType).ToList();
                int[] cardRatingsOfType = RateAllCards(cardsOfType);
                GamePlan oppositeGamePlan = currentGamePlan == GamePlan.Bust ? GamePlan.MaxDamage : GamePlan.Bust;
                Card cardToSwap;
                if(cardsOfType.Count > 0)
                {
                    cardToSwap = ChooseOptimalCard(cardRatingsOfType, oppositeGamePlan, goHighOnNoOptimalBustCard: false, goLowestOnBust: true, allCards: cardsOfType.ToArray());
                } else {
                    cardToSwap = ChooseOptimalCard(cardRatings, oppositeGamePlan, goHighOnNoOptimalBustCard: false, goLowestOnBust: true);
                }
                
                yield return supremeSwap.GetComponent<SupremeSwap>().SupremeSwapCard(cardToSwap, this, cardToSwap.transform.position, cardToSwap.moveRotPivot.transform.rotation);
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    IEnumerator ActivateDominate(int[] cardRatings, int randomRange)
    {
        Power dominate = PowersTransform.Find("Dominate").GetComponent<Power>();
        if(dominate.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];
            int[] cardRatingsDominate = new int[cardRatings.Length];
            for(int i = 0; i < cardRatings.Length; i++)
            {
                cardRatingsDominate[i] = cardRatings[i];
                if(HandOfCards[i].type != gameManager.SupremeCard.type)
                {
                    cardRatingsDominate[i] += gameManager.supremeCardDenominationBonus;
                }
            }
            if(currentGamePlan == GamePlan.MaxDamage)
            {
                const float conditionalChanceToActivate1 = .5f;
                chanceToActivate = conditionalChanceToActivate1 * ChanceToPlayOptimally[(int)difficulty];
                if(gameManager.turn == 1)
                {
                    const float conditionalChanceToActivate2 = .95f;
                    bool clearsTargetDefault = GetCardRatingInfo(ChooseOptimalCard(cardRatings, currentGamePlan, RateCard(player.cardBeingPlayed, player), false), currentGamePlan, RateCard(player.cardBeingPlayed, player)).clearsTarget;
                    bool clearsTargetDominate = GetCardRatingInfo(ChooseOptimalCard(cardRatingsDominate, currentGamePlan, RateCard(player.cardBeingPlayed, player), false), currentGamePlan, RateCard(player.cardBeingPlayed, player)).clearsTarget;
                    if(clearsTargetDominate && !clearsTargetDefault) 
                    {
                        chanceToActivate = conditionalChanceToActivate2 * ChanceToPlayOptimally[(int)difficulty];
                    }
                }
            }
            
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                dominate.OnSelect();
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    IEnumerator ActivateAdrenaline(int[] cardRatings, int randomRange)
    {
        Power adrenaline = PowersTransform.Find("Adrenaline").GetComponent<Power>();
        if(adrenaline.amount > 0)
        {
            float chanceToActivate = 1-ChanceToPlayOptimally[(int)difficulty];
            int targetRating = gameManager.turn == 1 ? RateCard(player.cardBeingPlayed, player) : defaultTargetRating;
            CardRating optimalCardRatingInfo = GetCardRatingInfo(ChooseOptimalCard(cardRatings, currentGamePlan, targetRating, false), currentGamePlan, targetRating);
            if((currentGamePlan == GamePlan.Bust && optimalCardRatingInfo.ratingTargetDiff > 0) || currentGamePlan == GamePlan.MaxDamage)
            {
                float manaRatio = ((float)mana-2) / (float)maxMana;
                float denominationRatio = (float)optimalCardRatingInfo.card.denomination / (float)GameManager.maxCardDenomination;
                float ratingTargetRatioDiff = Mathf.Clamp((float)optimalCardRatingInfo.ratingTargetDiff / 3f, 0f, 2.5f);
                chanceToActivate = manaRatio * denominationRatio * ratingTargetRatioDiff * ChanceToPlayOptimally[(int)difficulty];
                Debug.Log($"Adrenaline chance to activate: {chanceToActivate}, ratingTargetRatioDiff: {ratingTargetRatioDiff}, OptimalCard: {optimalCardRatingInfo.card}");
            }
            
            int rng = Random.Range(0, randomRange);
            if(rng < randomRange * chanceToActivate)
            {
                adrenaline.OnSelect();
                yield return new WaitForSeconds(waitAfterActivatingPower);
            }
        }
    }
    CardRating GetCardRatingInfo(Card card, GamePlan gamePlan, int targetRating = defaultTargetRating)
    {
        int cardRating = RateCard(card, this);
        int diff = cardRating - targetRating;
        CardRating cardRatingInfo = new CardRating(card, cardRating, diff);
        if(cardRatingInfo.ratingTargetDiff < 0 && gamePlan == GamePlan.MaxDamage || cardRatingInfo.ratingTargetDiff > 0 && gamePlan == GamePlan.Bust)
        {
            cardRatingInfo.clearsTarget = false;
        } else if(cardRatingInfo.ratingTargetDiff > 0 && gamePlan == GamePlan.MaxDamage || cardRatingInfo.ratingTargetDiff < 0 && gamePlan == GamePlan.Bust)
        {
            cardRatingInfo.clearsTarget = true;
        } else
        {
            bool winsRoShamBo = true;
            if(gameManager.turn == 1)
            {
                winsRoShamBo = gameManager.RoShamBoWinner(card.type, player.cardBeingPlayed.type) == 1;
            }
            if(winsRoShamBo && gamePlan == GamePlan.MaxDamage || !winsRoShamBo && gamePlan == GamePlan.Bust)
            {
                cardRatingInfo.clearsTarget = true;
            } else
            {
                cardRatingInfo.clearsTarget = false;
            }
        }
        return cardRatingInfo;
    }
    Card ChooseOptimalCard(int[] cardRatings, GamePlan gamePlan, int targetRating = defaultTargetRating, bool goHighOnNoOptimalBustCard = true, bool goLowestOnBust = false, Card[] allCards = null)
    {
        allCards = allCards == null ? HandOfCards.ToArray() : allCards;
        int minmax = gamePlan == GamePlan.MaxDamage || goLowestOnBust ? -1 : int.MaxValue;
        Card optimalCard = null;
        for(int i = 0; i < cardRatings.Length; i++)
        {
            int currentCardRating = cardRatings[i];
            if(gameManager.turn == 1 && currentCardRating == targetRating)
            {
                if(gameManager.RoShamBoWinner(allCards[i].type, player.cardBeingPlayed.type) == 1)
                {
                    currentCardRating += gameManager.cardClashTieWinnerBonus;
                } else
                {
                    currentCardRating -= gameManager.cardClashTieWinnerBonus;
                }
            }
            if(gamePlan == GamePlan.Bust)
            {
                if(goLowestOnBust)
                {
                    if(currentCardRating <= targetRating && currentCardRating < minmax)
                    {
                        minmax = currentCardRating;
                        optimalCard = allCards[i];
                    } 
                } else
                {
                    if(currentCardRating <= targetRating && currentCardRating > minmax)
                    {
                        minmax = currentCardRating;
                        optimalCard = allCards[i];
                    } 
                }
            }
            if(gamePlan == GamePlan.MaxDamage)
            {
                if(currentCardRating >= targetRating && currentCardRating > minmax)
                {
                    minmax = currentCardRating;
                    optimalCard = allCards[i];
                }
            }
        }
        // if no card rating is above/below the target rating, for both bust and max damage, then just choose the highest card rating
        if(optimalCard == null && (goHighOnNoOptimalBustCard || gamePlan == GamePlan.MaxDamage))
        {
            minmax = -1;
            for(int i = 0; i < cardRatings.Length; i++)
            {
                if(cardRatings[i] > minmax)
                {
                    minmax = cardRatings[i];
                    optimalCard = allCards[i];
                }
            }
        }

        if(!goHighOnNoOptimalBustCard && gamePlan == GamePlan.Bust && optimalCard == null)
        {
            minmax = int.MaxValue;
            for(int i = 0; i < cardRatings.Length; i++)
            {
                if(cardRatings[i] < minmax)
                {
                    minmax = cardRatings[i];
                    optimalCard = allCards[i];
                }
            }
        }
        return optimalCard;
    }
    int[] RateAllCards(List<Card> cards = null)
    {
        if(cards == null)
            cards = HandOfCards;

        int[] cardRatings = new int[cards.Count];
        for(int i = 0; i < cards.Count; i++)
        {
            cardRatings[i] = RateCard(cards[i], this);
        }
        return cardRatings;
    }
    int RateCard(Card card, Agent agent)
    {
        int rating = card.denomination;
        if(card.type == gameManager.SupremeCard.type || agent.dominateActive)
        {
            rating += gameManager.supremeCardDenominationBonus;
        }
        if(agent.adrenalineActive)
        {
            rating *= 2;
        }
        Agent otherAgent = agent == AIEnemy ? player : AIEnemy;
        if(gameManager.mimicryActive && gameManager.turn == 1 && gameManager.currentPlayer == agent)
        {
            if(card.type != otherAgent.cardBeingPlayed.type)
            {
                rating = 0;
            }
        }
        return rating;
    }
    public override void UseCard(Card card, CardSlot slot, Action fn = null)
    {
        base.UseCard(card, slot, fn);
        StartCoroutine(MoveCardToFrontAndEndTurn(card));
    }
    IEnumerator MoveCardToFrontAndEndTurn(Card card)
    {
        yield return new WaitUntil(() => cardOnSlot);
        yield return new WaitForSeconds(cardToFrontOfCamDelay);
        card.transform.Find($"{card.frontPath}/EnemyHighlightBg").gameObject.SetActive(true);
        bool movedToPosition = false;
        Vector3 camPos = cam.transform.position + cam.transform.forward * cardInitialDistFromCam + cam.transform.right * cardInitialXOffsetFromMiddle;
        card.StartMoving(camPos, cam.transform.rotation, fn: () =>
        {
            movedToPosition = true;
        });
        yield return new WaitUntil(() => movedToPosition);
        yield return new WaitForSeconds(endTurnDelay);
        EndTurn();
    }
    public override IEnumerator AddArcana(Action finishedFn = null)
    {
        yield return base.AddArcana(finishedFn);

        if(cardMatchesSupremeSource)
        {
            int rng = Random.Range(0, PowersTransform.childCount);
            Power power = PowersTransform.GetChild(rng).GetComponent<Power>();
            power.AddPower();
        }
        finishedFn?.Invoke();
    }
}