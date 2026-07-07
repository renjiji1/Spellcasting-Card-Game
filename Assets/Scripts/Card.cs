using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using System;
using TMPro;

public enum MagicType {Illusion, Abjuration, Evocation};
public class Card : Entity
{
    GameObject cardAnimPivot;
    InputAction selectInput;
    [Header("Card")]
    [SerializeField] Sprite Image;
    [SerializeField] public int denomination = 1;
    [NonSerialized] public bool isBeingPlayed = false;
    [Header("Card Type")]
    [SerializeField] public MagicType type;
    [SerializeField] Sprite illusionIcon;
    [SerializeField] Sprite abjurationIcon;
    [SerializeField] Sprite evocationIcon;
    
    protected bool shuffle = false;

    [Header("Move")]
    [SerializeField] float selectMoveMultiplier = 3;
    [NonSerialized] public Transform HandTransform;
    bool isMoving = false;
    Vector3 highlightMoveOffset = new Vector3(0, .1f, .05f);
    [SerializeField] const float moveSpeed = 8;
    float moveTimer = 0;
    Vector3 moveInitialPos;
    Quaternion moveInitialRot;
    Vector3 moveTargetPos;
    Quaternion moveTargetRot;
    float currentSpeed = 0;
    Action OnMoveFinished;

    protected override void Start()
    {
        if(startHasRan) return;
        base.Start();
        cardAnimPivot = transform.Find("CardAnimPivot").gameObject;
        selectInput = InputSystem.actions.FindAction("Select");
        InitializeCard(gameObject, type, denomination, Image);
    }
    public void InitializeCard(GameObject obj, MagicType type, int denomination, Sprite image)
    {
        switch(type)
        {
            case MagicType.Illusion:
                obj.transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = illusionIcon;
                break;
            case MagicType.Abjuration:
                obj.transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = abjurationIcon;
                break;
            case MagicType.Evocation:
                obj.transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = evocationIcon;
                break;
        }
        obj.transform.Find("CardAnimPivot/Front/Background").GetComponent<SpriteRenderer>().sprite = image;
        obj.transform.Find("CardAnimPivot/Front/Deonomination").GetComponent<TMP_Text>().text = "" + denomination;
    }

    protected override void Update()
    {
        base.Update();
        Move();
    }
    public virtual void ExitShuffle(Vector3 pos, float speed)
    {
        GameObject shuffleRotAxis = GameManager.instance.Deck.transform.Find("ShuffleRotationAxis").gameObject;
        Quaternion deckCardRot = Quaternion.Euler(-90, 0, 180);
        StartMoving(pos, deckCardRot, speed, () =>
        {
            transform.parent = GameManager.instance.Deck.transform;
            transform.rotation = Quaternion.Euler(Vector3.zero);
            cardAnimPivot.transform.rotation = deckCardRot;
            shuffle = false;
        });
    }
    public virtual void BeginShuffle(float xOffset, float speed)
    {
        GameObject shuffleRotAxis = GameManager.instance.Deck.transform.Find("ShuffleRotationAxis").gameObject;
        Quaternion backTurnedRot = Quaternion.Euler(0, 0, 0);
        Vector3 aroundShuffleAxis = new Vector3(shuffleRotAxis.transform.position.x + xOffset, shuffleRotAxis.transform.position.y, shuffleRotAxis.transform.position.z);
        StartMoving(aroundShuffleAxis, backTurnedRot, speed, () =>
        {
            transform.parent = shuffleRotAxis.transform;
        });
        shuffle = true;
    }
    void Move()
    { 
        if(isMoving && moveTimer < 1)
        {
            isMoving = true;
            moveTimer += Time.deltaTime * currentSpeed;
            cardAnimPivot.transform.localRotation = Quaternion.Lerp(moveInitialRot, moveTargetRot, moveTimer);
            transform.position = Vector3.Lerp(moveInitialPos, moveTargetPos, moveTimer);
        } else if(isMoving)
        {
            isMoving = false;
            moveTimer = 0;
            OnMoveFinished?.Invoke();
        }
    }
    public void StartMoving(Vector3 pos, Quaternion? rot = null, float speed = moveSpeed, Action fn = null)
    {
        moveInitialRot = transform.Find("CardAnimPivot").transform.localRotation;
        moveInitialPos = transform.position;
        currentSpeed = speed;
        moveTargetPos = pos;
        moveTargetRot = rot ?? moveInitialRot;
        OnMoveFinished = fn;
        moveTimer = 0;
        isMoving = true;
    }
    public void OnHoverOverCard()
    {
        if(player.selectedCard != null)
        {
            if(player.selectedCard.isBeingPlayed)
            {
                return;
            }
        }
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if(Physics.Raycast(ray, out hit))
        {
            if(hit.collider == cardAnimPivot.GetComponent<Collider>())
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
                    OnSelect(); 
                } 
                
            } else if(player.highlightedCard == this)
            {
                OnHoverExit();
            }
        }
    }
    void OnHoverEnter()
    {
        player.highlightedCard = this;
        StartMoving(HandTransform.position + highlightMoveOffset, HandTransform.rotation);
    }
    public void OnHoverExit()
    {
        player.highlightedCard = null;
        StartMoving(HandTransform.position, HandTransform.rotation);
    }
    void OnSelect()
    {
        player.selectedCard = this;
        transform.Find("CardAnimPivot/Front/HighlightBg").gameObject.SetActive(true);
        InitializeCard(player.CardMovePreview, type, denomination, Image);
        /*Vector3 screenPos = Input.mousePosition;
        screenPos.z = 1;
        Vector3 worldPos = Camera.main.ScreenToWorldPoint(screenPos);
        worldPos.z = (worldPos.y - HandTransform.position.y) * selectMoveMultiplier + HandTransform.position.z + highlightMoveOffset.z;
        worldPos.y = (HandTransform.position.z - worldPos.y) / selectMoveMultiplier + HandTransform.position.y + highlightMoveOffset.y;
        //worldPos.x = (HandTransform.position.x + highlightMoveOffset.x) + (worldPos.x - HandTransform.position.x - highlightMoveOffset.x) * -(screenPos.z/worldPos.z) * .7f;
        transform.position = worldPos;
        //transform.Translate(/*new Vector3(worldPos.x * -Vector3.forward.x, worldPos.y * -Vector3.forward.y, worldPos.z * -Vector3.forward.z)worldPos, Space.World);*/
    }
    public void OnDeselect()
    {
        player.selectedCard = null;
        transform.Find("CardAnimPivot/Front/HighlightBg").gameObject.SetActive(false);
    }
}