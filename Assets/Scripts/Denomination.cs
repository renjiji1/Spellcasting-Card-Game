using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using NaughtyAttributes;
using System;
using TMPro;

public class Denomination : MonoBehaviour
{
    [NonSerialized] public int adder = 0;
    [SerializeField] public bool PositionInFrontOfCam = false;
    [SerializeField] SFX denominationAddSFX;
    [SerializeField] float consecutiveSFXPitchIncrease = .5f;
    [ShowIf("PositionInFrontOfCam")]
    [SerializeField] float distFromCam = 2;
    [ShowIf("PositionInFrontOfCam")]
    [SerializeField] Vector2 offset = Vector2.zero;
    void Start()
    {
        GameManager.CardClashFinished.AddListener(() =>
        {
            denominationAddSFX.pitch = 1;
        });
    }
    public void AddToDenomination()
    {
        GetComponent<TMP_Text>().text = "" + (int.Parse(GetComponent<TMP_Text>().text) + adder);
        adder = 0;
        SoundManager.instance.Play(denominationAddSFX);
        denominationAddSFX.pitch += consecutiveSFXPitchIncrease;
        Debug.Log(denominationAddSFX.pitch - .5f);
    }
    void LateUpdate()
    {
        if(PositionInFrontOfCam)
        {
            transform.position = Camera.main.transform.position + Camera.main.transform.forward * distFromCam + Camera.main.transform.right * offset.x + Camera.main.transform.up * offset.y;
            transform.rotation = Camera.main.transform.rotation;
        }
    }
}