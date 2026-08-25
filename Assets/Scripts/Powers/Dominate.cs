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
        base.OnSelect();
        agent.dominateActive = true;
    }  
}
