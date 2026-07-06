using UnityEngine;
using System.Collections.Generic;
using System;

public class Agent : Entity
{
    [SerializeField] protected int turnIndx = 0; // 0 for player, 1 for enemy
    protected int totalDamage = 0;
    protected int currentDamage = 0;
    [SerializeField] protected const int maxMana = 10;
    protected int mana = maxMana;
    [NonSerialized] public int roundWins = 0;
    protected List<Card> HandOfCards = new List<Card>();
    public GameObject Hand;
    protected override void Start()
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
    public virtual void StartTurn()
    {
        
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
