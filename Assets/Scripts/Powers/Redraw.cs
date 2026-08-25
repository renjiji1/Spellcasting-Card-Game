using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;
using UnityEngine.UI;

public class Redraw : Power
{
    [SerializeField] Vector3 offsetFromCam = new Vector3(0,0, 1f);
    [NonSerialized] public bool drawedCardInPlace = false;
    GameObject DumpCardButton;
    Card drawedCard;
    public override void Start()
    {
        base.Start();
        DumpCardButton = gameManager.DumpCardButtonOnRedraw;
        DumpCardButton.GetComponent<Button>().onClick.AddListener(() => {StartCoroutine(DumpCard());});
    }
    public override void OnSelect()
    {
        base.OnSelect();
        drawedCardInPlace = false;
        drawedCard = null;
        gameManager.RedrawTxt.SetActive(agent == player);
        agent.powerActiveCantPlayCard = true;
        StartCoroutine(ChooseRandomCardFromDeck());
    } 
    IEnumerator ChooseRandomCardFromDeck()
    {
        bool takeCardDone = false;
        Vector3 playerPos = cam.transform.position + cam.transform.forward * offsetFromCam.z + cam.transform.right * offsetFromCam.x + cam.transform.up * offsetFromCam.y;
        Vector3 enemyPos = AIEnemy.transform.position + AIEnemy.transform.forward * offsetFromCam.z + AIEnemy.transform.right * offsetFromCam.x + AIEnemy.transform.up * offsetFromCam.y;
        Vector3 pos = agent == player ? playerPos : enemyPos;
        Quaternion rot = agent == player ? cam.transform.rotation : AIEnemy.transform.rotation;
        StartCoroutine(gameManager.Deck.GetComponent<Deck>().TakeCardRandomlyFromDeck(pos, rot, fn: (Card newCard) =>
        {
            takeCardDone = true;
            drawedCard = newCard;
        }));
        
        yield return new WaitUntil(() => takeCardDone);
        drawedCardInPlace = true;
        agent.canRedraw = true;
        DumpCardButton.SetActive(agent == player);
    }

    public IEnumerator DumpCard()
    {
        if(drawedCard != null)
        {
            bool insertCardDone = false;
            StartCoroutine(gameManager.Deck.GetComponent<Deck>().InsertCardRandomlyIntoDeck(drawedCard, fn: () =>
            {
                insertCardDone = true;
            })); 
            DumpCardButton.SetActive(false);
            gameManager.RedrawTxt.SetActive(false);
            yield return new WaitUntil(() => insertCardDone);
            agent.canRedraw = false;
            agent.powerActiveCantPlayCard = false;
        }
    }
    public IEnumerator RedrawCard(Card card, Agent agent)
    {
        card.isBeingSwapped = true;

        bool takeNewCardDone = false;
        drawedCard.StartMoving(card.transform.position, card.moveRotPivot.transform.rotation, fn: () =>
        {
            takeNewCardDone = true;
        });

        bool insertCardDone = false;
        StartCoroutine(gameManager.Deck.GetComponent<Deck>().InsertCardRandomlyIntoDeck(card, fn: () =>
        {
            insertCardDone = true;
        }));

        yield return new WaitUntil(() => takeNewCardDone && insertCardDone);
        agent.RemoveCard(card);
        agent.AddCard(drawedCard);
        card.isBeingSwapped = false;
        drawedCard.HandTransform = card.HandTransform;
        DumpCardButton.SetActive(false);
        agent.powerActiveCantPlayCard = false;
        gameManager.RedrawTxt.SetActive(false);
        if(agent is Player)
        {
            agent.GetComponent<Player>().ReOrderCards();
        }
    }
}
