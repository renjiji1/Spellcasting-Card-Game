using UnityEngine;
using System.Collections.Generic;
using System;

public class Player : Agent
{
    [NonSerialized] public bool waitForDuelReadyUp = false;
    [NonSerialized] public bool readyForDuel = false;
    protected override void Start()
    {
        base.Start();
    }

    protected override void Update()
    {
        base.Update();

    }
}
