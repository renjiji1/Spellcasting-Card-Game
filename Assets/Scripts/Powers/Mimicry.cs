using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Mimicry : Power
{
    public override void OnSelect()
    {
        if(gameManager.turn == 0)
        {
            base.OnSelect();
            gameManager.mimicryActive = true;
            if(agent == AIEnemy)
            {
                StartCoroutine(ActivateMimcryTxt());
            }
        } else
        {
            StartCoroutine(ShowCantUsePowerTxt("Can Only Use When Leading"));
        }
        
    }
    IEnumerator ActivateMimcryTxt()
    {
        yield return new WaitUntil(() => gameManager.currentPlayer.GetComponent<Agent>() != agent);
        gameManager.MimicryTxt.SetActive(true);
        yield return new WaitUntil(() => gameManager.currentPlayer.GetComponent<Agent>().cardOnSlot);
        
        gameManager.MimicryTxt.SetActive(false);
    }  
}
