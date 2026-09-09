using NaughtyAttributes;
using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.Pool;
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
    IObjectPool<AudioSource> sourcePool;
    void Awake()
    {
        instance = this;
        sourcePool = new ObjectPool<AudioSource>(
            () => {return Instantiate(audioSource);}, 
            (AudioSource source) => {source.gameObject.SetActive(true);},
            (AudioSource source) => {source.gameObject.SetActive(false);},
            (AudioSource source) => {Destroy(source.gameObject);}, false, 100); 
            
    }
    public void Play(AudioClip clip, float volume = 1, float pitch = 1, float startTime = 0, float endTime = Mathf.Infinity)
    {
        AudioSource newSource = sourcePool.Get();
        newSource.clip = clip;
        newSource.volume = volume;
        newSource.pitch = pitch;
        newSource.Play((ulong)startTime);
        float deleteSourceTime = endTime == Mathf.Infinity ? clip.length : endTime;
        StartCoroutine(DestroySource(deleteSourceTime, newSource));
    }
    public void Play(SFX sfx)
    {
        if(sfx.clip != null)
        {
            AudioSource newSource = sourcePool.Get();
            newSource.clip = sfx.clip;
            newSource.volume = sfx.volume;
            newSource.pitch = sfx.pitch;
            newSource.Play((ulong)sfx.startTime);
            float deleteSourceTime = sfx.endTime == Mathf.Infinity ? sfx.clip.length : sfx.endTime;
            StartCoroutine(DestroySource(deleteSourceTime, newSource));
        }
    }
    IEnumerator DestroySource(float sec, AudioSource source)
    {
        yield return new WaitForSeconds(sec);
        sourcePool.Release(source);
    } 
}
