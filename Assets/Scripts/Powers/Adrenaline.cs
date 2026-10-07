using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Surge : Power
{
    public static int manaLossOnLose = 1;
    public static int manaLossOnWin = 1;
    public override void OnSelect()
    {
        if(gameManager.turn == 0)
        {
            base.OnSelect();
            agent.surgeActive = true;
            agent.manaLossOnLose = manaLossOnLose;
            agent.manaLossOnWin = manaLossOnWin;
        } else
        {
            StartCoroutine(ShowCantUsePowerTxt("Can Only Use When Leading"));
        }
    }  
}
