using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using TMPro;
using Random = UnityEngine.Random;
using UnityEngine.Events;
using Microsoft.Unity.VisualStudio.Editor;

public class MusicPlayer : MonoBehaviour
{
    public static MusicPlayer instance;
    AudioSource source;
    [SerializeField] SFX BattleTheme;
    [SerializeField] SFX AmbientTheme;
    [SerializeField] int dmgDoneInASingleTurnToStartBattleTheme = 20;
    [SerializeField] int consecutivePowerUsesToStartBattleTheme = 3;
    int priorConsecutivePowerUses = 0;
    int consecutivePowerUses = 0;
    [SerializeField] float battleThemePlayDuration = 20;
    bool playBattleThemeUntilRoundEnd = false;
    [SerializeField] int manaToStartBattleTheme = 3;
    [SerializeField] int totalDamageToStartBattleTheme = 40;

    float startingVolume;
    float endingVolume;
    [SerializeField] float fadeSpeed = 5;
    float fadeTimer = -1;
    void Awake()
    {
        instance = this;
        source = GetComponent<AudioSource>();
        GameManager.CardClashFinished.AddListener(() =>
        {
            // Reset Consecutive Power Uses
            if(consecutivePowerUses <= priorConsecutivePowerUses)
            {
                consecutivePowerUses = 0;
            }
            priorConsecutivePowerUses = consecutivePowerUses;

            // Check Damage Threshold
            if(GameManager.player.acculumatedDamagePerRound >= totalDamageToStartBattleTheme) StartCoroutine(PlayTheme(BattleTheme, true));

            // Check Mana Threshold
            if(GameManager.player.mana <= manaToStartBattleTheme) StartCoroutine(PlayTheme(BattleTheme, true));
        });
    }

    void Update()
    {
        if(fadeTimer >= 0)
        {
            source.volume = Mathf.Lerp(startingVolume, endingVolume, fadeTimer);
            fadeTimer += Time.deltaTime * fadeSpeed;
            if(fadeTimer >= 1) fadeTimer = -1;
        }
    }

    public void DamageDoneInATurn(int dmg)
    {
        if(dmg >= dmgDoneInASingleTurnToStartBattleTheme) StartCoroutine(PlayTheme(BattleTheme, false));
    }
    public void UsedPower()
    {
        consecutivePowerUses++;
        if(consecutivePowerUses >= consecutivePowerUsesToStartBattleTheme) StartCoroutine(PlayTheme(BattleTheme, false));
    }
    public void PlayAmbientTheme() {StartCoroutine(PlayTheme(AmbientTheme, false));}
    public IEnumerator PlayTheme(SFX sfx, bool playBattleThemeUntilRoundEnd)
    {
        this.playBattleThemeUntilRoundEnd = playBattleThemeUntilRoundEnd;
        if(sfx.clip != null && source.clip != sfx.clip)
        {
            FadeOut();
            yield return new WaitUntil(() => fadeTimer < 0);
            float time = source.time;
            source.clip = sfx.clip;
            source.volume = sfx.volume;
            source.pitch = sfx.pitch;
            source.Play((ulong)time);
            FadeIn();
            if(!playBattleThemeUntilRoundEnd && sfx != AmbientTheme)
            {
                StartCoroutine(WaitToSetAmbientMusic(battleThemePlayDuration)); 
            }
        }
    }
    public void FadeOut()
    {
        fadeTimer = 0;
        endingVolume = 0;
        startingVolume = source.volume;
    }
    public void FadeIn()
    {
        fadeTimer = 0;
        endingVolume = 1;
        startingVolume = source.volume;
    }
    IEnumerator WaitToSetAmbientMusic(float sec)
    {
        yield return new WaitForSeconds(sec);
        if(!playBattleThemeUntilRoundEnd)
        {
            StartCoroutine(PlayTheme(AmbientTheme, false));
        }
    }
}
