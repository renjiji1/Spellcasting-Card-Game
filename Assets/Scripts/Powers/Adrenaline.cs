using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Adrenaline : Power
{
    public static int manaLossOnLose = 1;
    public static int manaLossOnWin = 2;
    public override void OnSelect()
    {
        base.OnSelect();
        agent.adrenalineActive = true;
        agent.manaLossOnLose = manaLossOnLose;
        agent.manaLossOnWin = manaLossOnWin;
    }  
}
