using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using System;
using TMPro;
using Random = UnityEngine.Random;

public class Player : Agent
{
    InputAction ShopInput;
    public GameObject CardMovePreview;
    [SerializeField] Vector3 cardPosDifference = new Vector3(.2f, 0, .005f);
    [NonSerialized] public bool waitForDuelReadyUp = false;
    [NonSerialized] public bool readyForDuel = false;
    [NonSerialized] public Card highlightedCard;
    [NonSerialized] public Card selectedCard;
    [NonSerialized] public CardSlot highlightedCardSlot;
    [NonSerialized] public Power highlightedPower;
    [SerializeField] Transform[] powerPanelsPoses;
    [SerializeField] GameObject Shop;
    [SerializeField] TMP_Text ShopArcanaTxt;
    Sprite ArcanaCrystalOgSprite;
    [SerializeField] Sprite ArcanaCrystalHighlightedSprite;
    GameObject highlightedPowerPanel;
    float ogMusicVolume = 1;
    public override void Start()
    {
        base.Start();
        ShopInput = InputSystem.actions.FindAction("Shop");
        OnArcanaChanged.AddListener((arcana) => {ShopArcanaTxt.text = ""+arcana;});
        ArcanaCrystalOgSprite = ArcanaCrystal.GetComponent<SpriteRenderer>().sprite;
    }

    protected override void Update()
    {
        base.Update();
        UpdateShop();
        if(RunUpdate())
        {
            OnHoverOverArcanaCrystal();
            if(isAgentTurn)
            {
                foreach(Card card in HandOfCards)
                {
                    if(!card.hasBeenPlayed && !card.isBeingPlayed)
                    {
                        card.OnHoverOverCard();
                    } 
                }
            }
        }
        
    }
    public override void UseCard(Card card, CardSlot slot, Action fn = null)
    {
        base.UseCard(card, slot, fn);
        card.HandTransform.position = card.ogHandPos;
        if(!gameManager.Deck.GetComponent<Deck>().isDealing)
        {
            List<Card> newHand = new List<Card>(HandOfCards);
            newHand.Remove(card);
            ReOrderCards(newHand);
        }
    }
    protected override IEnumerator WaitEndTurn(Card card, CardSlot slot, bool endTurn = true)
    {
        if(cardMatchesSupremeSource)
        {
            CardMovePreview.SetActive(false);
            slot.MatchSourceAnim.SetActive(true);
            SoundManager.instance.Play(matchSourceSFX);
            float animLength = GetAnimLengthByName("MatchAnim", slot.MatchSourceAnim.GetComponent<Animator>());
            float waitTime = animLength >= matchSourceSFX.clip.length ? animLength : matchSourceSFX.clip.length;
            yield return new WaitForSeconds(waitTime);
            slot.MatchSourceAnim.SetActive(false);
        }
        StartCoroutine(base.WaitEndTurn(card, slot));
    }
    public void OnShopPanelEnter(Power power)
    {
        OnShopPanelExit(power);
        SoundManager.instance.Play(hoverUISFX);
        power.ShopPanel.GetComponent<Image>().sprite = power.PanelSelectedSprite;
        highlightedPowerPanel = power.ShopPanel;
    }
    public void OnShopPanelExit(Power power)
    {
        if(highlightedPowerPanel != null)
        {
            highlightedPowerPanel.GetComponent<Image>().sprite = power.PanelUnselectedSprite;
            highlightedPowerPanel = null;
        }
    }
    public void OnShopPanelSelect(Power power)
    {
        if(power.BuyPower())
        {
            gameManager.LevelUpTxt.SetActive(false);
            SoundManager.instance.Play(buyPowerSFX);
        } 
    }
    void UpdateShop()
    {
        if(ShopInput.WasPressedThisFrame())
        {
            if(!Shop.activeSelf && !GameManager.paused)
            {
                OpenShop();
            } else if(Shop.activeSelf)
            {
                CloseShop();
            }
        }
    }
    public void OpenShop()
    {
        OnArcanaChanged.Invoke(arcana);
        Shop.SetActive(true);
        GameManager.paused = true;
        GameManager.PauseGame.Invoke();
        ogMusicVolume = MusicPlayer.instance.GetComponent<AudioSource>().volume;
        MusicPlayer.instance.FadeOut(.4f, 3, true, false);
    }
    public void CloseShop()
    {
        Shop.SetActive(false);
        GameManager.paused = false;
        GameManager.ResumeGame.Invoke();
        MusicPlayer.instance.FadeIn(ogMusicVolume, 3, true, false);
    }
    public override IEnumerator AddArcana(Action finishedFn = null)
    {
        yield return base.AddArcana(finishedFn);
        if(cardMatchesSupremeSource)
        {
            finishedFn?.Invoke(); 
        }
    }
    public void ReOrderCards(List<Card> cards = null)
    {
        if(cards == null) cards = HandOfCards;

        List<Card> orderedHandOfCards = Deck.OrderCards(cards);
        Vector3 currentPos = new Vector3(((float)orderedHandOfCards.Count-1)/2 * cardPosDifference.x, 0, 0);
        for(int i = 0; i < orderedHandOfCards.Count; i++)
        {
            orderedHandOfCards[i].HandTransform.localPosition = currentPos;
            currentPos += new Vector3(-cardPosDifference.x, cardPosDifference.y, cardPosDifference.z);
            orderedHandOfCards[i].StartMoving(orderedHandOfCards[i].HandTransform.position);
        }
    }
    

    public void OnHoverOverArcanaCrystal()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if(Physics.Raycast(ray, out hit))
        {
            if(hit.collider == ArcanaCrystal.GetComponent<Collider>())
            {
                //hover enter
                ArcanaCrystal.GetComponent<SpriteRenderer>().sprite = ArcanaCrystalHighlightedSprite;
                if (selectInput.WasPressedThisFrame())
                {
                    //on select
                    ArcanaCrystal.GetComponent<SpriteRenderer>().sprite = ArcanaCrystalOgSprite;
                    OpenShop();
                } 
            } else 
            {
                //hover exit
                ArcanaCrystal.GetComponent<SpriteRenderer>().sprite = ArcanaCrystalOgSprite;
            }
        } else
        {
            //hover exit
            ArcanaCrystal.GetComponent<SpriteRenderer>().sprite = ArcanaCrystalOgSprite;
        }
    }
}