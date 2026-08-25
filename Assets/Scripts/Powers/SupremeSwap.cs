using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class SupremeSwap : Power
{
    public override void OnSelect()
    {
        base.OnSelect();
        gameManager.SupremeCardSwapTxt.SetActive(agent == player);
        agent.canSupremeCardSwap = true;
        agent.powerActiveCantPlayCard = true;
    } 
    public IEnumerator SupremeSwapCard(Card card, Agent agent, Vector3 prevCardPos, Quaternion prevCardRot)
    {
        card.isBeingSwapped = true;
        int cardsInPosition = 0;
        card.StartMoving(gameManager.SupremeCardSpawnPoint.position, Quaternion.Euler(90,0,0), fn: () =>
        {
            cardsInPosition++;
            agent.RemoveCard(card);
            card.isBeingSwapped = false;
            gameManager.SupremeCard = card;
            Debug.Log($"card pos {card.transform.position} supreme point pos {gameManager.SupremeCardSpawnPoint.position}");
            gameManager.SupremeCardSpawnPoint.transform.Find("TypeProjection").GetComponent<SpriteRenderer>().sprite = card.transform.Find($"{card.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
        });
        Card currentSupremeCard = gameManager.SupremeCard;
        currentSupremeCard.StartMoving(prevCardPos, prevCardRot, fn: () =>
        {
            cardsInPosition++;
            currentSupremeCard.HandTransform = card.HandTransform;
            agent.AddCard(currentSupremeCard);
        });

        yield return new WaitUntil(() => cardsInPosition >= 2);
        agent.powerActiveCantPlayCard = false;
        gameManager.SupremeCardSwapTxt.SetActive(false);
        if(agent is Player)
        {
            agent.GetComponent<Player>().ReOrderCards();
        }
    }
}
