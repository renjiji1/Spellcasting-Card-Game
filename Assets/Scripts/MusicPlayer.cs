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
    float currentFadeSpeed;
    float fadeTimer = -1;
    bool fadeUseUnscaledTime = false;
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
            float time = fadeUseUnscaledTime ? Time.unscaledDeltaTime : Time.deltaTime;
            fadeTimer += time * currentFadeSpeed;
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
    public void PlayAmbientTheme(float fadeSpeed = -1, bool fadeOut = true) {StartCoroutine(PlayTheme(AmbientTheme, false, true, fadeSpeed, fadeOut));}
    public IEnumerator PlayTheme(SFX sfx, bool playBattleThemeUntilRoundEnd, bool restartSong = false, float fadeSpeed = -1, bool fadeOut = true)
    {
        this.playBattleThemeUntilRoundEnd = playBattleThemeUntilRoundEnd;
        if(sfx.clip != null && (source.clip != sfx.clip || restartSong))
        {
            if(fadeOut) {FadeOut(fadeSpeed: fadeSpeed);} else {source.volume = 0;}
            yield return new WaitUntil(() => fadeTimer < 0);
            float time = source.time;
            source.clip = sfx.clip;
            source.pitch = sfx.pitch;
            source.Play((ulong)time);
            FadeIn(sfx.volume, fadeSpeed: fadeSpeed);
            if(!playBattleThemeUntilRoundEnd && sfx != AmbientTheme)
            {
                StartCoroutine(WaitToSetAmbientMusic(battleThemePlayDuration)); 
            }
        }
    }
    public void FadeOut(float finalVolume = 0, float fadeSpeed = -1, bool useUnscaledTime = false, bool interruptOtherFade = true)
    {
        if(!interruptOtherFade && fadeTimer != -1) return;
        fadeTimer = 0;
        endingVolume = finalVolume;
        startingVolume = source.volume;
        currentFadeSpeed = fadeSpeed == -1 ? this.fadeSpeed : fadeSpeed;
        fadeUseUnscaledTime = useUnscaledTime;
    }
    public void FadeIn(float finalVolume = 1, float fadeSpeed = -1, bool useUnscaledTime = false, bool interruptOtherFade = true)
    {
        if(!interruptOtherFade && fadeTimer != -1) return;
        fadeTimer = 0;
        endingVolume = finalVolume;
        startingVolume = source.volume;
        currentFadeSpeed = fadeSpeed == -1 ? this.fadeSpeed : fadeSpeed;
        fadeUseUnscaledTime = useUnscaledTime;
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
