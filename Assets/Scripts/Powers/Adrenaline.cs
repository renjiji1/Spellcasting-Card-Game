using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Adrenaline : Power
{
    public override void OnSelect()
    {
        base.OnSelect();
        agent.adrenalineActive = true;
    }  
}
