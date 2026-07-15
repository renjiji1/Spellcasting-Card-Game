using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;
using TMPro;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    Camera cam;
    [SerializeField] public GameObject Deck;
    [SerializeField] public GameObject AllCardSlots;
    [SerializeField] GameObject RoundTxt;
    [NonSerialized] public bool paused = false;
    [SerializeField] public Player player;
    [SerializeField] public AI AIEnemy;

    [Header("Round")]
    [SerializeField] float delayBetweenWonCardsReturnToDeck = .2f;
    [NonSerialized] public int round = 1;
    [SerializeField] int roundWinsToWin = 3;
    [NonSerialized] public bool isChoosingSupremeCard = false;
    [NonSerialized] public int turn = 0; // number of turns that happened in the current duel
    [NonSerialized] public GameObject currentPlayer; // the player whose turn it is
    int playerDamageDone = 0;
    int enemyDamageDone = 0;
    [Header("Supreme Card")]
    [NonSerialized] public Card SupremeCard;
    [SerializeField] public Transform SupremeCardSpawnPoint;
    [SerializeField] int supremeCardDenominationBonus = 3;
    [SerializeField] GameObject SupremeCardBonus;
    [SerializeField] float supremeCardBonusMoveDelay = .5f;

    [Header("Card Clash Tie")]
    [SerializeField] int cardClashTieWinnerBonus = 3;
    [SerializeField] float cardClashTieDelay = .15f;
    [SerializeField] float cardClashTieFinishDelay = .3f;
    [SerializeField] GameObject CardClashTiePlayerTypeProjection;
    [SerializeField] GameObject CardClashTieEnemyTypeProjection;
    [SerializeField] float CardClashTieProjectionOffsetY = .1f;

    public int maxDuels = 10;
    [NonSerialized] public int currentDuelNum = 0;
    [Header("Card Clash")]
    [SerializeField] float cardClashEnterDelay = .5f;
    [SerializeField] float cardClashDistanceFromCamera = .3f;
    [SerializeField] float cardClashXOffset = .2f;
    [SerializeField] float cardClashExitDelay = .5f;
    [SerializeField] Transform PlayerCardsWonTransform;
    [SerializeField] Transform EnemyCardsWonTransform;
    void Awake()
    {
        instance = this;
    }
    void Start()
    {
        currentPlayer = player.gameObject;
        cam = Camera.main.GetComponent<Camera>();
        StartRound();
    }

    public void EndTurn()
    {
        turn++;
        currentPlayer = currentPlayer == player.gameObject ? AIEnemy.gameObject : player.gameObject;
        Debug.Log(currentPlayer);
        if (turn > 1)
        {
            currentDuelNum++;
            turn = 0;
            StartCoroutine(CardBattle());
        } else
        {
           currentPlayer.GetComponent<Agent>().StartTurn(); 
        }
    }
    IEnumerator CardBattle()
    {
        // move cards into position in front of camera for clash
        yield return new WaitForSeconds(cardClashEnterDelay);
        int cardsInPositionForClash = 0;
        player.cardBeingPlayed.StartMoving(cam.transform.position + cam.transform.forward * cardClashDistanceFromCamera + cam.transform.right * -cardClashXOffset/2, cam.transform.rotation, fn: () =>
        {
            cardsInPositionForClash++;
        });
        AIEnemy.cardBeingPlayed.StartMoving(cam.transform.position + cam.transform.forward * cardClashDistanceFromCamera + cam.transform.right * cardClashXOffset/2, cam.transform.rotation, fn: () =>
        {
            cardsInPositionForClash++;
        });
        int enemyDenominationAdder = 0;
        int playerDenominationAdder = 0;
        yield return new WaitUntil(() => cardsInPositionForClash >= 2);
        if(AIEnemy.cardBeingPlayed.type == SupremeCard.type)
        {
            yield return AddSupremeCardBonus(AIEnemy);
            enemyDenominationAdder += supremeCardDenominationBonus;
        }
        if(player.cardBeingPlayed.type == SupremeCard.type)
        {
            yield return AddSupremeCardBonus(player);
            playerDenominationAdder += supremeCardDenominationBonus;
        }

        bool playerWon = player.cardBeingPlayed.denomination > AIEnemy.cardBeingPlayed.denomination;
        if(AIEnemy.cardBeingPlayed.denomination == player.cardBeingPlayed.denomination)
        {
            yield return CardClashTie();
            if(RoShamBoWinner(player.cardBeingPlayed.type, AIEnemy.cardBeingPlayed.type) == 1) {
                playerDenominationAdder += cardClashTieWinnerBonus;
                playerWon = true;
            } else { 
                enemyDenominationAdder += cardClashTieWinnerBonus;
                playerWon = false; 
            }
        }
        
        yield return new WaitForSeconds(cardClashExitDelay);
        int cardsMovedToPosition = 0;
        int damageDealt = Mathf.Abs(player.cardBeingPlayed.denomination - AIEnemy.cardBeingPlayed.denomination);
        
        if(playerWon)
        {
            playerDamageDone += damageDealt;
            AIEnemy.cardBeingPlayed.StartMoving(PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).position, PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).rotation, fn: () =>
            {
                PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("DamageTxt").GetComponent<TMP_Text>().text = "" + damageDealt;
                PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("DamageTxt").gameObject.SetActive(true);
                player.WonCards.Add(AIEnemy.cardBeingPlayed);
                cardsMovedToPosition++;
            });
            player.cardBeingPlayed.StartMoving(PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("WinningCard").position, PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("WinningCard").rotation, fn: () =>
            {
                player.WonCards.Add(player.cardBeingPlayed);
                cardsMovedToPosition++;
            });
        } else
        {
            enemyDamageDone += damageDealt;
            AIEnemy.cardBeingPlayed.StartMoving(EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("WinningCard").position, EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("WinningCard").rotation, fn: () =>
            {
                EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("DamageTxt").GetComponent<TMP_Text>().text = "" + damageDealt;
                EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("DamageTxt").gameObject.SetActive(true);
                AIEnemy.WonCards.Add(AIEnemy.cardBeingPlayed);
                cardsMovedToPosition++;
            });
            player.cardBeingPlayed.StartMoving(EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).position, EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).rotation, fn: () =>
            {
                AIEnemy.WonCards.Add(player.cardBeingPlayed);
                cardsMovedToPosition++;
            });
        }

        yield return new WaitUntil(() => cardsMovedToPosition >= 2);
        if(playerWon)
        {
            player.UseMana();
        } else {
            AIEnemy.UseMana();
        }
        player.DeactivateCurrentCard(playerDenominationAdder);
        AIEnemy.DeactivateCurrentCard(enemyDenominationAdder);
        Agent agentWithInitiative = playerWon ? player : AIEnemy;
        if(currentDuelNum >= maxDuels)
        {
            StartCoroutine(EndRound());
        } else
        {
            StartCoroutine(StartDuel(agentWithInitiative));
        }
    }
    IEnumerator AddSupremeCardBonus(Agent agent)
    {
        GameObject CardDenomination = agent.cardBeingPlayed.transform.Find($"{agent.cardBeingPlayed.frontPath}/Denomination").gameObject;
        SupremeCardBonus.transform.position = SupremeCardSpawnPoint.Find("TypeProjection").position;
        SupremeCardBonus.GetComponent<TMP_Text>().text = "" + supremeCardDenominationBonus;
        SupremeCardBonus.SetActive(true);
        
        yield return new WaitForSeconds(supremeCardBonusMoveDelay);
        bool supremeCardBonusMoveFinished = false;
        SupremeCardBonus.GetComponent<Entity>().StartMoving(CardDenomination.transform.position, CardDenomination.transform.rotation, fn: () =>
        {
            SupremeCardBonus.SetActive(false);
            supremeCardBonusMoveFinished = true;
        });

        yield return new WaitUntil(() => supremeCardBonusMoveFinished);
        CardDenomination.GetComponent<Denomination>().adder = supremeCardDenominationBonus;
        CardDenomination.GetComponent<Animator>().SetBool("Add", true);
        agent.cardBeingPlayed.denomination += supremeCardDenominationBonus;
        float supremeCardBonusAnimLength = agent.GetAnimLengthByName("Add", CardDenomination.GetComponent<Animator>());
        
        yield return new WaitForSeconds(supremeCardBonusAnimLength);
        CardDenomination.GetComponent<Animator>().SetBool("Add", false);
    }
    IEnumerator CardClashTie()
    {
        CardClashTiePlayerTypeProjection.SetActive(true);
        CardClashTiePlayerTypeProjection.GetComponent<SpriteRenderer>().sprite = player.cardBeingPlayed.transform.Find($"{player.cardBeingPlayed.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
        CardClashTiePlayerTypeProjection.transform.position = player.cardBeingPlayed.transform.position + cam.transform.up * CardClashTieProjectionOffsetY;
        CardClashTiePlayerTypeProjection.transform.rotation = player.cardBeingPlayed.transform.Find($"{player.cardBeingPlayed.frontPath}").rotation;

        CardClashTieEnemyTypeProjection.SetActive(true);
        CardClashTieEnemyTypeProjection.GetComponent<SpriteRenderer>().sprite = AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
        CardClashTieEnemyTypeProjection.transform.position = AIEnemy.cardBeingPlayed.transform.position + cam.transform.up * CardClashTieProjectionOffsetY;
        CardClashTieEnemyTypeProjection.transform.rotation = AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}").rotation;
        
        yield return new WaitForSeconds(cardClashTieDelay);
        Vector3 projectionTargetPos = cam.transform.position + cam.transform.forward * cardClashDistanceFromCamera + cam.transform.up * CardClashTieProjectionOffsetY;
        bool typeProjectionsFinishedMoving = false;
        CardClashTiePlayerTypeProjection.GetComponent<Entity>().Start();
        CardClashTiePlayerTypeProjection.GetComponent<Entity>().StartMoving(projectionTargetPos, CardClashTiePlayerTypeProjection.transform.rotation, fn: () =>
        {
            typeProjectionsFinishedMoving = true;
        });
        CardClashTieEnemyTypeProjection.GetComponent<Entity>().Start();
        CardClashTieEnemyTypeProjection.GetComponent<Entity>().StartMoving(projectionTargetPos, CardClashTieEnemyTypeProjection.transform.rotation, fn: () =>
        {
            typeProjectionsFinishedMoving = true;
        });

        yield return new WaitUntil(() => typeProjectionsFinishedMoving);
        int winner = RoShamBoWinner(player.cardBeingPlayed.type, AIEnemy.cardBeingPlayed.type);
        GameObject CardDenomination;
        if(winner == 1)
        {
            CardDenomination = player.cardBeingPlayed.transform.Find($"{player.cardBeingPlayed.frontPath}/Denomination").gameObject;
            CardClashTieEnemyTypeProjection.SetActive(false);
            player.cardBeingPlayed.denomination += supremeCardDenominationBonus;
        } else
        {
            CardDenomination = AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}/Denomination").gameObject;
            CardClashTiePlayerTypeProjection.SetActive(false);
            AIEnemy.cardBeingPlayed.denomination += supremeCardDenominationBonus;
        }
        CardDenomination.GetComponent<Denomination>().adder = cardClashTieWinnerBonus;
        CardDenomination.GetComponent<Animator>().SetBool("Add", true);

        yield return new WaitForSeconds(cardClashTieFinishDelay);
        CardClashTieEnemyTypeProjection.SetActive(false);
        CardClashTiePlayerTypeProjection.SetActive(false);
    }

    public int RoShamBoWinner(MagicType type1, MagicType type2)
    {
        if(type1 == MagicType.Illusion && type2 == MagicType.Abjuration)
        {
            return 1;
        }
        if(type1 == MagicType.Abjuration && type2 == MagicType.Evocation)
        {
            return 1;
        }
        if(type1 == MagicType.Evocation && type2 == MagicType.Illusion)
        {
            return 1;
        }
        if(type1 == MagicType.Illusion && type2 == MagicType.Evocation)
        {
            return 2;
        }
        if(type1 == MagicType.Evocation && type2 == MagicType.Abjuration)
        {
            return 2;
        }
        if(type1 == MagicType.Abjuration && type2 == MagicType.Illusion)
        {
            return 2;
        }
        return -1;
    }

    IEnumerator StartDuel(Agent agentWithInitiative)
    {
        yield return new WaitUntil(() => !Deck.GetComponent<Deck>().isShuffling && !Deck.GetComponent<Deck>().isDealing && !isChoosingSupremeCard);
        agentWithInitiative.GetComponent<Agent>().StartTurn();
        currentPlayer = agentWithInitiative.gameObject;
    }
    void StartRound()
    {
        Deck.GetComponent<Deck>().Start();
        StartCoroutine(Deck.GetComponent<Deck>().StartShuffle());
        StartCoroutine(ShowRoundTxt());
        StartCoroutine(StartDuel(player));
    }
    IEnumerator ShowRoundTxt()
    {
        RoundTxt.GetComponent<TMP_Text>().text = "Round " + round;
        RoundTxt.SetActive(true);
        float animLength = RoundTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length;
        yield return new WaitForSeconds(animLength);
        RoundTxt.SetActive(false);
    }
    IEnumerator EndRound()
    {
        Agent winningAgent = playerDamageDone >= enemyDamageDone ? player : AIEnemy;
        yield return ReturnWonCardsToDeck(winningAgent);
        round++;
        turn = 0;
        currentDuelNum = 0;
        playerDamageDone = 0;
        enemyDamageDone = 0;
        player.ResetMana();
        AIEnemy.ResetMana();
        if(player.points >= player.pointsToWin)
        {
            player.WinRound();
            AIEnemy.LoseRound();
        } else if(AIEnemy.points >= AIEnemy.pointsToWin)
        {
            AIEnemy.WinRound();
            player.LoseRound();
        } else
        {
           StartRound(); 
        }
    }
    IEnumerator ReturnWonCardsToDeck(Agent winningAgent)
    {
        int mostWonCardsCount = player.WonCards.Count > AIEnemy.WonCards.Count ? player.WonCards.Count : AIEnemy.WonCards.Count;
        Transform winningWonCardsTransform = winningAgent == player ? PlayerCardsWonTransform : EnemyCardsWonTransform;       
        Transform losingWonCardsTransform = winningAgent != player ? PlayerCardsWonTransform : EnemyCardsWonTransform;
        int winningCardDamageStoppedMoving = 0;
        for(int i = mostWonCardsCount-1; i >= 0; i--)
        {
            
            winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").GetComponent<Entity>().Start();
            winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").GetComponent<Entity>().StartMoving(winningAgent.PointsTxt.transform.position, winningAgent.PointsTxt.transform.rotation, fn: () =>
            {
                winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").gameObject.SetActive(false);
                winningAgent.AddPoints(int.Parse(winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").GetComponent<TMP_Text>().text));
                winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").position = winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("WinningCard").position;
                winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").localRotation = winningWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").rotation;
                winningCardDamageStoppedMoving++;            
            });
            losingWonCardsTransform.GetChild(winningAgent.WonCards.Count/2).Find("DamageTxt").gameObject.SetActive(false);
            if(player.WonCards.Count > i)
            {
                Deck.GetComponent<Deck>().AddCardToTopOfDeck(player.WonCards[i], speed: player.WonCards[i].moveSpeed);
                player.WonCards.RemoveAt(i);
            }
            if(AIEnemy.WonCards.Count > i)
            {
                Deck.GetComponent<Deck>().AddCardToTopOfDeck(AIEnemy.WonCards[i], speed: AIEnemy.WonCards[i].moveSpeed);
                AIEnemy.WonCards.RemoveAt(i);
            }
            yield return new WaitForSeconds(delayBetweenWonCardsReturnToDeck);        
        }
        yield return new WaitUntil(() => winningCardDamageStoppedMoving >= winningAgent.WonCards.Count);
    }
    void Update()
    {
        
    }
}
