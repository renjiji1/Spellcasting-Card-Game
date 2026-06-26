using UnityEngine;
using System.Collections.Generic;
using System;
using TMPro;

public enum MagicType {Illusion, Abjuration, Evocation};
public enum MagicSource {Primal, Divine, Arcane};
public class Card : Entity
{
    [Header("Card")]
    [SerializeField] Sprite Image;
    [SerializeField] public int denomination = 1;
    [Header("Card Type")]
    [SerializeField] public MagicType type;
    [SerializeField] Sprite illusionIcon;
    [SerializeField] Sprite abjurationIcon;
    [SerializeField] Sprite evocationIcon;
    [Header("Card Source")]
    [SerializeField] public MagicSource source;
    [SerializeField] Sprite primalIcon;
    [SerializeField] Sprite divineIcon;
    [SerializeField] Sprite arcaneIcon;

    [Header("Shuffle")]
    [SerializeField] float enterShuffleAnimSpeed = 10;
    protected bool shuffle = false;
    [SerializeField] float enterShufflePosXOffset = 10;
    [SerializeField] float exitShuffleAnimSpeed = 10;

    [Header("Move")]
    bool isMoving = false;
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
        base.Start();
        switch(type)
        {
            case MagicType.Illusion:
                transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = illusionIcon;
                break;
            case MagicType.Abjuration:
                transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = abjurationIcon;
                break;
            case MagicType.Evocation:
                transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = illusionIcon;
                break;
        }
        switch(source)
        {
            case MagicSource.Divine:
                transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = divineIcon;
                break;
            case MagicSource.Primal:
                transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = primalIcon;
                break;
            case MagicSource.Arcane:
                transform.Find("CardAnimPivot/Front/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite = arcaneIcon;
                break;
        }
        transform.Find("CardAnimPivot/Front/Background").GetComponent<SpriteRenderer>().sprite = Image;
        transform.Find("CardAnimPivot/Front/Deonomination").GetComponent<TMP_Text>().text = "" + denomination;
    }

    protected override void Update()
    {
        base.Update();
        Move();
    }
    public virtual void ExitShuffle(Vector3 pos)
    {
        GameObject shuffleRotAxis = gameManager.Deck.transform.Find("ShuffleRotationAxis").gameObject;
        Quaternion deckCardRot = Quaternion.Euler(90, 0, 0);
        StartMoving(pos, deckCardRot, enterShuffleAnimSpeed, () =>
        {
            transform.parent = gameManager.Deck.transform;
            shuffle = false;
        });
    }
    public virtual void BeginShuffle()
    {
        GameObject shuffleRotAxis = gameManager.Deck.transform.Find("ShuffleRotationAxis").gameObject;
        Quaternion backTurnedRot = Quaternion.Euler(0, -180, 0);
        Vector3 aroundShuffleAxis = new Vector3(shuffleRotAxis.transform.position.x + enterShuffleAnimSpeed, shuffleRotAxis.transform.position.y, shuffleRotAxis.transform.position.z);
        StartMoving(aroundShuffleAxis, backTurnedRot, enterShuffleAnimSpeed, () =>
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
            transform.rotation = Quaternion.Lerp(moveInitialRot, moveTargetRot, moveTimer);
            transform.position = Vector3.Lerp(moveInitialPos, moveTargetPos, moveTimer);
        } else if(isMoving)
        {
            isMoving = false;
            moveTimer = 0;
            OnMoveFinished?.Invoke();
        }
    }
    public void StartMoving(Vector3 pos, Quaternion rot, float speed = moveSpeed, Action fn = null)
    {
        moveInitialRot = transform.rotation;
        moveInitialPos = transform.position;
        moveTargetPos = pos;
        moveTargetRot = rot;
        OnMoveFinished = fn;
        isMoving = true;
    }
}