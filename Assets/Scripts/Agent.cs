using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using UnityEngine.Events;
using System;
using TMPro;

public class Agent : Entity
{
    [Header("Agent")]
    protected InputAction selectInput;
    [NonSerialized] public UnityEvent<int> OnArcanaChanged = new UnityEvent<int>();
    [NonSerialized] public bool isAgentTurn = false;
    [NonSerialized] public bool powerActiveCantPlayCard = false;
    [NonSerialized] public bool canRedraw = false;
    [NonSerialized] public bool canSupremeCardSwap = false;
    [NonSerialized] public bool envigorateActive = false;
    [NonSerialized] public bool adrenalineActive = false;
    [NonSerialized] public int points = 0;
    [SerializeField] public int pointsToWin = 55;
    [SerializeField] public int maxMana = 10;
    [NonSerialized] public int mana;
    [NonSerialized] public int manaLossOnLose = 0;
    [NonSerialized] public int manaLossOnWin = 1;
    protected int level = 0;
    [NonSerialized] public bool cardOnSlot = false;
    [NonSerialized] public int roundWins = 0;
    [SerializeField] protected float useCardSpeed = 5;
    [NonSerialized] public List<Card> HandOfCards = new List<Card>();
    [NonSerialized] public List<Card> WonCards = new List<Card>();
    public GameObject Hand;
    [NonSerialized] public Card cardBeingPlayed;
    [NonSerialized] public CardSlot cardSlotBeingPlayed;

    [SerializeField] GameObject ManaCrystalFill;
    [SerializeField] GameObject DamageSlider;
    [SerializeField] public TMP_Text DamageNumTxt;
    [SerializeField] protected Transform PowersTransform;
    [SerializeField] protected TMP_Text ManaTxt;
    [NonSerialized] public List<Power> powers = new List<Power>();
    [SerializeField] protected GameObject AddedArcanaTxt;
    [SerializeField] protected TMP_Text ArcanaBagTxt;
    [SerializeField] float AddedArcanaTxtYOffset = .5f;
    [SerializeField] protected int arcana = 0;
    protected bool cardMatchesSupremeSource = false;
    [NonSerialized] public bool hasUsedPowerThisTurn = false;
    public override void Start()
    {
        base.Start();
        mana = maxMana;
        ResetMana();
        DamageNumTxt.text = "" + points;
        DamageSlider.GetComponent<SpriteRenderer>().size = new Vector2(Mathf.Clamp((float)points/(float)pointsToWin, .05f, 1), DamageSlider.GetComponent<SpriteRenderer>().size.y);
        ArcanaBagTxt.text = "" + arcana;
        selectInput = InputSystem.actions.FindAction("Select");
        OnArcanaChanged.Invoke(arcana);
    }
    public bool SpendArcana(int amount)
    {
        if(arcana >= amount)
        {
            arcana -= amount;
            OnArcanaChanged.Invoke(arcana);
            return true;
        }
        return false;
    }
    protected override void Update()
    {
        base.Update();
    }
    public virtual void UseMana(bool win = true)
    {
        if(!envigorateActive)
        {
            int manaSubtracter = win ? manaLossOnWin : manaLossOnLose;
            mana = Mathf.Clamp(mana - manaSubtracter, 0, maxMana);
            ManaTxt.text = "" + mana;
            ManaCrystalFill.transform.localScale = new Vector3((float)mana/(float)maxMana, (float)mana/(float)maxMana, ManaCrystalFill.transform.localScale.z);
        }
        adrenalineActive = false;
        envigorateActive = false;
        manaLossOnLose = 0;
        manaLossOnWin = 1;
    }
    public virtual void ResetMana()
    {
        mana = maxMana;
        ManaTxt.text = "" + mana;
        ManaCrystalFill.transform.localScale = new Vector3((float)mana/(float)maxMana, (float)mana/(float)maxMana, ManaCrystalFill.transform.localScale.z);
    }
    public virtual int AddPoints(int addedPoints)
    {
        points += addedPoints;
        DamageNumTxt.text =$"{points}/{pointsToWin}";
        DamageSlider.GetComponent<SpriteRenderer>().size = new Vector2(Mathf.Clamp((float)points/(float)pointsToWin, .05f, 1), DamageSlider.GetComponent<SpriteRenderer>().size.y);
        return points;    
    }
    public virtual void AddCard(Card card)
    {
        HandOfCards.Add(card);
    }
    public virtual void RemoveCard(Card card)
    {
        HandOfCards.Remove(card);
    }
    public bool ContainsCard(Card card) {return HandOfCards.Contains(card);}
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
        foreach(Transform power in PowersTransform)
        {
            power.GetComponent<Power>().hasBeenUsedThisTurn = false;
        }
    }
    public virtual void EndTurn()
    {
        isAgentTurn = false;
        cardOnSlot = false;
        hasUsedPowerThisTurn = false;
        if(player.highlightedPower)
        {
            player.highlightedPower.OnHoverExit();
        }
        gameManager.EndTurn();
    }
    public virtual void UseCard(Card card, CardSlot slot, Action fn = null)
    {
        cardMatchesSupremeSource = true;//gameManager.SupremeSource == slot.source;
        cardBeingPlayed = card;
        cardSlotBeingPlayed = slot;
        card.OnDeselect();
        card.isBeingPlayed = true;
        card.GetComponent<Animator>().SetBool("UseCard", true);
        card.GetComponent<Animator>().speed = card.GetAnimLengthByName("UseCard") / card.GetTotalMoveTime(useCardSpeed);
        card.StartMoving(slot.transform.position + new Vector3(0, slot.cardOnSlotYOffset,0), slot.transform.rotation, speed: useCardSpeed, fn: () =>
        {
            fn?.Invoke();
            card.GetComponent<Animator>().SetBool("UseCard", false);
            RemoveCard(card);
            cardOnSlot = true;
        });
    }
    public virtual bool UseCardForPower(Card selectedCard)
    {
        if(powerActiveCantPlayCard)
        {
            if(canRedraw)
            {
                canRedraw = false;
                StartCoroutine(PowersTransform.Find("Redraw").GetComponent<Redraw>().RedrawCard(selectedCard, this));
            } else if(canSupremeCardSwap)
            {
                canSupremeCardSwap = false;
                StartCoroutine(PowersTransform.Find("SupremeSwap").GetComponent<SupremeSwap>().SupremeSwapCard(selectedCard, this, selectedCard.transform.position, selectedCard.moveRotPivot.transform.localRotation));
            } 
            return false;
        } else
        {
            return true;
        }
    }
    public virtual IEnumerator AddArcana(Action finishedFn = null)
    { 
        if(cardMatchesSupremeSource)
        {
            AddedArcanaTxt.transform.position = cardSlotBeingPlayed.transform.position + new Vector3(0,AddedArcanaTxtYOffset,0);
            AddedArcanaTxt.SetActive(true);
            arcana++;
            OnArcanaChanged.Invoke(arcana);
            ArcanaBagTxt.text = "" + arcana;
            float arcanaTxtAnimLength = GetAnimLengthByName("AddedArcana", AddedArcanaTxt.transform.GetChild(0).gameObject.GetComponent<Animator>());
            yield return new WaitForSeconds(arcanaTxtAnimLength);
            AddedArcanaTxt.SetActive(false);
        } else
        {
            finishedFn?.Invoke();
        }
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
