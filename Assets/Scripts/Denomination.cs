using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using System;
using TMPro;

public class Denomination : MonoBehaviour
{
    [NonSerialized] public int adder = 1;
    public void AddToDenomination()
    {
        GetComponent<TMP_Text>().text = "" + (int.Parse(GetComponent<TMP_Text>().text) + adder);
    }

}