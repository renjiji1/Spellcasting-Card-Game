using UnityEngine;
using UnityEngine.InputSystem;
public enum MagicSource {Primal, Divine, Arcane};
public class CardSlot : Entity
{
    InputAction selectInput;
    [Header("Card Slot")]
    [SerializeField] public float cardOnSlotYOffset = .002f;
    [SerializeField] public bool isPlayerSlot = true;
    [SerializeField] public GameObject MatchSourceAnim;
    [Header("Card Source")]
    [SerializeField] public MagicSource source;
    [SerializeField] public SFX sourceClashSFX;
    [SerializeField] Sprite primalIcon;
    [SerializeField] Sprite divineIcon;
    [SerializeField] Sprite arcaneIcon;
    public override void Start()
    {
        base.Start();
        selectInput = InputSystem.actions.FindAction("Select");
        switch(source)
        {
            case MagicSource.Divine:
                GetComponent<SpriteRenderer>().sprite = divineIcon;
                break;
            case MagicSource.Primal:
                GetComponent<SpriteRenderer>().sprite = primalIcon;
                break;
            case MagicSource.Arcane:
                GetComponent<SpriteRenderer>().sprite = arcaneIcon;
                break;
        }
    }

    protected override void Update()
    {
        base.Update();
        if(RunUpdate())
        {
            OnHoverOverSlot();
        }
    }
    public void OnHoverOverSlot()
    {
        if(isPlayerSlot && player.isAgentTurn && !player.cardOnSlot)
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if(Physics.Raycast(ray, out hit))
            {
                if(hit.collider == GetComponent<Collider>() && player.selectedCard != null)
                {
                    if(player.highlightedCardSlot != this)
                    {
                        if(player.highlightedCardSlot != null)
                        {
                            player.highlightedCardSlot.OnHoverExit();
                        }
                        OnHoverEnter();
                    }
                    if (selectInput.WasPressedThisFrame())
                    {
                        OnSelect(player.selectedCard); 
                    } 
                } else if(player.highlightedCardSlot == this)
                {
                    OnHoverExit();
                }
            }
        }
    }
    void OnHoverEnter()
    {
        player.highlightedCardSlot = this;
        player.CardMovePreview.SetActive(true);
        player.CardMovePreview.transform.position = transform.position + new Vector3(0, cardOnSlotYOffset, 0);
        player.CardMovePreview.transform.rotation = transform.rotation;
    }
    public void OnHoverExit()
    {
        player.highlightedCardSlot = null;
        player.CardMovePreview.SetActive(false);
    }
    public void OnSelect(Card card)
    {
        player.UseCard(card, this);
    }
}
