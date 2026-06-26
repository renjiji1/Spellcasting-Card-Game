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

    // Update is called once per frame
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
            card.BeginShuffle();
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        StartCoroutine(ExitShuffle());
    }
    IEnumerator ExitShuffle()
    {
        List<Card> tmpDeck = new List<Card>(DeckOfCards);
        DeckOfCards.Clear();
        for(int i = 0; i < DeckOfCards.Count; i++)
        {
            int rng = Random.Range(0, tmpDeck.Count);
            Card choosenCard = tmpDeck[rng];
            DeckOfCards.Add(choosenCard);
            Vector3 cardPos = new Vector3(transform.position.x, transform.position.y + (i+1) * choosenCard.thickness, transform.position.z);
            choosenCard.ExitShuffle(cardPos);
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        DeckOfCards.Reverse();
        isShuffling = false;
        StartCoroutine(DealCards());
    }
    IEnumerator DealCards()
    { 
        for(int i = 0; i < player.Hand.transform.childCount*2; i += 2)
        {
            Quaternion playerSideRotation = Quaternion.Euler(0,0,player.Hand.transform.rotation.z);
            Vector3 playerTargetPos = player.Hand.transform.GetChild(Mathf.FloorToInt(i/2)).position;
            DeckOfCards[i].StartMoving(playerTargetPos, playerSideRotation, fn: () =>
            {
                player.AddCard(DeckOfCards[i]);
                DeckOfCards.RemoveAt(i);
            });
            Quaternion enemySideRotation = Quaternion.Euler(0,180, AIEnemy.Hand.transform.rotation.z);
            Vector3 enemyTargetPos = AIEnemy.Hand.transform.GetChild(Mathf.FloorToInt(i/2)).position;
            DeckOfCards[i+1].StartMoving(enemyTargetPos, playerSideRotation, fn: () =>
            {
                AIEnemy.AddCard(DeckOfCards[i+1]);
                DeckOfCards.RemoveAt(i+1);
            });
            yield return new WaitForSeconds(delayBetweenCardDealings);
        }
    }
}
