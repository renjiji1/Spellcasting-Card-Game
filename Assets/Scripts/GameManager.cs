using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using TMPro;
using Random = UnityEngine.Random;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    [SerializeField] SettingsManager settings;
    float animationSpeed = 1;
    Camera cam;
    [NonSerialized] public static bool paused = false;
    public static int maxCardDenomination = 10;
    [SerializeField] public GameObject DumpCardButtonOnRedraw;
    [SerializeField] TMP_Text TurnTxt;
    [SerializeField] Color playerTurnColor;
    [SerializeField] Color enemyTurnColor;
    [SerializeField] public GameObject Deck;
    [SerializeField] public GameObject AllCardSlots;
    [SerializeField] GameObject RoundTxt;
    [SerializeField] public Player Player;
    [NonSerialized] public static Player player;
    [SerializeField] GameObject ApprenticeEnemy;
    [SerializeField] GameObject MageEnemy;
    [SerializeField] GameObject ArchWizardEnemy;
    [SerializeField] GameObject SimulacrumEnemy;
    [SerializeField] GameObject LichEnemy;
    [NonSerialized] public static AI AIEnemy;
    [SerializeField] public GameObject CantUsePowerTxt;
    [SerializeField] public GameObject LevelUpTxt;
    [SerializeField] public GameObject RedrawTxt;
    [SerializeField] public GameObject SupremeCardSwapTxt;
    [SerializeField] public GameObject MimicryTxt;
    [SerializeField] GameObject ManaBustTxt;
    [Header("Round")]
    [SerializeField] float returnEnemyWonCardsDelay = .2f;
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
    [SerializeField] float delayBeforeAddingPoints = .3f;
    int playerDamageDone = 0;
    int enemyDamageDone = 0;
    bool manaBust = false;
    [NonSerialized] public Agent agentForceInitiative = null;
    [NonSerialized] public Agent agentDominate = null;
    [NonSerialized] public bool mimicryActive = false;
    [SerializeField] public TMP_Text PowerNameTxt;
    [Header("Supreme Card")]
    [NonSerialized] public Card SupremeCard;
    [SerializeField] public Transform SupremeCardSpawnPoint;
    [SerializeField] GameObject SupremeCardBonus;
    [SerializeField] float supremeCardBonusMoveDelay = .5f;
    [NonSerialized] public MagicSource SupremeSource;

    [Header("Card Clash Tie")]
    [SerializeField] public int cardClashTieWinnerBonus = 3;
    [SerializeField] float cardClashTieDelay = .15f;
    [SerializeField] float cardClashTieFinishDelay = .3f;
    [SerializeField] GameObject CardClashTiePlayerTypeProjection;
    [SerializeField] GameObject CardClashTieEnemyTypeProjection;
    [SerializeField] float CardClashTieProjectionOffsetY = .1f;

    public int maxDuels = 10;
    [NonSerialized] public int currentDuelNum = 0;
    [Header("Card Clash")]
    [SerializeField] public int RoShamBoWinnerDenominationBonus = 3;
    [SerializeField] float cardClashEnterDelay = .5f;
    [SerializeField] float cardClashDistanceFromCamera = .3f;
    [SerializeField] float cardClashXOffset = .2f;
    [SerializeField] float cardClashPowerUseDelay = .35f;
    [SerializeField] float cardClashExitDelay = .5f;
    [SerializeField] Transform PlayerCardsWonTransform;
    [SerializeField] Transform EnemyCardsWonTransform;
    [SerializeField] GameObject DamageNumTxt;
    [SerializeField] float damageNumTxtYOffset = -1;
    [SerializeField] float damageNumTxtDistFromCamScalar = .5f;
    [SerializeField] GameObject PlayerDamageBonusTxt;
    [SerializeField] GameObject EnemyDamageBonusTxt;
    [SerializeField] GameObject PlayerDenominationBonusTxt;
    [SerializeField] GameObject EnemyDenominationBonusTxt;
    [SerializeField] int streakAdder = 1;
    [SerializeField] float damageBonusDelay = .1f;
    [SerializeField] float afterStreakDelay = .25f;
    [NonSerialized] public int playerStreak = 0;
    [NonSerialized] public int enemyStreak = 0;

    [Header("End Game")]
    [SerializeField] GameObject EndGameLosePanel;
    [SerializeField] GameObject EndGameWinPanel;
    [SerializeField] GameObject EndGameButtons;
    [SerializeField] GameObject EndGamePlayerWinsTxt;
    [SerializeField] GameObject EndGameEnemyWinsTxt;
    [SerializeField] TMP_Text EndGamePlayerDamageTxt;
    [SerializeField] TMP_Text EndGameEnemyDamageTxt;
    [SerializeField] GameObject WinsTxtObj;
    
    void Awake()
    {
        instance = this;
        paused = false;
        player = Player;
    }
    void Start()
    {
        currentPlayer = player.gameObject;
        switch (SaveData.instance.currentDifficulty)
        {
            case 0:
                AIEnemy = ApprenticeEnemy.GetComponent<AI>();
                break;
            case 1:
                AIEnemy = MageEnemy.GetComponent<AI>();
                break;
            case 2:
                AIEnemy = ArchWizardEnemy.GetComponent<AI>();
                break;
            case 3:
                AIEnemy = SimulacrumEnemy.GetComponent<AI>();
                break;
            case 4:
                AIEnemy = LichEnemy.GetComponent<AI>();
                break;
        }
        AIEnemy.gameObject.SetActive(true);
        cam = Camera.main.GetComponent<Camera>();
        PlayerDenominationBonusTxt.GetComponent<Animator>().speed = 1.5f;
        EnemyDenominationBonusTxt.GetComponent<Animator>().speed = 1.5f;
        StartRound();
    }

    public void EndTurn()
    {
        turn++;
        currentPlayer = currentPlayer == player.gameObject ? AIEnemy.gameObject : player.gameObject;
        if(currentPlayer == player.gameObject)
        {
            TurnTxt.text = "Your Turn";
            TurnTxt.color = playerTurnColor;
        } else
        {
            TurnTxt.text = "Enemy's Turn";
            TurnTxt.color = enemyTurnColor;
        }

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
        AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}/EnemyHighlightBg").gameObject.SetActive(false);
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

        // Ro Sham Bo Bonus
        int roShamBoWinner = RoShamBoWinner(player.cardBeingPlayed.type, AIEnemy.cardBeingPlayed.type);
        if(roShamBoWinner == 1 || agentDominate == player)
        {
            yield return AddRoShamBoBonus(player, PlayerDenominationBonusTxt);
            playerDenominationAdder += RoShamBoWinnerDenominationBonus;
        }
        if(roShamBoWinner == 2 || agentDominate == AIEnemy)
        {
            yield return AddRoShamBoBonus(AIEnemy, EnemyDenominationBonusTxt);
            enemyDenominationAdder += RoShamBoWinnerDenominationBonus;
        }
        agentDominate = null;
        
        //Adrenaline Bonus
        if(player.adrenalineActive)
        {
            playerDenominationAdder += player.cardBeingPlayed.denomination;
            yield return AddAdrenalineBonus(player, PlayerDenominationBonusTxt);
        }
        if(AIEnemy.adrenalineActive)
        {
            enemyDenominationAdder += AIEnemy.cardBeingPlayed.denomination;
            yield return AddAdrenalineBonus(AIEnemy, EnemyDenominationBonusTxt);
        }

        //Mimicry turn card to 0
        if(mimicryActive)
        {
            if(player.cardBeingPlayed.type != AIEnemy.cardBeingPlayed.type)
            {
                if(currentPlayer == player.gameObject)
                {
                    enemyDenominationAdder -= AIEnemy.cardBeingPlayed.denomination;
                } else
                {
                    playerDenominationAdder -= player.cardBeingPlayed.denomination;
                }
            }
            yield return MimicryPenalty();
        }
        
        //Card Clash Tie
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

        // Damage Txt
        Agent agentThatWon = playerWon ? player : AIEnemy;
        int damageDealt = Mathf.Abs(player.cardBeingPlayed.denomination - AIEnemy.cardBeingPlayed.denomination);
        yield return ActivateDamageNumTxt(playerWon, damageDealt);

        // Streak
        if(playerStreak > 0 && agentThatWon == player)
        {
            yield return AddStreakBonus(player, playerStreak, PlayerDamageBonusTxt);
            damageDealt += playerStreak * streakAdder;
        }
        if(enemyStreak > 0 && agentThatWon == AIEnemy)
        {
            yield return AddStreakBonus(AIEnemy, enemyStreak, EnemyDamageBonusTxt);
            damageDealt += enemyStreak * streakAdder;
        }
        playerStreak = playerWon ? playerStreak + 1 : 0;
        enemyStreak = playerWon ? 0 : enemyStreak + 1;

        // Manage Supreme Card Bonus
        if(player.cardBeingPlayed.type == SupremeCard.type && agentThatWon == player)
        {
            yield return AddSupremeCardBonus(player, damageDealt, PlayerDamageBonusTxt);
            damageDealt *= 2;
        }
        if(AIEnemy.cardBeingPlayed.type == SupremeCard.type && agentThatWon == AIEnemy)
        {
            yield return AddSupremeCardBonus(AIEnemy, damageDealt, EnemyDamageBonusTxt);
            damageDealt *= 2;
        }
        
        //Move the cards to the winner's side
        yield return new WaitForSeconds(cardClashExitDelay);
        int cardsMovedToPosition = 0;
        GameObject WonCardDamageTxt;
        if(playerWon)
        {
            playerDamageDone += damageDealt;
            WonCardDamageTxt = PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("DamageTxt").gameObject;
            AIEnemy.cardBeingPlayed.StartMoving(PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).position, PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).rotation, fn: () =>
            {
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
            WonCardDamageTxt = EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("DamageTxt").gameObject;
            AIEnemy.cardBeingPlayed.StartMoving(EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("WinningCard").position, EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("WinningCard").rotation, fn: () =>
            {
                AIEnemy.WonCards.Add(AIEnemy.cardBeingPlayed);
                cardsMovedToPosition++;
            });
            player.cardBeingPlayed.StartMoving(EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).position, EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).rotation, fn: () =>
            {
                AIEnemy.WonCards.Add(player.cardBeingPlayed);
                cardsMovedToPosition++;
            });
        }
        DamageNumTxt.transform.parent.GetComponent<Entity>().StartMoving(WonCardDamageTxt.transform.position, WonCardDamageTxt.transform.rotation, fn: () =>
        {
            WonCardDamageTxt.GetComponent<TMP_Text>().text = "" + damageDealt;
            WonCardDamageTxt.SetActive(true);
        });
        yield return new WaitUntil(() => cardsMovedToPosition >= 2);

        if(playerWon)
        {
            AIEnemy.adrenalineActive = false;
            AIEnemy.envigorateActive = false;
            player.UseMana();
            AIEnemy.UseMana(win: false);
        } else {
            player.adrenalineActive = false;
            player.envigorateActive = false;
            AIEnemy.UseMana();
            player.UseMana(win: false);
        }
        player.DeactivateCurrentCard(playerDenominationAdder);
        AIEnemy.DeactivateCurrentCard(enemyDenominationAdder);

        int arcanaAdded = 0;
        StartCoroutine(player.AddArcana(finishedFn: () => {arcanaAdded++;}));
        StartCoroutine(AIEnemy.AddArcana(finishedFn: () => {arcanaAdded++;}));
        yield return new WaitUntil(() => arcanaAdded >= 2);

        //Mana Bust
        if(player.mana < 0)
        {
            yield return ReturnWonCardsOnManaBust(player);
        }
        if(AIEnemy.mana < 0)
        {
            yield return ReturnWonCardsOnManaBust(AIEnemy);
        }
        
        if(currentDuelNum >= maxDuels || manaBust)
        {
            StartCoroutine(EndRound());
        } else
        {
            StartCoroutine(StartDuel(agentThatWon));
        }
    }
    IEnumerator ActivateDamageNumTxt(bool playerWon, int damageDealt)
    {
        DamageNumTxt.transform.parent.position = cam.transform.position + cam.transform.forward * cardClashDistanceFromCamera * damageNumTxtDistFromCamScalar + cam.transform.up * damageNumTxtYOffset;
        DamageNumTxt.transform.parent.rotation = cam.transform.rotation;
        
        DamageNumTxt.GetComponent<TMP_Text>().color = playerWon ? Color.blue : Color.red;
        DamageNumTxt.GetComponent<TMP_Text>().text = "" + 0;
        DamageNumTxt.SetActive(true);
        yield return null;
        DamageNumTxt.GetComponent<Denomination>().adder = damageDealt;
        DamageNumTxt.GetComponent<Animator>().SetBool("Add", true);
        DamageNumTxt.GetComponent<Animator>().Play("Add", 0, 0);
        float addAnimLength = player.GetAnimLengthByName("Add", DamageNumTxt.GetComponent<Animator>());  
        yield return new WaitForSeconds(addAnimLength);
        DamageNumTxt.GetComponent<Animator>().SetBool("Add", false);
    }
    IEnumerator AddRoShamBoBonus(Agent agent, GameObject DenominationBonusTxt)
    {
        DenominationBonusTxt.GetComponent<TMP_Text>().text = agentDominate == null ? "Advantage" : "Dominate";
        DenominationBonusTxt.SetActive(true);
        yield return new WaitForSeconds(damageBonusDelay / DenominationBonusTxt.GetComponent<Animator>().speed);

        float streakActivateAnimLength = DenominationBonusTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length - damageBonusDelay;        
        GameObject CardDenomination = agent.cardBeingPlayed.transform.Find($"{agent.cardBeingPlayed.frontPath}/Denomination").gameObject;

        CardDenomination.GetComponent<Denomination>().adder = RoShamBoWinnerDenominationBonus;
        CardDenomination.GetComponent<Animator>().SetBool("Add", true);
        CardDenomination.GetComponent<Animator>().Play("Add", 0, 0);
        agent.cardBeingPlayed.denomination += RoShamBoWinnerDenominationBonus;
        float addAnimLength = agent.GetAnimLengthByName("Add", CardDenomination.GetComponent<Animator>());
        
        float waitTime = streakActivateAnimLength > addAnimLength ? streakActivateAnimLength : addAnimLength;
        yield return new WaitForSeconds(waitTime);
        CardDenomination.GetComponent<Animator>().SetBool("Add", false);
        DenominationBonusTxt.SetActive(false);
        yield return new WaitForSeconds(cardClashPowerUseDelay);
    }
    IEnumerator AddAdrenalineBonus(Agent agent, GameObject DenominationBonusTxt)
    {
        DenominationBonusTxt.GetComponent<TMP_Text>().text = "Surge";
        DenominationBonusTxt.SetActive(true);
        yield return new WaitForSeconds(damageBonusDelay / DenominationBonusTxt.GetComponent<Animator>().speed);

        float streakActivateAnimLength = DenominationBonusTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length - damageBonusDelay;
        GameObject CardDenomination = agent.cardBeingPlayed.transform.Find($"{agent.cardBeingPlayed.frontPath}/Denomination").gameObject;

        CardDenomination.GetComponent<Denomination>().adder = agent.cardBeingPlayed.denomination;
        CardDenomination.GetComponent<Animator>().SetBool("Add", false);
        CardDenomination.GetComponent<Animator>().SetBool("Add", true);
        CardDenomination.GetComponent<Animator>().Play("Add", 0, 0);
        agent.cardBeingPlayed.denomination *= 2;
        float supremeCardBonusAnimLength = agent.GetAnimLengthByName("Add", CardDenomination.GetComponent<Animator>());
        
        float waitTime = streakActivateAnimLength > supremeCardBonusAnimLength ? streakActivateAnimLength : supremeCardBonusAnimLength;
        yield return new WaitForSeconds(waitTime);
        CardDenomination.GetComponent<Animator>().SetBool("Add", false);
        DenominationBonusTxt.SetActive(false);
        yield return new WaitForSeconds(cardClashPowerUseDelay);
    }
    IEnumerator MimicryPenalty()
    {
        mimicryActive = false;
        Agent followingPlayer = currentPlayer == player.gameObject ? AIEnemy : player;
        GameObject DenominationBonusTxt = followingPlayer == player ? PlayerDenominationBonusTxt : EnemyDenominationBonusTxt;
        if(followingPlayer.cardBeingPlayed.type != currentPlayer.GetComponent<Agent>().cardBeingPlayed.type)
        {
            DenominationBonusTxt.GetComponent<TMP_Text>().text = "Mimicry";
            DenominationBonusTxt.SetActive(true);
            yield return new WaitForSeconds(damageBonusDelay /  DenominationBonusTxt.GetComponent<Animator>().speed);

            float streakActivateAnimLength = DenominationBonusTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length - damageBonusDelay;
            GameObject CardDenomination = followingPlayer.cardBeingPlayed.transform.Find($"{followingPlayer.cardBeingPlayed.frontPath}/Denomination").gameObject;

            CardDenomination.GetComponent<Denomination>().adder = -followingPlayer.cardBeingPlayed.denomination;
            CardDenomination.GetComponent<Animator>().SetBool("Add", true);
            CardDenomination.GetComponent<Animator>().Play("Add", 0, 0);
            followingPlayer.cardBeingPlayed.denomination = 0;
            float mimicrySubtractAnimLength = followingPlayer.GetAnimLengthByName("Add", CardDenomination.GetComponent<Animator>());
            
            float waitTime = streakActivateAnimLength > mimicrySubtractAnimLength ? streakActivateAnimLength : mimicrySubtractAnimLength;
            yield return new WaitForSeconds(waitTime);
            CardDenomination.GetComponent<Animator>().SetBool("Add", false);
            DenominationBonusTxt.SetActive(false);
            yield return new WaitForSeconds(cardClashPowerUseDelay);
        }
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
            player.cardBeingPlayed.denomination += RoShamBoWinnerDenominationBonus;
        } else
        {
            CardDenomination = AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}/Denomination").gameObject;
            CardClashTiePlayerTypeProjection.SetActive(false);
            AIEnemy.cardBeingPlayed.denomination += RoShamBoWinnerDenominationBonus;
        }
        CardDenomination.GetComponent<Denomination>().adder = cardClashTieWinnerBonus;
        CardDenomination.GetComponent<Animator>().SetBool("Add", true);
        CardDenomination.GetComponent<Animator>().Play("Add", 0, 0);

        yield return new WaitForSeconds(cardClashTieFinishDelay);
        CardClashTieEnemyTypeProjection.SetActive(false);
        CardClashTiePlayerTypeProjection.SetActive(false);
    }
    IEnumerator AddStreakBonus(Agent agent, int streak, GameObject StreakTxt)
    {
        StreakTxt.GetComponent<TMP_Text>().text = $"{streak} Streak";
        StreakTxt.SetActive(true);
        yield return new WaitForSeconds(damageBonusDelay);

        float streakActivateAnimLength = player.GetAnimLengthByName("ActivatePowerTxt", StreakTxt.GetComponent<Animator>()) - damageBonusDelay;
        DamageNumTxt.GetComponent<Denomination>().adder = streak * streakAdder;
        DamageNumTxt.GetComponent<Animator>().SetBool("Add", true);
        DamageNumTxt.GetComponent<Animator>().Play("Add", 0, 0);
        float damageNumAddAnimLength = player.GetAnimLengthByName("Add", DamageNumTxt.GetComponent<Animator>());  
        
        float waitTime = streakActivateAnimLength > damageNumAddAnimLength ? streakActivateAnimLength : damageNumAddAnimLength;
        yield return new WaitForSeconds(waitTime);
        DamageNumTxt.GetComponent<Animator>().SetBool("Add", false);
        StreakTxt.SetActive(false);
        yield return new WaitForSeconds(afterStreakDelay);
    }
    IEnumerator AddSupremeCardBonus(Agent agent, int damageDealt, GameObject SupremeBonusTxt)
    {
        int bonusDamage = damageDealt;
        SupremeBonusTxt.GetComponent<TMP_Text>().text = $"Supreme Bonus +{bonusDamage}";
        SupremeBonusTxt.SetActive(true);
        float supremeBonusActivateAnimLength = player.GetAnimLengthByName("ActivatePowerTxt", SupremeBonusTxt.GetComponent<Animator>());
        
        GameObject CardDenomination = agent.cardBeingPlayed.transform.Find($"{agent.cardBeingPlayed.frontPath}/Denomination").gameObject;
        SupremeCardBonus.transform.position = SupremeCardSpawnPoint.Find("TypeProjection").position;
        
        SupremeCardBonus.GetComponent<TMP_Text>().text = "" + bonusDamage;
        SupremeCardBonus.SetActive(true);
        
        yield return new WaitForSeconds(supremeCardBonusMoveDelay);
        bool supremeCardBonusMoveFinished = false;
        SupremeCardBonus.GetComponent<Entity>().StartMoving(DamageNumTxt.transform.position, DamageNumTxt.transform.rotation, fn: () =>
        {
            SupremeCardBonus.SetActive(false);
            supremeCardBonusMoveFinished = true;
        });

        yield return new WaitUntil(() => supremeCardBonusMoveFinished);
        DamageNumTxt.GetComponent<Denomination>().adder = bonusDamage;
        DamageNumTxt.GetComponent<Animator>().SetBool("Add", true);
        DamageNumTxt.GetComponent<Animator>().Play("Add", 0, 0);
        float supremeCardBonusAnimLength = agent.GetAnimLengthByName("Add", CardDenomination.GetComponent<Animator>());
        
        yield return new WaitForSeconds(supremeCardBonusAnimLength);
        DamageNumTxt.GetComponent<Animator>().SetBool("Add", false);
        SupremeBonusTxt.SetActive(false);
        yield return new WaitForSeconds(cardClashPowerUseDelay);
    }

    public static int RoShamBoWinner(MagicType type1, MagicType type2)
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
    public static MagicType GetAdvantageMatchupType(MagicType type)
    {
        switch(type)
        {
            case MagicType.Illusion:
                return MagicType.Abjuration;
            case MagicType.Abjuration:
                return MagicType.Evocation;
            case MagicType.Evocation:
                return MagicType.Illusion;
        }
        return MagicType.Abjuration;
    }
    public static MagicType GetDisadvantageMatchupType(MagicType type)
    {
        switch(type)
        {
            case MagicType.Illusion:
                return MagicType.Evocation;
            case MagicType.Evocation:
                return MagicType.Abjuration;
            case MagicType.Abjuration:
                return MagicType.Illusion;
        }
        return MagicType.Abjuration;
    }

    IEnumerator StartDuel(Agent agentWithInitiative)
    {
        yield return new WaitUntil(() => !Deck.GetComponent<Deck>().isShuffling && !Deck.GetComponent<Deck>().isDealing && !isChoosingSupremeCard);
        int rng = Random.Range(0, Enum.GetValues(typeof(MagicSource)).Length);
        SupremeSource = (MagicSource)rng;
        agentWithInitiative = agentForceInitiative == null ? agentWithInitiative : agentForceInitiative;
        agentForceInitiative = null;
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
        RoundTxt.GetComponent<TMP_Text>().text = round < 3 ? "Round " + round : "Final Round";
        RoundTxt.SetActive(true);
        float animLength = RoundTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length;
        yield return new WaitForSeconds(animLength);
        RoundTxt.SetActive(false);
    }
    IEnumerator EndRound()
    {
        Agent winningAgent = playerDamageDone >= enemyDamageDone ? player : AIEnemy;
        if(!manaBust)
        {
            yield return ReturnWonCardsToDeck();
        }
        manaBust = false;
        round++;
        turn = 0;
        currentDuelNum = 0;
        playerDamageDone = 0;
        enemyDamageDone = 0;
        player.ResetMana();
        AIEnemy.ResetMana();
        if(player.points >= player.pointsToWin && AIEnemy.points >= AIEnemy.pointsToWin || round > 3)
        {
            Agent wonAgent = player.points >= AIEnemy.pointsToWin ? player : AIEnemy;
            yield return EndGame(wonAgent);
        } else if(player.points >= player.pointsToWin)
        {
            yield return EndGame(player);
        } else if(AIEnemy.points >= AIEnemy.pointsToWin)
        {
            yield return EndGame(AIEnemy);
        } else
        {
            StartRound(); 
        }
        
    }
    IEnumerator EndGame(Agent winningAgent)
    {
        GameObject WinsTxt;
        EndGamePlayerWinsTxt.GetComponent<TMP_Text>().text = "" + SaveData.instance.numOfWinsPerDifficulty[SaveData.instance.currentDifficulty];
        EndGameEnemyWinsTxt.GetComponent<TMP_Text>().text = "" + SaveData.instance.numOfLossesPerDifficulty[SaveData.instance.currentDifficulty];
        EndGamePlayerDamageTxt.text = $"{player.points} Dmg Dealt";
        EndGameEnemyDamageTxt.text = $"{AIEnemy.points} Dmg Dealt";
        if(winningAgent == player)
        {
            EndGameWinPanel.SetActive(true);
            SaveData.instance.numOfWinsPerDifficulty[SaveData.instance.currentDifficulty]++;
            EndGameWinPanel.transform.Find("WinTxt").GetComponent<TMP_Text>().text = "You Beat The " + AIEnemy.name + "!";
            WinsTxt = EndGamePlayerWinsTxt;
        } else
        {
            EndGameLosePanel.SetActive(true);
            SaveData.instance.numOfLossesPerDifficulty[SaveData.instance.currentDifficulty]++;
            EndGameLosePanel.transform.Find("LoseTxt").GetComponent<TMP_Text>().text = "The " + AIEnemy.name + " Wins";
            WinsTxt = EndGameEnemyWinsTxt;
        }
        WinsTxtObj.SetActive(true);
        WinsTxt.GetComponent<Denomination>().adder = 1; 
        WinsTxt.GetComponent<Animator>().SetBool("UIAdd", true);
        float animLength = winningAgent.GetAnimLengthByName("UIAdd", WinsTxt.GetComponent<Animator>());
        yield return new WaitForSeconds(animLength);
        WinsTxt.GetComponent<Animator>().SetBool("UIAdd", false);
        EndGameButtons.SetActive(true);
    }
    IEnumerator ReturnWonCardsOnManaBust(Agent agentThatBust)
    {
        //Activate Mana Bust Txt
        ManaBustTxt.GetComponent<TMP_Text>().color = agentThatBust == player ? Color.red : Color.blue;
        ManaBustTxt.SetActive(true);
        float manaBustAnimLength = ManaBustTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length;
        
        yield return new WaitForSeconds(manaBustAnimLength);
        ManaBustTxt.SetActive(false);

        //Return the player and enemy's hand to deck
        List<Card> tmpPlayerHand = new List<Card>(player.HandOfCards);
        foreach(Card card in tmpPlayerHand)
        {
            player.RemoveCard(card);
            bool cardFinishedMoving = false;
            Deck.GetComponent<Deck>().AddCardToTopOfDeck(card, card.moveSpeed, () => cardFinishedMoving = true);
            yield return new WaitUntil(() => cardFinishedMoving);
        }
        List<Card> tmpEnemyHand = new List<Card>(AIEnemy.HandOfCards);
        foreach(Card card in tmpEnemyHand)
        {
            AIEnemy.RemoveCard(card);
            bool cardFinishedMoving = false;
            Deck.GetComponent<Deck>().AddCardToTopOfDeck(card, card.moveSpeed, () => cardFinishedMoving = true);
            yield return new WaitUntil(() => cardFinishedMoving);
        }
        yield return new WaitForSeconds(damageAddedToPointsDelay);
        
        //Return WonCards To Deck
        GameObject damageDealtTxt = agentThatBust == player ? EnemyDamageDealtTxt : PlayerDamageDealtTxt;
        damageDealtTxt.SetActive(true);
        damageDealtTxt.GetComponent<TMP_Text>().text = "0";
        int totalDamageDealt = 0;
        yield return CountWonCards(player, damageDealtTxt, PlayerCardsWonTransform, false, (dmg) => totalDamageDealt += dmg);
        yield return CountWonCards(AIEnemy, damageDealtTxt, EnemyCardsWonTransform, false, (dmg) => totalDamageDealt += dmg);
        Agent agentThatDidntBust = agentThatBust == player ? AIEnemy : player;
        damageDealtTxt.SetActive(false);
        yield return new WaitForSeconds(delayBeforeAddingPoints);
        agentThatDidntBust.AddPoints(totalDamageDealt);
        yield return new WaitForSeconds(damageAddedToPointsDelay);
        manaBust = true;
    }
    IEnumerator ReturnWonCardsToDeck()
    {
        // Return Player Cards
        cam.GetComponent<Animator>().SetBool("LookAtPlayerWonCards", true);
        
        yield return new WaitUntil(() => !cam.GetComponent<Animator>().IsInTransition(0) && cam.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("LookAtPlayerWonCards"));
        PlayerDamageDealtTxt.SetActive(true);
        PlayerDamageDealtTxt.GetComponent<TMP_Text>().text = "0";
        int totalPlayerPoints = 0;
        yield return CountWonCards(player, PlayerDamageDealtTxt, PlayerCardsWonTransform, fn: (dmg) => totalPlayerPoints += dmg);
        cam.GetComponent<Animator>().SetBool("LookAtPlayerWonCards", false);
        yield return new WaitForSeconds(delayBeforeAddingPoints);
        player.AddPoints(totalPlayerPoints);
        yield return new WaitForSeconds(damageAddedToPointsDelay);

        // Return Enemy Cards
        //cam.GetComponent<Animator>().SetBool("LookAtEnemyWonCards", true);
        //yield return new WaitUntil(() => !cam.GetComponent<Animator>().IsInTransition(0) && cam.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).IsName("LookAtEnemyWonCards"));
        EnemyDamageDealtTxt.SetActive(true);
        EnemyDamageDealtTxt.GetComponent<TMP_Text>().text = "0";
        int totalEnemyPoints = 0;
        yield return CountWonCards(AIEnemy, EnemyDamageDealtTxt, EnemyCardsWonTransform, fn: (dmg) => totalEnemyPoints += dmg);
        yield return new WaitForSeconds(delayBeforeAddingPoints);
        AIEnemy.AddPoints(totalEnemyPoints);
        yield return new WaitForSeconds(damageAddedToPointsDelay);
        cam.GetComponent<Animator>().SetBool("LookAtEnemyWonCards", false);
    }

    IEnumerator CountWonCards(Agent agent, GameObject DamageDealtTxt, Transform WonCardsTransform, bool makeDmgTxtFalse = true, Action<int> fn = null)
    {
        DamageDealtTxt.GetComponent<Denomination>().PositionInFrontOfCam = true;
        DamageDealtTxt.GetComponent<Animator>().speed = 2;
        int cardDamageStoppedMoving = 0;
        int totalDamageDealt = 0;
        for(int i = agent.WonCards.Count-1; i >= 0; i--)
        {
            if(i % 2 == 0)
            {
                Transform DamageTxt = WonCardsTransform.GetChild(i/2).Find("DamageTxt");
                int damageDealt = int.Parse(DamageTxt.GetComponent<TMP_Text>().text);
                totalDamageDealt += damageDealt;
                DamageTxt.GetComponent<Entity>().Start();
                Vector3 prevPos = DamageTxt.position;
                Quaternion prevRot = DamageTxt.rotation;
                DamageTxt.GetComponent<Entity>().StartMoving(DamageDealtTxt.transform.position, DamageDealtTxt.transform.rotation, useLocalRot: false, fn: () =>
                {
                    DamageTxt.gameObject.SetActive(false);
                    DamageDealtTxt.GetComponent<Denomination>().AddToDenomination();
                    DamageDealtTxt.GetComponent<Denomination>().adder += damageDealt;
                    DamageDealtTxt.GetComponent<Animator>().SetBool("Add", true);
                    StartCoroutine(SetDamageTextAnimToFalse(DamageDealtTxt));
                    DamageTxt.position = prevPos;
                    DamageTxt.rotation = prevRot;
                    cardDamageStoppedMoving++;
                });
            }
            Deck.GetComponent<Deck>().AddCardToTopOfDeck(agent.WonCards[i], speed: agent.WonCards[i].moveSpeed);
            yield return new WaitForSeconds(delayBetweenWonCardsReturnToDeck);
        }
        yield return new WaitUntil(() => cardDamageStoppedMoving >= agent.WonCards.Count/2);
        yield return new WaitUntil(() => !DamageDealtTxt.GetComponent<Animator>().GetBool("Add"));
        yield return new WaitForSeconds(damageAddedUpDelay);
        DamageDealtTxt.GetComponent<Denomination>().PositionInFrontOfCam = false;
        agent.WonCards.Clear();
        DamageDealtTxt.SetActive(!makeDmgTxtFalse);

        fn?.Invoke(totalDamageDealt);
    }
    IEnumerator SetDamageTextAnimToFalse(GameObject DamageDealtTxt)
    {
        float animLength = player.GetAnimLengthByName("Add", DamageDealtTxt.GetComponent<Animator>());
        DamageDealtTxt.GetComponent<Animator>().Play("Add", 0, 0);
        yield return new WaitForSeconds(animLength * DamageDealtTxt.GetComponent<Animator>().speed);
        DamageDealtTxt.GetComponent<Animator>().SetBool("Add", false);
    }
    private void OnApplicationQuit()
    {
        SaveData.instance.Save();
    }
    public void PlayAgain()
    {
        SceneManager.LoadSceneAsync("Game");
    }
    public void MainMenu()
    {
        SceneManager.LoadSceneAsync("MainMenu");
    }
    void Update()
    {
        settings.UpdateSettings();
        if(!paused)
        {
            Time.timeScale = animationSpeed;
        } else { Time.timeScale = 0; }
    }
    public void ChangeAnimationSpeed(float speed)
    {
        animationSpeed = speed;
    }
}
