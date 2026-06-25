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
    float enterShuffleTimer = 0;
    [SerializeField] float enterShufflePosXOffset = 10;
    Quaternion rotBeforeShuffle;
    Vector3 posBeforeShuffle;

    bool exitShuffle = false;
    Quaternion rotBeforeExitShuffle;
    Vector3 posBeforeExitShuffle;
    [SerializeField] float exitShuffleAnimSpeed = 10;
    Vector3 afterShufflePos;
    float exitShuffleTimer = 0;

    float moveTimer = 0;
    Vector3 moveInitialPos;
    Quaternion moveInitialRot;
    [SerializeField] const float moveSpeed = 8;

    
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
        Shuffle();
    }
    protected void Shuffle()
    {
        if(shuffle)
        {
            GameObject shuffleRotAxis = gameManager.Deck.transform.Find("ShuffleRotationAxis").gameObject;

            Quaternion backTurnedRot = Quaternion.Euler(0, -180, 0);
            Vector3 aroundShuffleAxis = new Vector3(posBeforeShuffle.x + enterShuffleAnimSpeed, shuffleRotAxis.transform.position.y, shuffleRotAxis.transform.position.z);
            if(!Move(aroundShuffleAxis, backTurnedRot, enterShuffleAnimSpeed))
            {
                transform.parent = shuffleRotAxis.transform;
            }
            if(exitShuffle)
            {
                Quaternion deckCardRot = Quaternion.Euler(90, 0, 0);
                if(!Move(afterShufflePos, deckCardRot, exitShuffleAnimSpeed))
                {
                    transform.parent = gameManager.Deck.transform;
                    shuffle = false;
                    exitShuffle = false;
                }
            }
        }
    }
    public virtual void ExitShuffle(Vector3 pos)
    {
        moveInitialRot = transform.rotation;
        moveInitialPos = transform.position;
        afterShufflePos = pos;
        exitShuffle = true;
    }
    public virtual void BeginShuffle()
    {
        moveInitialRot = transform.rotation;
        moveInitialPos = transform.position;
        shuffle = true;
    }
    // returns true if moving, false if not
    public bool Move(Vector3 pos, Quaternion rot, float speed = moveSpeed)
    {
        if(moveTimer < 1)
        {
            moveTimer += Time.deltaTime * speed;
            transform.rotation = Quaternion.Lerp(moveInitialRot, rot, moveTimer);
            transform.position = Vector3.Lerp(moveInitialPos, pos, moveTimer);
            return true;
        }
        return false;
    }
}