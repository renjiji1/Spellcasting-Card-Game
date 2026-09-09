using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using System;
using TMPro;
using Unity.VisualScripting;

public enum MagicType {Illusion, Abjuration, Evocation};
public class Card : Entity
{
    InputAction selectInput;
    [Header("Card")]
    [SerializeField] Sprite Image;
    [SerializeField] public int denomination = 1;
    [NonSerialized] public bool isBeingPlayed = false;
    [NonSerialized] public bool hasBeenPlayed = false;
    [NonSerialized] public bool isBeingSwapped = false;
    [Header("Card Type")]
    [SerializeField] public MagicType type;
    [SerializeField] Sprite illusionIcon;
    [SerializeField] Sprite abjurationIcon;
    [SerializeField] Sprite evocationIcon;
    [NonSerialized] public string frontPath = "CardRotPivot/CardAnimPivot/Front";
    protected bool shuffle = false;

    [Header("Move")]
    [SerializeField] float selectMoveMultiplier = 3;
    [NonSerialized] public Transform HandTransform;
    [NonSerialized] public Vector3 ogHandPos; 
    Vector3 highlightMoveOffset = new Vector3(0, .1f, .05f);
    [Header("Words")]
    [SerializeField] SFX DivineWord;
    [SerializeField] SFX PrimalWord;
    [SerializeField] SFX OccultWord;

    public override void Start()
    {
        if(startHasRan) return;
        base.Start();
        selectInput = InputSystem.actions.FindAction("Select");
        InitializeCard(gameObject, type, denomination, Image);
    }
    public void InitializeCard(GameObject obj, MagicType type, int denomination, Sprite image)
    {
        switch(type)
        {
            case MagicType.Illusion:
                obj.transform.Find($"{frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = illusionIcon;
                break;
            case MagicType.Abjuration:
                obj.transform.Find($"{frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = abjurationIcon;
                break;
            case MagicType.Evocation:
                obj.transform.Find($"{frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = evocationIcon;
                break;
        }
        obj.transform.Find($"{frontPath}/Background").GetComponent<SpriteRenderer>().sprite = image;
        obj.transform.Find($"{frontPath}/Denomination").GetComponent<TMP_Text>().text = "" + denomination;
    }

    protected override void Update()
    {
        base.Update();
    }
    public void ActivateCard()
    {
        isBeingPlayed = false;
        hasBeenPlayed = false;
    }
    public virtual void ExitShuffle(Vector3 pos, float speed, Action fn = null)
    {
        GameObject shuffleRotAxis = GameManager.instance.Deck.transform.Find("ShuffleRotationAxis").gameObject;
        Quaternion deckCardRot = Quaternion.Euler(-90, 0, 180);
        StartMoving(pos, deckCardRot, speed, () =>
        {
            transform.rotation = Quaternion.Euler(Vector3.zero);
            moveRotPivot.transform.rotation = deckCardRot;
            shuffle = false;
            fn?.Invoke();
        });
    }
    public virtual void BeginShuffle(float xOffset, float speed, Action fn = null)
    {
        GameObject shuffleRotAxis = GameManager.instance.Deck.transform.Find("ShuffleRotationAxis").gameObject;
        Quaternion backTurnedRot = Quaternion.Euler(0, 0, 0);
        Vector3 aroundShuffleAxis = new Vector3(shuffleRotAxis.transform.position.x + xOffset, shuffleRotAxis.transform.position.y, shuffleRotAxis.transform.position.z);
        StartMoving(aroundShuffleAxis, backTurnedRot,  speed, () =>
        {
            transform.parent = shuffleRotAxis.transform;
            moveRotPivot.transform.rotation = backTurnedRot;
            fn?.Invoke();
        }, playSFX: true);
        shuffle = true;
    }
    
    public void OnHoverOverCard()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if(Physics.Raycast(ray, out hit))
        {
            if(hit.collider == moveRotPivot.GetComponent<Collider>())
            {
                if(player.highlightedCard != this)
                {
                    if(player.highlightedCard != null)
                    {
                        player.highlightedCard.OnHoverExit();
                    }
                    OnHoverEnter();
                }
                if (selectInput.WasPressedThisFrame())
                {
                    if(player.selectedCard != this && player.selectedCard != null)
                    {
                        player.selectedCard.OnDeselect();
                    }
                    player.UseCardForPower(this);
                    if(!player.powerActiveCantPlayCard)
                    {
                        OnSelect();
                    }
                } 
                
            } else if(player.highlightedCard == this && player.selectedCard != this)
            {
                OnHoverExit();
            }
        }
    }
    void OnHoverEnter()
    {
        if(!isBeingSwapped && player.ContainsCard(this)) {
            player.highlightedCard = this;
            StartMoving(HandTransform.position + highlightMoveOffset, HandTransform.rotation);
        } 
    }
    public void OnHoverExit()
    {
        if(!hasBeenPlayed && !isBeingPlayed && !isBeingSwapped && player.ContainsCard(this))
        {
            if(player.highlightedCard == this)
            {
                player.highlightedCard = null;
            }
            StartMoving(HandTransform.position, HandTransform.rotation);
        }
    }
    void OnSelect()
    {
        player.selectedCard = this;
        transform.Find($"{frontPath}/HighlightBg").gameObject.SetActive(true);
        InitializeCard(player.CardMovePreview, type, denomination, Image);
    }
    public void OnDeselect()
    {
        player.selectedCard = null;
        transform.Find($"{frontPath}/HighlightBg").gameObject.SetActive(false);
    }
    public SFX GetArcaneWordFromSource(MagicSource source)
    {
        switch(source)
        {
            case MagicSource.Arcane:
                return OccultWord;
            case MagicSource.Primal:
                return PrimalWord;
            case MagicSource.Divine:
                return DivineWord;
        }
        return null;
    }
}