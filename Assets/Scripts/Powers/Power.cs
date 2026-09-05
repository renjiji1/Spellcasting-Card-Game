using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using System;
using TMPro;
using UnityEngine.Rendering;

public class Power : Entity
{
    protected InputAction selectInput;
    [Header("Power")]
    [SerializeField] protected Agent agent;
    [SerializeField] protected GameObject AmountTxt;
    [SerializeField] public GameObject Panel;
    [SerializeField] protected string nameTxt;
    [SerializeField] protected string description;
    [SerializeField] GameObject highlightedGlow;
    [SerializeField] GameObject canUseGlow;
    [SerializeField] protected Material greyedOutMat;
    [SerializeField] ParticleSystem OnSelectEffect;
    protected Material ogMat;
    [NonSerialized] public Sprite PanelUnselectedSprite;
    public Sprite PanelSelectedSprite;
    [SerializeField] protected Transform showPos;
    [NonSerialized] public bool hasBeenUsedThisTurn = false;
    protected TMP_Text PanelName;
    protected TMP_Text PanelDesc;
    protected TMP_Text PanelAmount;
    protected GameObject PanelRune;
    [NonSerialized] public int amount = 0;
    [NonSerialized] public int cost = 1;
    [Header("Shop Panel")]
    [NonSerialized] public Sprite ShopPanelUnSelectedSprite;
    [SerializeField] public Sprite ShopPanelSelectedSprite;
    [SerializeField] public GameObject ShopPanel;
    [SerializeField] TMP_Text ShopPanelName;
    [SerializeField] TMP_Text ShopPanelDescription;
    [SerializeField] Image ShopPanelRune;
    [SerializeField] TMP_Text ShopPanelAmount;
    [SerializeField] TMP_Text ShopPanelCost;

    public override void Start()
    {
        base.Start();
        selectInput = InputSystem.actions.FindAction("Select");

        PanelName = Panel.transform.Find("Name").GetComponent<TMP_Text>();
        PanelDesc = Panel.transform.Find("Description").GetComponent<TMP_Text>();
        PanelAmount = Panel.transform.Find("Amount").GetComponent<TMP_Text>();
        PanelRune = Panel.transform.Find("Rune").gameObject;

        PanelUnselectedSprite = Panel.GetComponent<SpriteRenderer>().sprite;
        PanelName.text = nameTxt;
        PanelDesc.text = description;
        PanelRune.GetComponent<SpriteRenderer>().sprite = GetComponent<SpriteRenderer>().sprite;
        ogMat = GetComponent<SpriteRenderer>().material;
        GetComponent<SpriteRenderer>().material = greyedOutMat;

        if(agent == player)
        {
            ShopPanelUnSelectedSprite = ShopPanel.GetComponent<Image>().sprite;
            ShopPanelName.text = nameTxt;
            ShopPanelDescription.text = description;
            ShopPanelRune.sprite = GetComponent<SpriteRenderer>().sprite;
            ShopPanelAmount.text = "x"+amount;
            ShopPanelCost.text = ""+cost;
            agent.OnArcanaChanged.AddListener(OnArcanaChange);
        }
        
    }

