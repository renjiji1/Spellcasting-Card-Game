using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Patience : Power
{
    public override void OnSelect()
    {
        if(gameManager.agentForcePatience == null)
        {
            base.OnSelect();
            gameManager.agentForcePatience = agent == player ? AIEnemy : player;
        } else
        {
            StartCoroutine(ShowCantUsePowerTxt("Opponent Already Used Patience"));
        }
        
    }  
}
