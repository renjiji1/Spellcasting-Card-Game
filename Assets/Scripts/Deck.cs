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
    [Header("Shuffle")]
    [SerializeField] float rotationAxisSpeed = 200;
    [SerializeField] float delayBetweenCardShuffles = .05f;
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
    public void StartShuffle()
    {
        isShuffling = true;
        StartCoroutine(ActivateCardShuffle());
    }
    IEnumerator ActivateCardShuffle()
    {
        foreach(Card card in DeckOfCards)
        {
            card.BeginShuffle();
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        StartCoroutine(ActivateCardExitShuffle());
    }
    IEnumerator ActivateCardExitShuffle()
    {
        List<Card> tmpDeck = new List<Card>(DeckOfCards);
        DeckOfCards.Clear();
        for(int i = 0; i < DeckOfCards.Count; i++)
        {
            int rng = Random.Range(0, tmpDeck.Count);
            Card choosenCard = tmpDeck[i];
            DeckOfCards.Add(choosenCard);
            Vector3 cardPos = new Vector3(transform.position.x, transform.position.y + (i+1) * choosenCard.thickness, transform.position.z);
            choosenCard.ExitShuffle(cardPos);
            yield return new WaitForSeconds(delayBetweenCardShuffles);
        }
        DeckOfCards.Reverse();
        isShuffling = false;
        DealCards();
    }
    void DealCards()
    {
        
    }
}
