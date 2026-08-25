using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Envigorate : Power
{
    public override void OnSelect()
    {
        base.OnSelect();
        agent.envigorateActive = true;
    }  
}
