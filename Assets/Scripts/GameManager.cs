using UnityEngine;
using System.Collections;
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
    [SerializeField] public Player player;
    [SerializeField] public AI AIEnemy;
    [NonSerialized] public int round = 1;
    [SerializeField] int roundWinsToWin = 3;
    [NonSerialized] public int turn = 0; // number of turns that happened in the current duel
    [NonSerialized] public GameObject currentPlayer; // the player whose turn it is
    [NonSerialized] public Card SupremeCard;
    [SerializeField] Transform SupremeCardSpawnPoint;
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
        turn++;
        currentPlayer = currentPlayer == player.gameObject ? AIEnemy.gameObject : player.gameObject;
        if (turn > 1)
        {
            currentDuelNum++;
            turn = 0;
            if(currentDuelNum > maxDuels)
            {
                EndRound();
                return;
            }
            StartDuel();
        }
        currentPlayer.GetComponent<Agent>().StartTurn();
    }

    void StartDuel()
    {
        
    }
    void StartRound()
    {
        Deck.GetComponent<Deck>().RunStart();
        StartCoroutine(Deck.GetComponent<Deck>().StartShuffle());
        RoundTxt.GetComponent<TMP_Text>().text = "Round " + round;
        RoundTxt.SetActive(true);
        StartCoroutine(DeactivateRoundTxt());
        StartCoroutine(ChooseNewSupremeCard());
        StartDuel();
    }
    IEnumerator ChooseNewSupremeCard()
    {
        yield return new WaitUntil(() => !Deck.GetComponent<Deck>().isShuffling);
        bool canChooseSupremeCard = false;
        if(SupremeCard != null)
        {
            StartCoroutine(Deck.GetComponent<Deck>().InsertCardRandomlyIntoDeck(SupremeCard, fn: () =>
            {
                SupremeCard = null;
                canChooseSupremeCard = true;
            }));

        } else {canChooseSupremeCard = true;}
        yield return new WaitUntil(() => canChooseSupremeCard);
        StartCoroutine(Deck.GetComponent<Deck>().TakeCardRandomlyFromDeck(SupremeCardSpawnPoint.position, targetRot: Quaternion.identity, fn: (card) =>
        {
            SupremeCard = card;
        }));
    }
    IEnumerator DeactivateRoundTxt()
    {
        float animLength = RoundTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length;
        yield return new WaitForSeconds(animLength);
        RoundTxt.SetActive(false);
    }
    void EndRound()
    {
        round++;
        turn = 0;
        currentDuelNum = 0;
        if(player.roundWins >= 3)
        {
            player.WinRound();
            AIEnemy.LoseRound();
            return;
        }
        if(AIEnemy.roundWins >= 3)
        {
            AIEnemy.WinRound();
            player.LoseRound();
            return;
        }
        StartRound();
    }
    void Update()
    {
        
    }
}
