using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Reverso : Power
{
    public override void OnSelect()
    {
        base.OnSelect();
        gameManager.reversoActive = !gameManager.reversoActive;
    }  
}
