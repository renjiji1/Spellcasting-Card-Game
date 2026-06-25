using UnityEngine;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;
using TMPro;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    [SerializeField] public GameObject Deck;
    [SerializeField] GameObject RoundTxt;
    [NonSerialized] public bool paused = false;
    [SerializeField] Player player;
    [SerializeField] AI AIPlayer;
    [NonSerialized] public int round = 0;
    [SerializeField] int roundWinsToWin = 3;
    [NonSerialized] public int turn = 0; // 0 for player, 1 for enemy
    public const int maxDuels = 10;
    [NonSerialized] public int currentDuelNum = 0;
    void Awake()
    {
        instance = this;
    }
    void Start()
    {
        StartRound();
    }

    public void EndTurn()
    {
        turn = (turn + 1) % 2;
        if (turn == 0)
        {
            currentDuelNum++;
            StartDuel();
        }
        
        if(currentDuelNum > maxDuels)
        {
            EndRound();
        }
    }

    void StartDuel()
    {
        // Logic to start a duel between the player and the AI
    }
    void StartRound()
    {
        Deck.GetComponent<Deck>().RunStart();
        Deck.GetComponent<Deck>().StartShuffle();
    }
    void EndRound()
    {
        round++;
        turn = 0;
        currentDuelNum = 0;
        if(player.roundWins >= 3)
        {
            Win();
            return;
        }
        if(AIPlayer.roundWins >= 3)
        {
            Lose();
            return;
        }
        StartRound();
    }
    void Win() {}
    void Lose() {}
    

    void Update()
    {
        
    }
}
