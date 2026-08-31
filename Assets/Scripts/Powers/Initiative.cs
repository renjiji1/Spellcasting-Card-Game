using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Initiative : Power
{
    public override void OnSelect()
    {
        if(gameManager.agentForceInitiative == null)
        {
            base.OnSelect();
            gameManager.agentForceInitiative = agent == player ? AIEnemy : player;
        } else
        {
            StartCoroutine(ShowCantUsePowerTxt("Opponent Already Used Patience"));
        }
        
    }  
}
