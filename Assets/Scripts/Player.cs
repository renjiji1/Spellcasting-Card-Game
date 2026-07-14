using UnityEngine;
using System.Collections.Generic;
using System;

public class Player : Agent
{
    public GameObject CardMovePreview;
    [NonSerialized] public bool waitForDuelReadyUp = false;
    [NonSerialized] public bool readyForDuel = false;
    [NonSerialized] public Card highlightedCard;
    [NonSerialized] public Card selectedCard;
    [NonSerialized] public CardSlot highlightedCardSlot;
    public override void Start()
    {
        base.Start();
    }

    protected override void Update()
    {
        base.Update();
        if(isAgentTurn)
        {
            foreach(Card card in HandOfCards)
            {
                if(!card.hasBeenPlayed && !card.isBeingPlayed)
                {
                    card.OnHoverOverCard();
                } 
            }
        }
        
    }
    void LateUpdate()
    {
        
    }
    
}
