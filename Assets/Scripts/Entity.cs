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
    protected Camera cam;
    protected Player player;
    protected AI AIEnemy;
    [Header("Depth Projection Settings")]
    [SerializeField] protected bool depthProjection = true;
    [ShowIf("depthProjection")]
    [SerializeField] public float thickness = .004f;
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
    [Header("Move")]
    [SerializeField] public float moveSpeed = 8;
    [SerializeField] protected GameObject moveRotPivot;
    protected float moveTimer = 0;
    protected Vector3 moveInitialPos;
    protected Quaternion moveInitialRot;
    protected Vector3 moveTargetPos;
    protected Quaternion moveTargetRot;
    protected float currentSpeed = 0;
    protected Action OnMoveFinished;
    protected bool isMoving = false;
    protected bool startHasRan = false;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    protected virtual void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        col = GetComponent<Collider2D>();
        cam = Camera.main.GetComponent<Camera>();
        gameManager = GameManager.instance;
        player = gameManager.player;
        AIEnemy = gameManager.AIEnemy;
        if(moveRotPivot == null) moveRotPivot = gameObject;
        if (depthProjection)
        {
            currentSprite = FrontSprite.GetComponent<SpriteRenderer>().sprite;   
            for (int i = 0; i < thickness / projectionOffset; i++)
            {
                GameObject projectionSpriteInstance = Instantiate(ProjectionSprite, transform.position, transform.rotation, FrontSprite.transform);
                projectionSpriteInstance.transform.localPosition = new Vector3(0, 0, projectionOffset * (i + 1));
                projectionSpriteInstance.transform.localRotation = Quaternion.identity;
                projectionSpriteInstance.GetComponent<SpriteRenderer>().sprite = currentSprite;
                projectionSprites.Add(projectionSpriteInstance);
            }
            if(BackSprite != null)
            {
                BackSprite.transform.localPosition = new Vector3(0, 0, -thickness * 2 - projectionOffset);
            }
        }
        startHasRan = true;
    }

    // Update is called once per frame
    protected virtual void Update()
    {
        if (RunUpdate())
        {
            if(depthProjection)
            {
                UpdateDepthProjections();
            }
            Move();
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
    protected virtual void Move()
    { 
        if(isMoving && moveTimer < 1)
        {
            isMoving = true;
            moveTimer += Time.deltaTime * currentSpeed;
            moveRotPivot.transform.localRotation = Quaternion.Lerp(moveInitialRot, moveTargetRot, moveTimer);
            transform.position = Vector3.Lerp(moveInitialPos, moveTargetPos, moveTimer);
        } else if(isMoving)
        {
            isMoving = false;
            moveTimer = 0;
            OnMoveFinished?.Invoke();
            OnMoveFinished = null;
        }
    }
    public void StartMoving(Vector3 pos, Quaternion? rot = null, float? speed = null, Action fn = null)
    {
        OnMoveFinished?.Invoke();
        
        moveInitialRot = moveRotPivot.transform.localRotation;
        moveInitialPos = transform.position;
        currentSpeed = speed ?? moveSpeed;
        moveTargetPos = pos;
        moveTargetRot = rot ?? moveInitialRot;
        OnMoveFinished = fn;
        moveTimer = 0;
        isMoving = true;
    }
    protected virtual bool RunUpdate()
    {
        return !gameManager.paused;
    }
    public float GetTotalMoveTime(float speed)
    {
        float totalMoveFrames = 1 / (speed * Time.deltaTime);
        float totalMoveTime = totalMoveFrames * Time.deltaTime;
        return totalMoveTime;
    }
    public float GetAnimLengthByName(string clipName, Animator anim = null)
    {
        if(anim == null)
        {
            anim = GetComponent<Animator>();
        }
        if(anim == null)
        {
            return 0f;
        }
        // Get all clips assigned to the Animator
        AnimationClip[] clips = anim.runtimeAnimatorController.animationClips;

        foreach (AnimationClip clip in clips)
        {
            if (clip.name == clipName)
            {
                return clip.length;
            }
        }
        return 0f;
    }
}
