using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Debug = UnityEngine.Debug;
using Random = UnityEngine.Random;
using Object = UnityEngine.Object;
using NaughtyAttributes;

public class Entity : MonoBehaviour
{
    protected Rigidbody2D rb;
    protected Animator anim;
    protected Collider2D col;
    protected GameManager gameManager;
    [Header("Depth Projection Settings")]
    [SerializeField] protected bool depthProjection = true;
    [ShowIf("depthProjection")]
    [SerializeField] protected float thickness = .004f;
    [ShowIf("depthProjection")]
    [SerializeField] protected float projectionOffset = .0005f;
    [ShowIf("depthProjection")] 
    [SerializeField] protected GameObject ProjectionSprite;
    [ShowIf("depthProjection")]
    [SerializeField] protected GameObject FrontSprite;
    [ShowIf("depthProjection")]
    [SerializeField] protected GameObject BackSprite;
    Sprite currentSprite;
    protected List<GameObject> projectionSprites = new List<GameObject>();
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    protected virtual void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        col = GetComponent<Collider2D>();
        gameManager = Object.FindObjectsByType<GameManager>(FindObjectsSortMode.None)[0];
        if (depthProjection)
        {
            currentSprite = FrontSprite.GetComponent<SpriteRenderer>().sprite;   
            for (int i = 0; i < thickness / projectionOffset; i++)
            {
                GameObject projectionSpriteInstance = Instantiate(ProjectionSprite, transform.position, transform.rotation, FrontSprite.transform);
                projectionSpriteInstance.transform.localPosition = new Vector3(0, 0, projectionOffset * (i + 1));
                projectionSpriteInstance.GetComponent<SpriteRenderer>().sprite = currentSprite;
                projectionSprites.Add(projectionSpriteInstance);
            }
            BackSprite.transform.localPosition = new Vector3(0, 0, -thickness*2);
        }
    }

    // Update is called once per frame
    protected virtual void Update()
    {
        if (RunUpdate())
        {
            UpdateDepthProjections();
        }
    }
    protected virtual void UpdateDepthProjections()
    {
        if(FrontSprite.GetComponent<SpriteRenderer>().sprite != currentSprite)
        {
            currentSprite = FrontSprite.GetComponent<SpriteRenderer>().sprite;
            foreach(GameObject projection in projectionSprites)
            {
                projection.GetComponent<SpriteRenderer>().sprite = currentSprite;
            }
        }
    }
    protected virtual bool RunUpdate()
    {
        return !gameManager.paused;
    }
}