    protected override void Update()
    {
        base.Update();
        
        bool beginningOfPlayersTurn = player.cardBeingPlayed == null ? player.isAgentTurn : player.isAgentTurn && !player.cardBeingPlayed.hasBeenPlayed && !player.cardBeingPlayed.isBeingPlayed;
        bool beginningOfEnemysTurn = AIEnemy.cardBeingPlayed == null ? AIEnemy.isAgentTurn : AIEnemy.isAgentTurn && !AIEnemy.cardBeingPlayed.hasBeenPlayed && !AIEnemy.cardBeingPlayed.isBeingPlayed;
        if(beginningOfPlayersTurn || beginningOfEnemysTurn)
        {
            OnHoverOverRune();
            if(amount > 0 && agent.isAgentTurn)
            {
                canUseGlow.SetActive(true);
            }
        } else
        {
            canUseGlow.SetActive(false);
        }
    }
    public void AddPower()
    {
        amount++;
        AmountTxt.SetActive(true);
        AmountTxt.GetComponent<TMP_Text>().text = "x" + amount;
        if(agent == player) ShopPanelAmount.text = "x"+amount;
        PanelAmount.text = "x" + amount;
        GetComponent<SpriteRenderer>().material = ogMat;
    }
    public bool BuyPower()
    {
        Debug.Log($"{cost}");
        bool canBuy = agent.CanSpendArcana(cost);
        if(canBuy)
        {
            int prevCost = cost;
            cost++;
            if(agent == player) ShopPanelCost.text = ""+cost;
            agent.SpendArcana(prevCost);
            AddPower();
        } else
        {
            
        }
        return canBuy;
    }
    void OnArcanaChange(int arcana)
    {
        if(arcana >= cost)
        {
            ShopPanelCost.color = Color.white;
        } else
        {
            ShopPanelCost.color = Color.red;
        }
    }
    public void OnHoverOverRune()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if(Physics.Raycast(ray, out hit))
        {
            if(hit.collider == GetComponent<Collider>())
            {
                if(player.highlightedPower != this && amount > 0)
                {
                    if(player.highlightedPower != null)
                    {
                        player.highlightedPower.OnHoverExit();
                    }
                    //On Hover Enter
                    player.highlightedPower = this;
                    highlightedGlow.SetActive(true);
                    ActivatePanel(showPos.position);
                }
                if (selectInput.WasPressedThisFrame() && agent == player && player.highlightedPower == this)
                {
                    if(player.isAgentTurn && !player.cardOnSlot && !hasBeenUsedThisTurn && !agent.hasUsedPowerThisTurn)
                    {
                        OnSelect();
                    } else if(agent.hasUsedPowerThisTurn)
                    {
                        StartCoroutine(ShowCantUsePowerTxt("Already Used A Power"));
                    } else if(hasBeenUsedThisTurn)
                    {
                        StartCoroutine(ShowCantUsePowerTxt("Has Already Been Used"));
                    } else
                    {
                        StartCoroutine(ShowCantUsePowerTxt("Can Only Use At The Beginning Of Your Turn"));
                    }
                } 
            } else if(player.highlightedPower == this)
            {
                OnHoverExit();
            }
        }
    }
    public void ActivatePanel(Vector3 pos, bool dontShowAmountTxt = false)
    {
        Panel.SetActive(true);
        Panel.GetComponent<SpriteRenderer>().sprite = PanelUnselectedSprite;
        Panel.transform.position = pos;
        Panel.transform.rotation = Quaternion.Euler(cam.transform.rotation.eulerAngles.x, cam.transform.rotation.eulerAngles.y, 180);
        if(amount > 0)
        {
            PanelAmount.gameObject.SetActive(true);
        }
        if(dontShowAmountTxt)
        {
            PanelAmount.gameObject.SetActive(false);
        }
    }
    public void OnHoverExit()
    {
        Panel.SetActive(false);
        highlightedGlow.SetActive(false);
        player.highlightedPower = null;
    }
    public virtual void OnSelect()
    {
        amount--;
        agent.hasUsedPowerThisTurn = true;
        if(amount <= 0)
        {
            AmountTxt.SetActive(false);
            PanelAmount.gameObject.SetActive(false);
            GetComponent<SpriteRenderer>().material = greyedOutMat;
        }
        AmountTxt.GetComponent<TMP_Text>().text = "x" + amount;
        PanelAmount.text = "x" + amount;
        hasBeenUsedThisTurn = true;
        OnSelectEffect.Play(true);
        OnHoverExit();
        StartCoroutine(ActivatePowerNameTxt());
    }
    IEnumerator ActivatePowerNameTxt()
    {
        gameManager.PowerNameTxt.text = nameTxt;
        gameManager.PowerNameTxt.GetComponent<TMP_Text>().color = agent == player ? Color.blue : Color.red;
        gameManager.PowerNameTxt.gameObject.SetActive(false);
        gameManager.PowerNameTxt.gameObject.SetActive(true);
        float animLength = GetAnimLengthByName("ActivatePowerTxt", gameManager.PowerNameTxt.GetComponent<Animator>());
        
        yield return new WaitForSeconds(animLength);
        if(gameManager.PowerNameTxt.text == nameTxt)
        {
            gameManager.PowerNameTxt.gameObject.SetActive(false);
        }
    }
    protected IEnumerator ShowCantUsePowerTxt(string txt)
    {
        gameManager.CantUsePowerTxt.GetComponent<TMP_Text>().text = txt;
        gameManager.CantUsePowerTxt.SetActive(true);
        float animLength = gameManager.CantUsePowerTxt.GetComponent<Animator>().GetCurrentAnimatorClipInfo(0)[0].clip.length;
        yield return new WaitForSeconds(animLength);
        gameManager.CantUsePowerTxt.SetActive(false);
    }
}
