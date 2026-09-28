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
    public int damage;
    public int extraDamage;
    public bool clearsTarget;
    public CardRating(Card card, int rating, int ratingTargetDiff, int damage, int extraDamage, bool clearsTarget = false)
    {
        this.card = card;
        this.rating = rating;
        this.ratingTargetDiff = ratingTargetDiff;
        this.damage = damage;
        this.extraDamage = extraDamage;
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
    [SerializeField] int gamePlanRatingThresholdAdder = 6;
    [SerializeField] float delayBetweenActivateAndUsePower = .5f;
    [SerializeField] Difficulty difficulty;
    GamePlan currentGamePlan;
    [SerializeField] float[] ChanceToChooseCorrectSource = new float[Enum.GetValues(typeof(Difficulty)).Length];
    [SerializeField] float[] ChanceToPlayOptimally = new float[Enum.GetValues(typeof(Difficulty)).Length];
    Card CardToPlay;
    Card MimicryCardToPlay;
    MagicType SupremeSwapTypeToSwap;
    bool powerActivatedThisDuel = false;
    
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
        float agentRating = -(player.maxMana - player.mana);
        for(int i = 0; i < cardRatings.Length; i++)
        {
            agentRating += cardRatings[i];
        }        
        float gamePlanRatingThresh = defaultTargetRating * Hand.transform.childCount + gamePlanRatingThresholdAdder;
        if(agentRating > gamePlanRatingThresh && gameManager.maxDuels - gameManager.currentDuelNum > player.mana)
        {
            currentGamePlan = GamePlan.MaxDamage;
        } else
        {
            currentGamePlan = GamePlan.Bust;
        }
        
        yield return new WaitForSeconds(waitToChooseBehavior);
        int randomRange = 1000;
        float[] cardPickRatings = GetCardDuelPickRating(currentGamePlan, player.cardBeingPlayed);
        Card optimalCard = HandOfCards[Array.IndexOf(cardPickRatings, cardPickRatings.Max())];
        float[] cardPickProbabilities = new float[cardPickRatings.Length];
        float unoptimalProbSum = 1 - ChanceToPlayOptimally[(int)difficulty];
        float rankDiffSum = 0;
        for(int i = 0; i < cardPickRatings.Length; i++)
        {
            if(HandOfCards[i] == optimalCard)
            {
                continue;
            }
            rankDiffSum += Mathf.Abs(cardPickRatings[i] - cardPickRatings.Max());
        }
        for(int i = 0; i < cardPickRatings.Length; i++)
        {
            if(HandOfCards[i] == optimalCard)
            {
                cardPickProbabilities[i] = ChanceToPlayOptimally[(int)difficulty];
                continue;
            }
            cardPickProbabilities[i] = Mathf.Abs(cardPickRatings[i] - cardPickRatings.Max()) / rankDiffSum * unoptimalProbSum;
        } 
        int rngCard = Random.Range(0, randomRange);
        float probSum = 0;
        Card ChosenCard = optimalCard;
        for(int i = 0; i < cardPickRatings.Length; i++)
        {
            probSum += cardPickProbabilities[i];
            if(rngCard < randomRange * probSum)
            {
                ChosenCard = HandOfCards[i];
                break;
            }
        }
        CardToPlay = ChosenCard;

        yield return ActivatePowers(randomRange);

        UseCard(CardToPlay, slot, fn: () =>
        {
            cam.GetComponent<Animator>().SetBool("GoToEnemy", false);
            cam.GetComponent<Animator>().SetBool("LookAtEnemyPlaceCard", false);
        });
    }
    IEnumerator ActivatePowers(int randomRange)
    {
        Power initiative = PowersTransform.Find("Initiative").GetComponent<Power>();
        Power redraw = PowersTransform.Find("Redraw").GetComponent<Power>();
        Power mimicry = PowersTransform.Find("Mimicry").GetComponent<Power>();
        Power envigorate = PowersTransform.Find("Envigorate").GetComponent<Power>();
        Power supremeSwap = PowersTransform.Find("SupremeSwap").GetComponent<Power>();
        Power dominate = PowersTransform.Find("Dominate").GetComponent<Power>();
        Power adrenaline = PowersTransform.Find("Adrenaline").GetComponent<Power>();
        float[] probToActivateEachPower = new float[]
        {
            GetProbToActivateInitiative(initiative), GetProbToActivateRedraw(redraw), GetProbToActivateMimicry(mimicry),
            GetProbToActivateEnvigorate(envigorate), GetProbToActivateSupremeSwap(supremeSwap), GetProbToActivateDominate(dominate),
            GetProbToActivateAdrenaline(adrenaline)
        };
        float maxProb = probToActivateEachPower.Max();
        float unoptimalProbSum = 1 - ChanceToPlayOptimally[(int)difficulty];
        float[] powerPickProbabilities = new float[probToActivateEachPower.Length];
        float rankDiffSum = 0;
        for(int i = 0; i < probToActivateEachPower.Length; i++)
        {
            if(probToActivateEachPower[i] == maxProb)
            {
                continue;
            }
            rankDiffSum += Mathf.Abs(probToActivateEachPower[i] - maxProb);
        }
        for(int i = 0; i < probToActivateEachPower.Length; i++)
        {
            if(probToActivateEachPower[i] == maxProb)
            {
                powerPickProbabilities[i] = ChanceToPlayOptimally[(int)difficulty];
                continue;
            }
            powerPickProbabilities[i] = Mathf.Abs(powerPickProbabilities[i] - maxProb) / rankDiffSum * unoptimalProbSum;
        } 
        int rngCard = Random.Range(0, randomRange);
        float probSum = 0;
        for(int i = 0; i < probToActivateEachPower.Length; i++)
        {
            probSum += powerPickProbabilities[i];
            if(rngCard < randomRange * probSum && probToActivateEachPower[i] != 0)
            {
                switch(i)
                {
                    case 0:
                        yield return ActivateInitiative(initiative);
                        break;
                    case 1:
                        yield return ActivateRedraw(redraw);
                        break;
                    case 2:
                        yield return ActivateMimicry(mimicry);
                        break;
                    case 3:
                        yield return ActivateEnvigorate(envigorate);
                        break;
                    case 4:
                        yield return ActivateSupremeSwap(supremeSwap);
                        break;
                    case 5:
                        yield return ActivateDominate(dominate);
                        break;
                    case 6:
                        yield return ActivateAdrenaline(adrenaline);
                        break;
                }
                break;
            }
        }
    }
    float GetProbToActivateInitiative(Power power)
    {
        if(arcana >= power.cost || power.amount > 0)
        {
            const float initiativeProbScalar = .5f;

            float prob = initiativeProbScalar * ChanceToPlayOptimally[(int)difficulty] * gameManager.currentDuelNum / gameManager.maxDuels;
            if(gameManager.turn == 1)
            {
                prob /= initiativeProbScalar;
            }
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateInitiative(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        power.OnSelect();
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    float GetProbToActivateRedraw(Power power)
    {
        if(arcana >= power.cost || power.amount > 0)
        {
            const float redrawScalar = .7f;

            int[] cardRatingsForRound = RateAllCards(null, true);
            int numOfBadCards = 0;
            for(int i = 0; i < cardRatingsForRound.Length; i++)
            {
                if((cardRatingsForRound[i] < defaultTargetRating && currentGamePlan == GamePlan.MaxDamage) || (cardRatingsForRound[i] > defaultTargetRating && currentGamePlan == GamePlan.Bust))
                {
                    numOfBadCards++;
                }
            }
            float prob = (float)numOfBadCards / (float)cardRatingsForRound.Length * redrawScalar * ChanceToPlayOptimally[(int)difficulty];
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateRedraw(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        power.OnSelect();
        yield return new WaitUntil(() => power.GetComponent<Redraw>().drawedCardInPlace);
        yield return new WaitForSeconds(delayBetweenActivateAndUsePower);
        
        GamePlan oppositeGamePlan = currentGamePlan == GamePlan.MaxDamage ? GamePlan.Bust : GamePlan.MaxDamage;
        float[] cardPickRatings = GetCardDuelPickRating(currentGamePlan, player.cardBeingPlayed);
        Card cardToRedraw = HandOfCards[Array.IndexOf(cardPickRatings, cardPickRatings.Min())];
        List<Card> HandOfCardsWithDrawnCard = new List<Card>(HandOfCards);
        HandOfCardsWithDrawnCard.Remove(cardToRedraw);
        HandOfCardsWithDrawnCard.Add(power.GetComponent<Redraw>().drawedCard);
        float[] cardPickRatingsAfterRedraw = GetCardDuelPickRating(currentGamePlan, player.cardBeingPlayed, HandOfCardsWithDrawnCard.ToArray());
        Card unoptimalCardAfterRedraw = HandOfCards[Array.IndexOf(cardPickRatings, cardPickRatings.Min())];
        if(cardToRedraw != unoptimalCardAfterRedraw)
        {
            yield return power.GetComponent<Redraw>().DumpCard();
        } else
        {
            yield return power.GetComponent<Redraw>().RedrawCard(cardToRedraw, this);
        }
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    float GetProbToActivateMimicry(Power power)
    {
        if((arcana >= power.cost || power.amount > 0) && gameManager.turn == 0 && currentGamePlan == GamePlan.MaxDamage)
        {
            CountedCards countedCards = CountedCards.GetCountedCards(this);
            int chosenTypeHighestDenomination = -1;
            MagicType chosenType = MagicType.Illusion;
            foreach(Card card in HandOfCards)
            {
                if(card.type == countedCards.min && card.denomination > chosenTypeHighestDenomination)
                {
                    chosenTypeHighestDenomination = card.denomination;
                    chosenType = countedCards.min;
                    MimicryCardToPlay = card;
                } 
            }
            if(chosenTypeHighestDenomination == -1)
            {
                foreach(Card card in HandOfCards)
                {
                    if(card.type == countedCards.mid && card.denomination > chosenTypeHighestDenomination)
                    {
                        chosenTypeHighestDenomination = card.denomination;
                        chosenType = countedCards.mid;
                        MimicryCardToPlay = card;
                    } 
                }
            }
            if(chosenTypeHighestDenomination == -1)
            {
                foreach(Card card in HandOfCards)
                {
                    if(card.type == countedCards.max && card.denomination > chosenTypeHighestDenomination)
                    {
                        chosenTypeHighestDenomination = card.denomination;
                        chosenType = countedCards.max;
                        MimicryCardToPlay = card;
                    } 
                }
            }
            float prob = (1-(float)countedCards.GetCountFromMagicType(chosenType) / (float)GameManager.maxCardDenomination) * (float)chosenTypeHighestDenomination / (float)GameManager.maxCardDenomination * ChanceToPlayOptimally[(int)difficulty];
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateMimicry(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        CardToPlay = MimicryCardToPlay;
        power.OnSelect();
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    float GetProbToActivateEnvigorate(Power power)
    {
        if(arcana >= power.cost || power.amount > 0)
        {
            float envigorateTurn0Scalar = .5f;

            float prob = (1 - (float)mana / (float)maxMana) * envigorateTurn0Scalar * ChanceToPlayOptimally[(int)difficulty];
            if(gameManager.turn == 1)
            {
                if(GetCardRatingInfo(CardToPlay, currentGamePlan).clearsTarget)
                {
                    prob = (1 - (float)mana / (float)maxMana) * ChanceToPlayOptimally[(int)difficulty];
                }
            }
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateEnvigorate(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        power.OnSelect();
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    float GetProbToActivateSupremeSwap(Power power)
    {
        if(arcana >= power.cost || power.amount > 0)
        {
            int numOfCurrentSupremeTypeCards = 0;
            int numOfIllusionCards = 0;
            int numOfEvocationCards = 0;
            int numOfAbjurationCards = 0;

            foreach(Card card in HandOfCards)
            {
                if(card.type == MagicType.Illusion)
                {
                    numOfIllusionCards++;
                    if(gameManager.SupremeCard.type == card.type) numOfCurrentSupremeTypeCards++;
                }
                if(card.type == MagicType.Evocation)
                {
                    numOfEvocationCards++;
                    if(gameManager.SupremeCard.type == card.type) numOfCurrentSupremeTypeCards++;
                }
                if(card.type == MagicType.Abjuration)
                {
                    numOfAbjurationCards++;
                    if(gameManager.SupremeCard.type == card.type) numOfCurrentSupremeTypeCards++;
                }
            }
            int maxNumOfCardsPerType = -1;
            if(numOfIllusionCards >= numOfEvocationCards && numOfIllusionCards >= numOfAbjurationCards)
            {
                maxNumOfCardsPerType = numOfIllusionCards;
                SupremeSwapTypeToSwap = MagicType.Illusion;
            }
            if(numOfEvocationCards >= numOfIllusionCards && numOfEvocationCards >= numOfAbjurationCards)
            {
                maxNumOfCardsPerType = numOfEvocationCards;
                SupremeSwapTypeToSwap = MagicType.Evocation;
            }
            if(numOfAbjurationCards >= numOfEvocationCards && numOfAbjurationCards >= numOfIllusionCards)
            {
                maxNumOfCardsPerType = numOfAbjurationCards;
                SupremeSwapTypeToSwap = MagicType.Abjuration;
            }
            float prob;
            if(maxNumOfCardsPerType-1 + numOfCurrentSupremeTypeCards == 0)
            {
                prob = 0;
            } else
            {
                prob = (maxNumOfCardsPerType-1) / (maxNumOfCardsPerType-1 + numOfCurrentSupremeTypeCards) * ChanceToPlayOptimally[(int)difficulty];
            }
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateSupremeSwap(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        power.OnSelect();
        yield return new WaitForSeconds(delayBetweenActivateAndUsePower);
        List<Card> cardsOfType = HandOfCards.Where(card => card.type == SupremeSwapTypeToSwap).ToList();
        GamePlan oppositeGamePlan = currentGamePlan == GamePlan.Bust ? GamePlan.MaxDamage : GamePlan.Bust;
        Card cardToSwap;
        if(cardsOfType.Count > 0)
        {
            cardToSwap = ChooseOptimalCard(oppositeGamePlan, allCards: cardsOfType.ToArray());
        } else {
            cardToSwap = ChooseOptimalCard(oppositeGamePlan);
        }
        
        yield return power.GetComponent<SupremeSwap>().SupremeSwapCard(cardToSwap, this, cardToSwap.transform.position, cardToSwap.moveRotPivot.transform.rotation);
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    float GetProbToActivateDominate(Power power)
    {
        if((arcana >= power.cost || power.amount > 0) && currentGamePlan == GamePlan.MaxDamage)
        {
            const float dominateStreakMinForBonus = 2;
            const float dominateStreakMinScalar = .7f;
            const float dominateSupremeTypeScalar = .7f;
            const float dominateTurn1BonusScalar = .7f;

            float prob = dominateStreakMinScalar * dominateSupremeTypeScalar * ChanceToPlayOptimally[(int)difficulty];
            if(gameManager.SupremeCard.type == CardToPlay.type)
            {
                prob /= dominateSupremeTypeScalar;
            }
            if(gameManager.enemyStreak >= dominateStreakMinForBonus)
            {
                prob /= dominateStreakMinScalar;
            }
            if(gameManager.turn == 1)
            {
                if(!GetCardRatingInfo(CardToPlay, currentGamePlan, player.cardBeingPlayed).clearsTarget)
                {
                    prob /= dominateTurn1BonusScalar;
                }
            }
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateDominate(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        power.OnSelect();
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    float GetProbToActivateAdrenaline(Power power)
    {
        if((arcana >= power.cost || power.amount > 0) && currentGamePlan == GamePlan.MaxDamage)
        {
            const float adrenalineStreakMinForBonus = 2;
            const float adrenalineStreakMinScalar = .85f;
            const float adrenalineSupremeTypeScalar = .85f;

            float prob = adrenalineStreakMinScalar * adrenalineSupremeTypeScalar * ChanceToPlayOptimally[(int)difficulty];
            if(gameManager.SupremeCard.type == CardToPlay.type)
            {
                prob /= adrenalineSupremeTypeScalar;
            }
            if(gameManager.enemyStreak >= adrenalineStreakMinForBonus)
            {
                prob /= adrenalineStreakMinScalar;
            }
            float manaScalar = ((float)mana - (float)Adrenaline.manaLossOnWin) / (float)maxMana;
            float denominationScalar = (float)CardToPlay.denomination / (float)GameManager.maxCardDenomination;
            prob *= manaScalar * denominationScalar;
            return prob;
        } else
        {
            return 0;
        }
    }
    IEnumerator ActivateAdrenaline(Power power)
    {
        power.BuyPower();
        yield return new WaitForSeconds(waitAfterActivatingPower);
        power.OnSelect();
        yield return new WaitForSeconds(waitAfterActivatingPower);
    }
    CardRating GetCardRatingInfo(Card card, GamePlan gamePlan, Card opposingCard = null)
    {
        int targetRating = opposingCard == null ? defaultTargetRating : RateCard(player.cardBeingPlayed, player); 
        int cardRating = RateCard(card, this);
        
        CardRating cardRatingInfo = new CardRating(card, cardRating, 0, 0, 0);
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
                winsRoShamBo = GameManager.RoShamBoWinner(card.type, player.cardBeingPlayed.type) == 1;
            }
            if(winsRoShamBo && gamePlan == GamePlan.MaxDamage || !winsRoShamBo && gamePlan == GamePlan.Bust)
            {
                cardRatingInfo.clearsTarget = true;
            } else
            {
                cardRatingInfo.clearsTarget = false;
            }
        }

        int diff = cardRating - targetRating;
        if(diff == 0)
        {
            if(cardRatingInfo.clearsTarget)
            {
                diff = gameManager.RoShamBoWinnerDenominationBonus;
            } else
            {
                diff = -gameManager.RoShamBoWinnerDenominationBonus;
            }
        }

        int damage = Mathf.Abs(diff);
        if(diff > 0)
        {
            damage += gameManager.enemyStreak;
            if(card.type == gameManager.SupremeCard.type) damage *= 2;
        } else
        {
            damage += gameManager.playerStreak;
            if(opposingCard != null)
            {
                if(opposingCard.type == gameManager.SupremeCard.type) damage *= 2;
            } 
        }
        cardRatingInfo.damage = damage;
        cardRatingInfo.extraDamage = damage - diff;
        cardRatingInfo.ratingTargetDiff = diff;
        return cardRatingInfo;
    }
    float[] GetCardDuelPickRating(GamePlan gamePlan, Card opposingCard = null, Card[] allCards = null)
    {
        int targetRating = opposingCard == null ? defaultTargetRating : RateCard(opposingCard, player);
        allCards = allCards == null ? HandOfCards.ToArray() : allCards;
        CardRating[] allCardRatings = new CardRating[allCards.Length];
        float[] duelPickRatings = new float[allCards.Length];
        for(int i = 0; i < allCardRatings.Length; i++)
        {
            allCardRatings[i] = GetCardRatingInfo(allCards[i], gamePlan, opposingCard);
        }
        for(int i = 0; i < allCardRatings.Length; i++)
        {
            CardRating cardRating = allCardRatings[i];

            if(gamePlan == GamePlan.MaxDamage && gameManager.turn == 0)
            {
                float maxDmgTurn0ExtraDmgScalar = 1.5f;
                float maxDmgTurn0SupremeTypeRatingEffect = -3;

                duelPickRatings[i] = cardRating.rating;
                duelPickRatings[i] += cardRating.extraDamage / maxDmgTurn0ExtraDmgScalar;
                if(cardRating.card.type == gameManager.SupremeCard.type)
                {
                    duelPickRatings[i] += maxDmgTurn0SupremeTypeRatingEffect;
                }
            }

            if(gamePlan == GamePlan.MaxDamage && gameManager.turn == 1)
            {
                int maxDmgTurn1DeadZoneRange = 3;
                int maxDmgTurn1SupremeTypeDeadZoneRange = 2;
                int maxDmgTurn1MinStreakToOverrideDeadZone = 2;

                duelPickRatings[i] = cardRating.damage;
                if(gameManager.enemyStreak < maxDmgTurn1MinStreakToOverrideDeadZone)
                {
                    if(cardRating.damage > 0 && cardRating.damage <= maxDmgTurn1DeadZoneRange)
                    {
                        duelPickRatings[i] = -2 * (maxDmgTurn1DeadZoneRange - cardRating.damage);
                    }
                    if(cardRating.card.type == gameManager.SupremeCard.type && cardRating.ratingTargetDiff <= maxDmgTurn1SupremeTypeDeadZoneRange)
                    {
                        duelPickRatings[i] = -4 * (maxDmgTurn1DeadZoneRange - cardRating.ratingTargetDiff);
                    }
                }
            }

            if(gamePlan == GamePlan.Bust && gameManager.turn == 0)
            {
                float bustTurn0SupremeTypeRatingEffect = -3;

                duelPickRatings[i] = GameManager.maxCardDenomination - cardRating.rating;
                if(cardRating.card.type == gameManager.SupremeCard.type)
                {
                    duelPickRatings[i] += bustTurn0SupremeTypeRatingEffect;
                }
            }

            if(gamePlan == GamePlan.Bust && gameManager.turn == 1)
            {
                int diff = cardRating.ratingTargetDiff;
                if(cardRating.card.type == gameManager.SupremeCard.type && cardRating.ratingTargetDiff <= 0)
                {
                    diff = -GameManager.maxCardDenomination;
                }
                if(diff <= 0)
                {
                    diff += GameManager.maxCardDenomination;
                }  else
                {
                    diff -= GameManager.maxCardDenomination;
                }
                duelPickRatings[i] = diff;
            }
        }
        return duelPickRatings;
    }
    Card ChooseOptimalCard(GamePlan gamePlan, Card opposingCard = null, Card[] allCards = null)
    {
        float[] cardDuelPickRatings = GetCardDuelPickRating(gamePlan, opposingCard, allCards);
        allCards = allCards == null ? HandOfCards.ToArray() : allCards;
        return allCards[Array.IndexOf(cardDuelPickRatings, cardDuelPickRatings.Max())];
    }
    int[] RateAllCards(List<Card> cards = null, bool forRound = false)
    {
        if(cards == null)
            cards = HandOfCards;

        int[] cardRatings = new int[cards.Count];
        for(int i = 0; i < cards.Count; i++)
        {
            cardRatings[i] = forRound ? RateCardForRound(cards[i]) : RateCard(cards[i], this);
        }
        return cardRatings;
    }
    int RateCard(Card card, Agent agent)
    {
        int rating = card.denomination;
        Agent otherAgent = agent == AIEnemy ? player : AIEnemy;
        if(gameManager.agentDominate == agent)
        {
            rating += gameManager.RoShamBoWinnerDenominationBonus;
        } else if(otherAgent.cardBeingPlayed != null)
        {
            if(GameManager.RoShamBoWinner(card.type, otherAgent.cardBeingPlayed.type) == 1)
            {
                rating += gameManager.RoShamBoWinnerDenominationBonus;
            }
        } else
        {
            rating = RateCardForRound(card);
        }
        
        if(agent.adrenalineActive)
        {
            rating *= 2;
        }
        
        if(gameManager.mimicryActive && gameManager.turn == 1 && gameManager.currentPlayer == agent)
        {
            if(card.type != otherAgent.cardBeingPlayed.type)
            {
                rating = 0;
            }
        }
        return rating;
    }
    int RateCardForRound(Card card) //rate the card in the context of the whole round not just the current deul 
    {
        int rating = card.denomination;
        CountedCards countedCards = CountedCards.GetCountedCards(this);
        int advantageousMatchupCount = countedCards.GetCountFromMagicType(GameManager.GetAdvantageMatchupType(card.type));
        rating += Mathf.RoundToInt(3f * (float)advantageousMatchupCount / (float)GameManager.maxCardDenomination);

        int disadvantageousMatchupCount = countedCards.GetCountFromMagicType(GameManager.GetAdvantageMatchupType(card.type));
        rating -= Mathf.RoundToInt(3f * (1-(float)disadvantageousMatchupCount / (float)GameManager.maxCardDenomination));
        return rating;
    } 
    struct CountedCards
    {
        public int[] typeCounts;
        public int illusionCount;
        public int evocationCount;
        public int abjurationCount;
        public MagicType max;
        public MagicType mid;
        public MagicType min;
        public CountedCards(int illusion, int evocation, int abjuration)
        {
            illusionCount = illusion;
            evocationCount = evocation;
            abjurationCount = abjuration;
            typeCounts = new int[3];
            max = MagicType.Abjuration;
            mid = MagicType.Abjuration;
            min = MagicType.Abjuration;
        }
        public static CountedCards GetCountedCards(Agent agent)
        {
            CountedCards countedCards = new CountedCards(0,0,0);
            foreach(Card card in GameManager.AIEnemy.WonCards)
            {
                switch(card.type)
                {
                    case MagicType.Illusion:
                        countedCards.typeCounts[0]++;
                        break;
                    case MagicType.Evocation:
                        countedCards.typeCounts[1]++;
                        break;
                    case MagicType.Abjuration:
                        countedCards.typeCounts[2]++;
                        break;
                }
            }
            foreach(Card card in GameManager.player.WonCards)
            {
                switch(card.type)
                {
                    case MagicType.Illusion:
                        countedCards.typeCounts[0]++;
                        break;
                    case MagicType.Evocation:
                        countedCards.typeCounts[1]++;
                        break;
                    case MagicType.Abjuration:
                        countedCards.typeCounts[2]++;
                        break;
                }
            }
            foreach(Card card in GameManager.AIEnemy.HandOfCards)
            {
                switch(card.type)
                {
                    case MagicType.Illusion:
                        countedCards.typeCounts[0]++;
                        break;
                    case MagicType.Evocation:
                        countedCards.typeCounts[1]++;
                        break;
                    case MagicType.Abjuration:
                        countedCards.typeCounts[2]++;
                        break;
                }
            }
            countedCards.illusionCount = countedCards.typeCounts[0];
            countedCards.evocationCount = countedCards.typeCounts[1];
            countedCards.abjurationCount = countedCards.typeCounts[2];

            int minIndx = Array.IndexOf(countedCards.typeCounts, countedCards.typeCounts.Min());
            if(minIndx == 0) countedCards.min = MagicType.Illusion;
            if(minIndx == 1) countedCards.min = MagicType.Evocation;
            if(minIndx == 2) countedCards.min = MagicType.Abjuration;

            int maxIndx = Array.IndexOf(countedCards.typeCounts, countedCards.typeCounts.Min());
            if(maxIndx == 0) countedCards.max = MagicType.Illusion;
            if(maxIndx == 1) countedCards.max = MagicType.Evocation;
            if(maxIndx == 2) countedCards.max = MagicType.Abjuration;

            if(countedCards.max == MagicType.Illusion && countedCards.min == MagicType.Evocation) countedCards.mid = MagicType.Abjuration;
            if(countedCards.max == MagicType.Illusion && countedCards.min == MagicType.Abjuration) countedCards.mid = MagicType.Evocation;
            if(countedCards.max == MagicType.Evocation && countedCards.min == MagicType.Abjuration) countedCards.mid = MagicType.Illusion;
            if(countedCards.max == MagicType.Evocation && countedCards.min == MagicType.Illusion) countedCards.mid = MagicType.Abjuration;
            if(countedCards.max == MagicType.Abjuration && countedCards.min == MagicType.Illusion) countedCards.mid = MagicType.Evocation;
            if(countedCards.max == MagicType.Abjuration && countedCards.min == MagicType.Evocation) countedCards.mid = MagicType.Illusion;

            return countedCards;
        }
        public int GetCountFromMagicType(MagicType type)
        {
            switch(type)
            {
                case MagicType.Illusion:
                    return illusionCount;
                case MagicType.Evocation:
                    return evocationCount;
                case MagicType.Abjuration:
                    return abjurationCount;
            }
            return 0;
        }
    }
    protected override IEnumerator WaitEndTurn(Card card, CardSlot slot, bool endTurn = true)
    {
        yield return base.WaitEndTurn(card, slot, false);
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
        finishedFn?.Invoke();
    }
}