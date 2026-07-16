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
    [SerializeField] GameObject PlayerDamageDealtTxt;
    [SerializeField] GameObject EnemyDamageDealtTxt;
    [SerializeField] float damageAddedUpDelay = 1f;
    [SerializeField] float damageAddedToPointsDelay = 1f;
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
        yield return new WaitUntil(() => !cam.GetComponent<Animator>().IsInTransition(0) && cam.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("Default"));
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
        if(player.cardBeingPlayed.type == SupremeCard.type)
        {
            yield return AddSupremeCardBonus(player);
            playerDenominationAdder += supremeCardDenominationBonus;
        }
        if(AIEnemy.cardBeingPlayed.type == SupremeCard.type)
        {
            yield return AddSupremeCardBonus(AIEnemy);
            enemyDenominationAdder += supremeCardDenominationBonus;
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
        yield return ReturnWonCardsToDeck();
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
    IEnumerator ReturnWonCardsToDeck()
    {
        // Return Player Cards
        cam.GetComponent<Animator>().SetBool("LookAtPlayerWonCards", true);
        
        yield return new WaitUntil(() => !cam.GetComponent<Animator>().IsInTransition(0) && cam.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("LookAtPlayerWonCards"));
        PlayerDamageDealtTxt.SetActive(true);
        PlayerDamageDealtTxt.GetComponent<Denomination>().PositionInFrontOfCam = true;
        PlayerDamageDealtTxt.GetComponent<Animator>().speed = 3;
        PlayerDamageDealtTxt.GetComponent<TMP_Text>().text = "0";
        int playerCardDamageStoppedMoving = 0;
        int totalPlayerDamageDealt = 0;
        for(int i = player.WonCards.Count-1; i >= 0; i--)
        {
            if(i % 2 == 0)
            {
                Transform DamageTxt = PlayerCardsWonTransform.GetChild(i/2).Find("DamageTxt");
                int playerDamageDealt = int.Parse(DamageTxt.GetComponent<TMP_Text>().text);
                totalPlayerDamageDealt += playerDamageDealt;
                DamageTxt.GetComponent<Entity>().Start();
                Vector3 prevPos = DamageTxt.position;
                Quaternion prevRot = DamageTxt.rotation;
                DamageTxt.GetComponent<Entity>().StartMoving(PlayerDamageDealtTxt.transform.position, PlayerDamageDealtTxt.transform.rotation, useLocalRot: false, fn: () =>
                {
                    DamageTxt.gameObject.SetActive(false);
                    PlayerDamageDealtTxt.GetComponent<Denomination>().AddToDenomination();
                    PlayerDamageDealtTxt.GetComponent<Denomination>().adder += playerDamageDealt;
                    PlayerDamageDealtTxt.GetComponent<Animator>().SetBool("Add", true);
                    StartCoroutine(SetDamageTextAnimToFalse(PlayerDamageDealtTxt));
                    DamageTxt.position = prevPos;
                    DamageTxt.rotation = prevRot;
                    playerCardDamageStoppedMoving++;
                    Debug.Log($"playerCardDamageStoppedMoving {playerCardDamageStoppedMoving}, playerDamageDealt {playerDamageDealt}");
                });
            }
            Deck.GetComponent<Deck>().AddCardToTopOfDeck(player.WonCards[i], speed: player.WonCards[i].moveSpeed);
            yield return new WaitForSeconds(delayBetweenWonCardsReturnToDeck);
        }
        yield return new WaitUntil(() => playerCardDamageStoppedMoving >= player.WonCards.Count/2);
        yield return new WaitUntil(() => !PlayerDamageDealtTxt.GetComponent<Animator>().GetBool("Add"));
        Debug.Log($"playerCardDamageStoppedMoving {playerCardDamageStoppedMoving}, player.WonCards.Count/2 {player.WonCards.Count/2}");
        yield return new WaitForSeconds(damageAddedUpDelay);
        PlayerDamageDealtTxt.GetComponent<Denomination>().PositionInFrontOfCam = false;
        bool PlayerDamageDealtTxtStopMoving = false;
        
        PlayerDamageDealtTxt.GetComponent<Entity>().StartMoving(player.PointsTxt.transform.position, player.PointsTxt.transform.rotation, useLocalRot: false, fn: () =>
        {
            player.AddPoints(totalPlayerDamageDealt);
            PlayerDamageDealtTxt.SetActive(false);
            PlayerDamageDealtTxtStopMoving = true;
            Debug.Log($"player.PointsTxt.transform.position {player.PointsTxt.transform.position} PlayerDamageDealtTxt {PlayerDamageDealtTxt.transform.position}");
        });
        
        yield return new WaitUntil(() => PlayerDamageDealtTxtStopMoving);
        player.WonCards.Clear();
        
        yield return new WaitForSeconds(damageAddedToPointsDelay);
        cam.GetComponent<Animator>().SetBool("LookAtPlayerWonCards", false);

        // Return Enemy Cards
        cam.GetComponent<Animator>().SetBool("LookAtEnemyWonCards", true);
        yield return new WaitUntil(() => !cam.GetComponent<Animator>().IsInTransition(0) && cam.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("LookAtEnemyWonCards"));
        EnemyDamageDealtTxt.SetActive(true);
        EnemyDamageDealtTxt.GetComponent<Denomination>().PositionInFrontOfCam = true;
        EnemyDamageDealtTxt.GetComponent<Animator>().speed = 3;
        EnemyDamageDealtTxt.GetComponent<TMP_Text>().text = "0";
        int enemyCardDamageStoppedMoving = 0;
        int totalEnemyDamageDealt = 0;
        for(int i = AIEnemy.WonCards.Count-1; i >= 0; i--)
        {
            if(i % 2 == 0)
            {
                Transform DamageTxt = EnemyCardsWonTransform.GetChild(i/2).Find("DamageTxt");
                int enemyDamageDealt = int.Parse(DamageTxt.GetComponent<TMP_Text>().text);
                totalEnemyDamageDealt += enemyDamageDealt;
                DamageTxt.GetComponent<Entity>().Start();
                Vector3 prevPos = DamageTxt.position;
                Quaternion prevRot = DamageTxt.rotation;
                DamageTxt.GetComponent<Entity>().StartMoving(EnemyDamageDealtTxt.transform.position, EnemyDamageDealtTxt.transform.rotation, useLocalRot: false, fn: () =>
                {
                    DamageTxt.gameObject.SetActive(false);
                    PlayerDamageDealtTxt.GetComponent<Denomination>().AddToDenomination();
                    EnemyDamageDealtTxt.GetComponent<Denomination>().adder += enemyDamageDealt;
                    EnemyDamageDealtTxt.GetComponent<Animator>().SetBool("Add", true);
                    StartCoroutine(SetDamageTextAnimToFalse(EnemyDamageDealtTxt));
                    DamageTxt.position = EnemyCardsWonTransform.GetChild(i/2).Find("WinningCard").position;
                    DamageTxt.rotation = EnemyCardsWonTransform.GetChild(i/2).Find("WinningCard").rotation;
                    enemyCardDamageStoppedMoving++;            
                });
            }
            Deck.GetComponent<Deck>().AddCardToTopOfDeck(AIEnemy.WonCards[i], speed: AIEnemy.WonCards[i].moveSpeed);
            yield return new WaitForSeconds(delayBetweenWonCardsReturnToDeck);
        }
        yield return new WaitUntil(() => enemyCardDamageStoppedMoving >= AIEnemy.WonCards.Count/2);
        yield return new WaitUntil(() => !EnemyDamageDealtTxt.GetComponent<Animator>().GetBool("Add"));
        yield return new WaitForSeconds(damageAddedUpDelay);
        bool EnemyDamageDealtTxtStopMoving = false;
        EnemyDamageDealtTxt.GetComponent<Denomination>().PositionInFrontOfCam = false;
        EnemyDamageDealtTxt.GetComponent<Entity>().StartMoving(AIEnemy.PointsTxt.transform.position, AIEnemy.PointsTxt.transform.rotation, useLocalRot: false, fn: () =>
        {
            AIEnemy.AddPoints(totalEnemyDamageDealt);
            EnemyDamageDealtTxt.SetActive(false);
            EnemyDamageDealtTxtStopMoving = true;
        });
        yield return new WaitUntil(() => EnemyDamageDealtTxtStopMoving);
        AIEnemy.WonCards.Clear();

        yield return new WaitForSeconds(damageAddedToPointsDelay);
        cam.GetComponent<Animator>().SetBool("LookAtEnemyWonCards", false);
    }
    IEnumerator SetDamageTextAnimToFalse(GameObject DamageDealtTxt)
    {
        float animLength = player.GetAnimLengthByName("Add", DamageDealtTxt.GetComponent<Animator>());
        yield return new WaitForSeconds(animLength);
        DamageDealtTxt.GetComponent<Animator>().SetBool("Add", false);
    }
    void Update()
    {
        
    }
}
