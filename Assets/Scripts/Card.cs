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
    }
}