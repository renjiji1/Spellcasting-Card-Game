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
    [NonSerialized] public int round = 1;
    [SerializeField] int roundWinsToWin = 3;
    [NonSerialized] public bool isChoosingSupremeCard = false;
    [NonSerialized] public int turn = 0; // number of turns that happened in the current duel
    [NonSerialized] public GameObject currentPlayer; // the player whose turn it is
    [Header("Supreme Card")]
    [NonSerialized] public Card SupremeCard;
    [SerializeField] Transform SupremeCardSpawnPoint;
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

    public const int maxDuels = 10;
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
        yield return new WaitForSeconds(cardClashEnterDelay);
        bool cardsInPositionForClash = false;
        player.cardBeingPlayed.StartMoving(cam.transform.position + cam.transform.forward * cardClashDistanceFromCamera + cam.transform.right * -cardClashXOffset, cam.transform.rotation, fn: () =>
        {
            cardsInPositionForClash = true;
        });
        int enemyDenominationAdder = 0;
        int playerDenominationAdder = 0;
        yield return new WaitUntil(() => cardsInPositionForClash);
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
        if(playerWon)
        {
            AIEnemy.cardBeingPlayed.StartMoving(PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).position, PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).rotation, fn: () =>
            {
                cardsMovedToPosition++;
            });
            player.cardBeingPlayed.StartMoving(PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("WinningCard").position, PlayerCardsWonTransform.GetChild(player.WonCards.Count/2).Find("WinningCard").rotation, fn: () =>
            {
                cardsMovedToPosition++;
            });
        } else
        {
            AIEnemy.cardBeingPlayed.StartMoving(EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("WinningCard").position, EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).Find("WinningCard").rotation, fn: () =>
            {
                cardsMovedToPosition++;
            });
            player.cardBeingPlayed.StartMoving(EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).position, EnemyCardsWonTransform.GetChild(AIEnemy.WonCards.Count/2).rotation, fn: () =>
            {
                cardsMovedToPosition++;
            });
        }

        yield return new WaitUntil(() => cardsMovedToPosition >= 2);
        if(currentDuelNum > maxDuels)
        {
            StartCoroutine(EndRound());
        } else
        {
            StartCoroutine(StartDuel());
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
        yield return new WaitForSeconds(cardClashTieDelay);
        CardClashTiePlayerTypeProjection.SetActive(true);
        CardClashTiePlayerTypeProjection.GetComponent<SpriteRenderer>().sprite = player.cardBeingPlayed.transform.Find($"{player.cardBeingPlayed.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
        CardClashTiePlayerTypeProjection.transform.position = player.cardBeingPlayed.transform.position + cam.transform.up * CardClashTieProjectionOffsetY;
        CardClashTiePlayerTypeProjection.transform.rotation = player.cardBeingPlayed.transform.Find($"{player.cardBeingPlayed.frontPath}").rotation;

        CardClashTieEnemyTypeProjection.SetActive(true);
        CardClashTieEnemyTypeProjection.GetComponent<SpriteRenderer>().sprite = AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
        CardClashTieEnemyTypeProjection.transform.position = AIEnemy.cardBeingPlayed.transform.position + cam.transform.up * CardClashTieProjectionOffsetY;
        CardClashTieEnemyTypeProjection.transform.rotation = AIEnemy.cardBeingPlayed.transform.Find($"{AIEnemy.cardBeingPlayed.frontPath}").rotation;
        
        Vector3 projectionTargetPos = cam.transform.position + cam.transform.forward * cardClashDistanceFromCamera + cam.transform.up * CardClashTieProjectionOffsetY;
        bool typeProjectionsFinishedMoving = false;
        CardClashTiePlayerTypeProjection.GetComponent<Entity>().StartMoving(projectionTargetPos, CardClashTiePlayerTypeProjection.transform.rotation, fn: () =>
        {
            typeProjectionsFinishedMoving = true;
        });
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

    IEnumerator StartDuel()
    {
        yield return new WaitUntil(() => !Deck.GetComponent<Deck>().isShuffling && !Deck.GetComponent<Deck>().isDealing && !isChoosingSupremeCard);
        currentPlayer.GetComponent<Agent>().StartTurn();
    }
    void StartRound()
    {
        Deck.GetComponent<Deck>().RunStart();
        StartCoroutine(Deck.GetComponent<Deck>().StartShuffle());
        RoundTxt.GetComponent<TMP_Text>().text = "Round " + round;
        RoundTxt.SetActive(true);
        StartCoroutine(DeactivateRoundTxt());
        StartCoroutine(ChooseNewSupremeCard());
        StartCoroutine(StartDuel());
    }
    IEnumerator ChooseNewSupremeCard()
    {
        yield return new WaitUntil(() => !Deck.GetComponent<Deck>().isShuffling && !Deck.GetComponent<Deck>().isDealing);
        isChoosingSupremeCard = true;
        bool canChooseSupremeCard = true;
        if(SupremeCard != null)
        {
            StartCoroutine(Deck.GetComponent<Deck>().InsertCardRandomlyIntoDeck(SupremeCard, fn: () =>
            {
                SupremeCard = null;
                canChooseSupremeCard = true;
            }));

        } else {canChooseSupremeCard = true;}
        yield return new WaitUntil(() => canChooseSupremeCard);
        StartCoroutine(Deck.GetComponent<Deck>().TakeCardRandomlyFromDeck(SupremeCardSpawnPoint.position, targetRot: Quaternion.Euler(90,0,0), fn: (card) =>
        {
            SupremeCard = card;
            SupremeCardSpawnPoint.transform.Find("TypeProjection").GetComponent<SpriteRenderer>().sprite = card.transform.Find($"{card.frontPath}/SpellTypeIcon").GetComponent<SpriteRenderer>().sprite;
            SupremeCardSpawnPoint.transform.Find("TypeProjection").gameObject.SetActive(true);
            isChoosingSupremeCard = false;
        }));
    }
    IEnumerator DeactivateRoundTxt()
    {
        float animLength = RoundTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length;
        yield return new WaitForSeconds(animLength);
        RoundTxt.SetActive(false);
    }
    IEnumerator EndRound()
    {
        int mostWonCardsCount = player.WonCards.Count > AIEnemy.WonCards.Count ? player.WonCards.Count : AIEnemy.WonCards.Count;
        for(int i = mostWonCardsCount-1; i >= 0; i--)
        {
            if(player.WonCards.Count > i)
            {
                bool playerWonCardReturnedToDeck = false;
                Deck.GetComponent<Deck>().AddCardToTopOfDeck(player.WonCards[i], speed: player.WonCards[i].moveSpeed, fn: () =>
                {
                    playerWonCardReturnedToDeck = true;
                });
                yield return new WaitUntil(() => playerWonCardReturnedToDeck);
            }
            if(AIEnemy.WonCards.Count > i)
            {
                bool enemyWonCardReturnedToDeck = false;
                Deck.GetComponent<Deck>().AddCardToTopOfDeck(AIEnemy.WonCards[i], speed: AIEnemy.WonCards[i].moveSpeed, fn: () =>
                {
                    enemyWonCardReturnedToDeck = true;
                });
                yield return new WaitUntil(() => enemyWonCardReturnedToDeck);
            }
        }
        round++;
        turn = 0;
        currentDuelNum = 0;
        if(player.roundWins >= 3)
        {
            player.WinRound();
            AIEnemy.LoseRound();
        } else if(AIEnemy.roundWins >= 3)
        {
            AIEnemy.WinRound();
            player.LoseRound();
        } else
        {
           StartRound(); 
        }
    }
    void Update()
    {
        
    }
}
