using NaughtyAttributes;
using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using System;
[Serializable]
public class SFX
{
    public AudioClip clip;
    public float volume = 1;
    public float pitch = 1;
    public float startTime = 0;
    public float endTime = Mathf.Infinity;
}
public class SoundManager : MonoBehaviour
{
    public static SoundManager instance;
    [SerializeField] AudioSource audioSource;
    void Awake()
    {
        instance = this;
    }
    public void Play(AudioClip clip, float volume = 1, float pitch = 1, float startTime = 0, float endTime = Mathf.Infinity)
    {
        AudioSource newSource = Instantiate(audioSource);
        newSource.clip = clip;
        newSource.volume = volume;
        newSource.pitch = pitch;
        newSource.Play((ulong)startTime);
        float deleteSourceTime = endTime == Mathf.Infinity ? clip.length : endTime;
        StartCoroutine(DeleteAudioSource(deleteSourceTime, newSource));
    }
    public void Play(SFX sfx)
    {
        AudioSource newSource = Instantiate(audioSource);
        newSource.clip = sfx.clip;
        newSource.volume = sfx.volume;
        newSource.pitch = sfx.pitch;
        newSource.Play((ulong)sfx.startTime);
        float deleteSourceTime = sfx.endTime == Mathf.Infinity ? sfx.clip.length : sfx.endTime;
        StartCoroutine(DeleteAudioSource(deleteSourceTime, newSource));
    }
    IEnumerator DeleteAudioSource(float sec, AudioSource source)
    {
        yield return new WaitForSeconds(sec);
        Destroy(source);
    }
    
}
