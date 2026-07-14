using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Debug = UnityEngine.Debug;
using Random = UnityEngine.Random;
using Object = UnityEngine.Object;
using NaughtyAttributes;

public class AI : Agent
{
    [Header("AI")]
    [SerializeField] protected float waitToPlayCard = 1f;
    CardSlot[] CardSlots;
    CardSlot PrimalSlot;
    CardSlot DivineSlot;
    CardSlot ArcaneSlot;
    
    public override void Start()
    {
        base.Start();
        foreach(Transform child in gameManager.AllCardSlots.transform)
        {
            CardSlot slot = child.GetComponent<CardSlot>();
            if(slot.isPlayerSlot)
            {
                continue;
            }
            switch(slot.source)
            {
                case MagicSource.Primal:
                    PrimalSlot = slot;
                    break;
                case MagicSource.Divine:
                    DivineSlot = slot;
                    break;
                case MagicSource.Arcane:
                    ArcaneSlot = slot;
                    break;
            }
        }
        CardSlots = new CardSlot[] {PrimalSlot, DivineSlot, ArcaneSlot};
    }

    protected override void Update()
    {
        base.Update();
    }
    public override void StartTurn()
    {
        base.StartTurn();
        Card cardToPlay = HandOfCards[Random.Range(0, HandOfCards.Count)];
        CardSlot slotToPlay = CardSlots[Random.Range(0, CardSlots.Length)];
        StartCoroutine(PlayCardAfterDelay(cardToPlay, slotToPlay));
    }
    IEnumerator PlayCardAfterDelay(Card card, CardSlot slot)
    {
        yield return new WaitForSeconds(waitToPlayCard);
        UseCard(card, slot);
    }
}