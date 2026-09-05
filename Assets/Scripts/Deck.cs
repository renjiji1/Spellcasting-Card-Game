using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Debug = UnityEngine.Debug;
using Random = UnityEngine.Random;
using Object = UnityEngine.Object;
using NaughtyAttributes;
public class Deck : Entity
{
    [NonSerialized] public List<Card> DeckOfCards = new List<Card>();
    [Header("Deck")]
    [SerializeField] Vector3 deckPosInsertOffset = new Vector3(.1f, 0, 0);
    [SerializeField] float deckInsertDelay = 10;
    [SerializeField] float deckInsertSpeed = 2;
    [SerializeField] float deckTakeReturnSpeed = 4;
    [SerializeField] float rotationAxisSpeed = 200;
    [SerializeField] float delayBetweenCardShuffles = .05f;
    [SerializeField] float delayBetweenCardDealings = .1f;
    [NonSerialized] public bool isShuffling = false;
    [NonSerialized] public bool isDealing = false;
    [SerializeField] float enterShuffleAnimSpeed = 10;
    [SerializeField] float enterShufflePosXOffset = 10;
    [SerializeField] float exitShuffleAnimSpeed = 10;
    
    GameObject ShuffleRotationAxis;

    public override void Start()
    {
        if(startHasRan) return;
        base.Start();
        ShuffleRotationAxis = transform.Find("ShuffleRotationAxis").gameObject;
        foreach(Transform child in transform)
        {
            Card card = child.gameObject.GetComponent<Card>();
            if(card != null)
            {
                DeckOfCards.Add(card);
            }
        }
    }
    protected override void Update()
    {
        base.Update();
        if(RunUpdate())
        {
            if(isShuffling)
            {
                ShuffleRotationAxis.transform.Rotate(new Vector3(0, Time.deltaTime * rotationAxisSpeed, 0));
            }
        }
    }
    public IEnumerator InsertCardRandomlyIntoDeck(Card card, Action fn = null)
    {
        int rng = Random.Range(0, DeckOfCards.Count);
        bool movedToInsertPos = false;
        card.GetComponent<Animator>().SetBool("Insert&TakeFromDeck", true);
        card.GetComponent<Animator>().speed = card.GetAnimLengthByName("Insert&TakeFromDeck") / card.GetTotalMoveTime(deckInsertSpeed);
        card.StartMoving(transform.position + deckPosInsertOffset, Quaternion.Euler(-90,0,180), speed: deckInsertSpeed, fn: () =>  {
            movedToInsertPos = true;
            card.GetComponent<Animator>().SetBool("Insert&TakeFromDeck", false);
        });
        
        yield return new WaitUntil(() => movedToInsertPos);
        for(int i = rng-1; i < DeckOfCards.Count; i++)
        {
            if(i < 0) continue;
            Card deckCard = DeckOfCards[i];
            Vector3 targetPos = new Vector3(deckCard.transform.position.x, deckCard.transform.position.y + deckCard.thickness, deckCard.transform.position.z);
            deckCard.StartMoving(targetPos, speed: deckInsertSpeed);
        }
        
        yield return new WaitForSeconds(deckInsertDelay);     
        card.StartMoving(transform.position + card.thickness * rng * transform.up, speed: deckInsertSpeed, fn: () => {
            DeckOfCards.Insert(rng, card);
            if(fn != null) fn.Invoke();
        });
    }
    public IEnumerator TakeCardRandomlyFromDeck(Vector3 targetPos, Quaternion? targetRot = null, Action<Card> fn = null)
    {
        int rng = Random.Range(0, DeckOfCards.Count);
        Card card = DeckOfCards[rng];
        bool movedToInsertPos = false;
        card.StartMoving(transform.position + deckPosInsertOffset, speed: deckInsertSpeed, fn: () => {
            movedToInsertPos = true;
            DeckOfCards.RemoveAt(rng);
        });
        
        yield return new WaitUntil(() => movedToInsertPos);
        for(int i = rng-1; i < DeckOfCards.Count; i++)
        {
            if(i < 0) continue;
            Card deckCard = DeckOfCards[i];
            Vector3 newPos = new Vector3(deckCard.transform.position.x, deckCard.transform.position.y - card.thickness, deckCard.transform.position.z);
            deckCard.StartMoving(newPos, speed: deckInsertSpeed);
        }
        
        yield return new WaitForSeconds(deckInsertDelay);
        card.GetComponent<Animator>().SetBool("Insert&TakeFromDeck", true);
        card.GetComponent<Animator>().speed = card.GetAnimLengthByName("Insert&TakeFromDeck") / card.GetTotalMoveTime(deckTakeReturnSpeed);
        card.StartMoving(targetPos, targetRot, speed: deckTakeReturnSpeed, fn: () => {
            card.GetComponent<Animator>().SetBool("Insert&TakeFromDeck", false);
            if(fn != null) fn.Invoke(card);
        });
    }
    public IEnumerator StartShuffle()
    {
        yield return ReturnSupremeCardToDeck();
        cam.GetComponent<Animator>().SetBool("LookAtShuffle", true);
        isShuffling = true;
        int cardsBegunShuffling = 0;
        for(int i = DeckOfCards.Count-1; i >= 0; i--)
        {
            Card card = DeckOfCards[i];
            card.BeginShuffle(enterShufflePosXOffset, enterShuffleAnimSpeed, fn: () => {cardsBegunShuffling++;});
            card.ActivateCard();
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        yield return new WaitUntil(() => cardsBegunShuffling >= DeckOfCards.Count);
        StartCoroutine(ExitShuffle());
    }
    IEnumerator ReturnSupremeCardToDeck()
    {
        bool isReturningSupremeCardToDeck = true;
        if(gameManager.SupremeCard != null)
        {
            StartCoroutine(InsertCardRandomlyIntoDeck(gameManager.SupremeCard, fn: () =>
            {
                gameManager.SupremeCard = null;
                isReturningSupremeCardToDeck = false;
            }));

        } else {isReturningSupremeCardToDeck = false;}
        yield return new WaitUntil(() => !isReturningSupremeCardToDeck);
    }
    IEnumerator ExitShuffle()
    {
        List<Card> tmpDeck = new List<Card>(DeckOfCards);
        List<Card> newDeck = new List<Card>();
        int cardsReturnedToDeck = 0;
        for(int i = 0; i < DeckOfCards.Count; i++)
        {
            int rng = Random.Range(0, tmpDeck.Count);
            Card choosenCard = tmpDeck[rng];
            newDeck.Add(choosenCard);
            tmpDeck.RemoveAt(rng);
            Vector3 cardPos = new Vector3(transform.position.x, transform.position.y + (i+1) * choosenCard.thickness, transform.position.z);
            choosenCard.transform.parent = transform;
            choosenCard.ExitShuffle(cardPos, exitShuffleAnimSpeed, fn: () =>
            {
                cardsReturnedToDeck++;
            });
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        yield return new WaitUntil(() => cardsReturnedToDeck >= DeckOfCards.Count);
        DeckOfCards = newDeck;
        isShuffling = false;
        cam.GetComponent<Animator>().SetBool("LookAtShuffle", false);
        yield return ChooseNewSupremeCard();
        StartCoroutine(DealCards());
    }
    IEnumerator ChooseNewSupremeCard()
    {
        bool isChoosingSupremeCard = true;
        StartCoroutine(TakeCardRandomlyFromDeck(gameManager.SupremeCardSpawnPoint.position, targetRot: Quaternion.Euler(90,0,0), fn: (card) =>
        {
            gameManager.SupremeCard = card;
            gameManager.SupremeCardSpawnPoint.transform.Find("TypeProjection").GetComponent<SpriteRenderer>().sprite = card.transform.Find($"{card.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
            gameManager.SupremeCardSpawnPoint.transform.Find("TypeProjection").gameObject.SetActive(true);
            isChoosingSupremeCard = false;
        }));
        yield return new WaitUntil(() => !isChoosingSupremeCard);
    }
    IEnumerator DealCards()
    { 
        isDealing = true;
        List<Card> tmpDeck = new List<Card>(DeckOfCards);
        List<Card> futurePlayerCards = new List<Card>();
        int playerCardsInHand = 0;
        int enemyCardsInHand = 0;
        int j = tmpDeck.Count-1;
        for(int i = 0; i < player.Hand.transform.childCount; i++)
        {
            futurePlayerCards.Add(tmpDeck[j]);
            j -= 2;
        }
        futurePlayerCards = OrderCards(futurePlayerCards);
        for(int i = 0; i < player.Hand.transform.childCount*2; i += 2)
        {
            Card playerCard = tmpDeck[tmpDeck.Count-1-i];
            Transform playerCardTransform = player.Hand.transform.GetChild(futurePlayerCards.IndexOf(playerCard));
            Vector3 playerTargetPos = playerCardTransform.position;
            playerCard.StartMoving(playerTargetPos, playerCardTransform.rotation, fn: () =>
            {
                player.AddCard(playerCard);
                DeckOfCards.Remove(playerCard);
                playerCard.ogHandPos = playerCardTransform.position;
                playerCard.HandTransform = playerCardTransform;
                playerCardsInHand++;
            });
            Transform enemyCardTransform = AIEnemy.Hand.transform.GetChild(i/2);
            Vector3 enemyTargetPos = enemyCardTransform.position;
            Card enemyCard = tmpDeck[tmpDeck.Count-2-i];
            enemyCard.StartMoving(enemyTargetPos, enemyCardTransform.rotation, fn: () =>
            {
                AIEnemy.AddCard(enemyCard);
                DeckOfCards.Remove(enemyCard);
                enemyCard.HandTransform = enemyCardTransform;
                enemyCardsInHand++;
            });
            yield return new WaitForSeconds(delayBetweenCardDealings);
        }
        yield return new WaitUntil(() => playerCardsInHand >= player.Hand.transform.childCount && enemyCardsInHand >= AIEnemy.Hand.transform.childCount);
        player.ReOrderCards();
        isDealing = false;
    }
    public static List<Card> OrderCards(List<Card> cards)
    {
        int[] cardsOrderRanked = new int[cards.Count];
        Card[] newCards = new Card[cards.Count];
        for(int i = 0; i < cards.Count; i++)
        {
            int rank = cards[i].denomination;
            if(cards[i].type == MagicType.Evocation)
            {
                rank += GameManager.maxCardDenomination;
            }
            if(cards[i].type == MagicType.Illusion)
            {
                rank += GameManager.maxCardDenomination*2;
            }
            cardsOrderRanked[i] = rank;
            newCards[i] = cards[i];
        }
        
        Array.Sort(cardsOrderRanked, newCards);
        return newCards.Reverse().ToList();
    }
    public void AddCardToTopOfDeck(Card card, float speed, Action? fn = null) 
    {
        Vector3 pos = transform.position + new Vector3(0, DeckOfCards.Count * card.thickness,0);
        Quaternion rot = Quaternion.Euler(-90, 0, 180);
        DeckOfCards.Add(card);
        card.StartMoving(pos, rot, speed: speed, fn: () =>
        {  
            fn?.Invoke();
        });
    }

}
