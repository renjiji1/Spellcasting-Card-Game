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
    [SerializeField] float rotationAxisSpeed = 200;
    [SerializeField] float delayBetweenCardShuffles = .05f;
    [SerializeField] float delayBetweenCardDealings = .1f;
    [NonSerialized] public bool isShuffling = false;
    [SerializeField] float enterShuffleAnimSpeed = 10;
    [SerializeField] float enterShufflePosXOffset = 10;
    [SerializeField] float exitShuffleAnimSpeed = 10;
    GameObject ShuffleRotationAxis;

    protected override void Start()
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
    public void RunStart() {Start();}

    protected override void Update()
    {
        base.Update();
        if(isShuffling)
        {
            ShuffleRotationAxis.transform.Rotate(new Vector3(0, Time.deltaTime * rotationAxisSpeed, 0));
        }
    }
    public IEnumerator StartShuffle()
    {
        isShuffling = true;
        foreach(Card card in DeckOfCards)
        {
            card.BeginShuffle(enterShufflePosXOffset, enterShuffleAnimSpeed);
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        StartCoroutine(ExitShuffle());
    }
    IEnumerator ExitShuffle()
    {
        List<Card> tmpDeck = new List<Card>(DeckOfCards);
        List<Card> newDeck = new List<Card>();
        for(int i = 0; i < DeckOfCards.Count; i++)
        {
            int rng = Random.Range(0, tmpDeck.Count);
            Card choosenCard = tmpDeck[rng];
            newDeck.Add(choosenCard);
            tmpDeck.RemoveAt(rng);
            Vector3 cardPos = new Vector3(transform.position.x, transform.position.y + (i+1) * choosenCard.thickness, transform.position.z);
            choosenCard.ExitShuffle(cardPos, exitShuffleAnimSpeed);
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        newDeck.Reverse();
        DeckOfCards = newDeck;
        isShuffling = false;
        StartCoroutine(DealCards());
    }
    IEnumerator DealCards()
    { 
        List<Card> tmpDeck = new List<Card>(DeckOfCards);
        for(int i = 0; i < player.Hand.transform.childCount*2; i += 2)
        {
            Transform playerCardTransform = player.Hand.transform.GetChild(i/2);
            Vector3 playerTargetPos = playerCardTransform.position;
            Card playerCard = tmpDeck[i];
            playerCard.StartMoving(playerTargetPos, playerCardTransform.rotation, fn: () =>
            {
                player.AddCard(playerCard);
                DeckOfCards.Remove(playerCard);
                playerCard.HandTransform = playerCardTransform;
            });
            Transform enemyCardTransform = AIEnemy.Hand.transform.GetChild(i/2);
            Vector3 enemyTargetPos = enemyCardTransform.position;
            Card enemyCard = tmpDeck[i+1];
            enemyCard.StartMoving(enemyTargetPos, enemyCardTransform.rotation, fn: () =>
            {
                AIEnemy.AddCard(enemyCard);
                DeckOfCards.Remove(enemyCard);
                enemyCard.HandTransform = enemyCardTransform;
            });
            yield return new WaitForSeconds(delayBetweenCardDealings);
        }
    }
}
