using UnityEngine;
using System.Collections.Generic;
using System;
using TMPro;

public class Agent : Entity
{
    [NonSerialized] public bool isAgentTurn = false;
    protected int totalDamage = 0;
    protected int currentDamage = 0;
    [SerializeField] protected const int maxMana = 10;
    protected int mana = maxMana;
    [NonSerialized] public int roundWins = 0;
    [SerializeField] protected float useCardSpeed = 5;
    protected List<Card> HandOfCards = new List<Card>();
    [NonSerialized] public List<Card> WonCards = new List<Card>();
    public GameObject Hand;
    [NonSerialized] public Card cardBeingPlayed;
    public override void Start()
    {
        base.Start();
    }
    protected override void Update()
    {
        base.Update();
    }
    public virtual void AddCard(Card card)
    {
        HandOfCards.Add(card);
    }
    public virtual void DeactivateCurrentCard(int addedDenomination)
    {
        cardBeingPlayed.denomination -= addedDenomination;
        cardBeingPlayed.transform.Find($"{cardBeingPlayed.frontPath}/Denomination").GetComponent<TMP_Text>().text = ""+cardBeingPlayed.denomination;
        cardBeingPlayed.hasBeenPlayed = true;
        cardBeingPlayed.isBeingPlayed = false;
        cardBeingPlayed = null;
    }
    public virtual void StartTurn()
    {
        isAgentTurn = true;
    }
    public virtual void EndTurn()
    {
        isAgentTurn = false;
        gameManager.EndTurn();
    }
    public virtual void UseCard(Card card, CardSlot slot)
    {
        cardBeingPlayed = card;
        card.OnDeselect();
        card.isBeingPlayed = true;
        card.GetComponent<Animator>().SetBool("UseCard", true);
        card.GetComponent<Animator>().speed = card.GetAnimLengthByName("UseCard") / card.GetTotalMoveTime(useCardSpeed);
        card.StartMoving(slot.transform.position + new Vector3(0, slot.cardOnSlotYOffset,0), slot.transform.rotation, speed: useCardSpeed, fn: () =>
        {
            card.GetComponent<Animator>().SetBool("UseCard", false);
            HandOfCards.Remove(card);
            EndTurn();
        });
    }

    public virtual void EndRound()
    {
        mana = maxMana;
        totalDamage = 0;
    }
    public virtual void WinRound()
    {
        EndRound();
        roundWins++;
    }
    public virtual void LoseRound()
    {
        EndRound();
    }
}
