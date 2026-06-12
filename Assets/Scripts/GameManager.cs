using UnityEngine;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;

public class GameManager : MonoBehaviour
{
    [NonSerialized] public bool paused = false;
    Player[] players;
    AI[] AIs;
    [NonSerialized] public int round = 0;
    [NonSerialized] public int turn = 0; // 0 for player, 1 for enemy
    public const int maxDuels = 10;
    [NonSerialized] public int currentDuelNum = 0;
    [SerializeField] float duelReadyUpTime = 5f;
    float duelReadyUpTimer = 0;
    [NonSerialized] public List<GameObject> Deck = new List<GameObject>();
    void Start()
    {
        players = Object.FindObjectsByType<Player>(FindObjectsSortMode.None);
        AIs = Object.FindObjectsByType<AI>(FindObjectsSortMode.None);
    }

    public void EndTurn()
    {
        turn = (turn + 1) % 2;
        if (turn == 0)
        {
            currentDuelNum++;
            StartDuelCountdown();
        }
        
        if(currentDuelNum > maxDuels)
        {
            EndRound();
        }
    }
    void StartDuelCountdown()
    {
        duelReadyUpTimer = duelReadyUpTime;
        foreach (Player player in players)
        {
            player.waitForDuelReadyUp = true;
        }
    }
    void StartDuel()
    {
        // Logic to start a duel between the player and the AI
    }
    void EndRound()
    {
        round++;
        turn = 0;
        currentDuelNum = 0;
    }
    void Update()
    {
        bool allPlayersReady = true;
        if(duelReadyUpTimer > 0)
        {
            duelReadyUpTimer -= Time.deltaTime;
            foreach (Player player in players)
            {
                if (!player.readyForDuel) 
                {
                    allPlayersReady = false;
                    break;
                }
            }
        }
        
        if(duelReadyUpTimer <= 0 || allPlayersReady)        {
            StartDuel();
        }
        
    }
}
