using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Dominate : Power
{
    public override void OnSelect()
    {
        if(gameManager.agentDominate == null)
        {
            base.OnSelect();
            gameManager.agentDominate = agent;
        } else
        {
            StartCoroutine(ShowCantUsePowerTxt("Opponent Already Used Patience"));
        }
    }  
}
