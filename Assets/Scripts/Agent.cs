using UnityEngine;
using System.Collections.Generic;
using System;
using TMPro;

public class Agent : Entity
{
    [NonSerialized] public bool isAgentTurn = false;
    [NonSerialized] public int points = 0;
    [SerializeField] public int pointsToWin = 55;
    [SerializeField] protected const int maxMana = 10;
    protected int mana = maxMana;
    [NonSerialized] public int roundWins = 0;
    [SerializeField] protected float useCardSpeed = 5;
    protected List<Card> HandOfCards = new List<Card>();
    [NonSerialized] public List<Card> WonCards = new List<Card>();
    public GameObject Hand;
    [NonSerialized] public Card cardBeingPlayed;

    [SerializeField] GameObject ManaBar;
    [SerializeField] GameObject PointsWheel;
    [SerializeField] public TMP_Text PointsTxt;
    public override void Start()
    {
        base.Start();
    }
    protected override void Update()
    {
        base.Update();
    }
    public virtual void UseMana()
    {
        mana--;
        ManaBar.transform.localScale = new Vector3((float)mana/(float)maxMana, ManaBar.transform.localScale.y, ManaBar.transform.localScale.z);
    }
    public virtual void ResetMana()
    {
        mana = maxMana;
        ManaBar.transform.localScale = new Vector3((float)mana/(float)maxMana, ManaBar.transform.localScale.y, ManaBar.transform.localScale.z);
    }
    public virtual int AddPoints(int addedPoints)
    {
        points += addedPoints;
        PointsTxt.text = "" + points;
        PointsWheel.transform.localScale = new Vector3((float)points / (float)pointsToWin, (float)points / (float)pointsToWin, PointsWheel.transform.localScale.z);
        return points;    
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
    }
    public virtual void WinRound()
    {
        EndRound();
    }
    public virtual void LoseRound()
    {
        EndRound();
    }
}
