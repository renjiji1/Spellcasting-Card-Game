using UnityEngine;
using System.Collections.Generic;

public class Agent : Entity
{
    [SerializeField] protected int turnIndx = 0; // 0 for player, 1 for enemy
    protected int totalDamage = 0;
    protected int currentDamage = 0;
    [SerializeField] protected const int maxMana = 10;
    protected int mana = maxMana;
    protected List<GameObject> Hand = new List<GameObject>();
    protected override void Start()
    {
        base.Start();
    }
    protected override void Update()
    {
        base.Update();
    }
}
