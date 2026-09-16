using NaughtyAttributes;
using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.Pool;
using System;
using Unity.VisualScripting;
[Serializable]
public class SFX
{
    public AudioClip clip;
    public float volume = 1;
    public float pitch = 1;
    public float startTime = 0;
    public float endTime = Mathf.Infinity;
    public bool useRealTimeSeconds = false;
}
class SFXInstance
{
    public AudioSource source;
    public SFX sfx;
}
public class SoundManager : MonoBehaviour
{
    public static SoundManager instance;
    [SerializeField] AudioSource audioSource;
    IObjectPool<SFXInstance> sourcePool;
    List<SFXInstance> allSources = new List<SFXInstance>();
    void Awake()
    {
        instance = this;
        GameManager.PauseGame.AddListener(PauseAllActiveSFX);
        GameManager.ResumeGame.AddListener(ResumeAllActiveSFX);
        sourcePool = new ObjectPool<SFXInstance>(
            () => {
                SFXInstance newInstance =  new SFXInstance { source = Instantiate(audioSource), sfx = null };
                allSources.Add(newInstance);
                return newInstance;
            }, 
            (SFXInstance instance) => {instance.source.gameObject.SetActive(true); instance.source.clip = null;},
            (SFXInstance instance) => {instance.source.gameObject.SetActive(false);},
            (SFXInstance instance) => {Destroy(instance.source.gameObject); }, false, 100); 
            
    }
    public static float GetSFXLength(SFX sfx)
    {
        if(sfx.clip != null)
        {
            float length = sfx.endTime == Mathf.Infinity ? sfx.clip.length : sfx.endTime;
            length /= sfx.pitch;
            return length - sfx.startTime;
        } else
        {
            return 0;
        }
    }
    public void Play(SFX sfx)
    {
        if(sfx.clip != null)
        {
            SFXInstance newSFXInstance = sourcePool.Get();
            AudioSource newSource = newSFXInstance.source;
            newSFXInstance.sfx = sfx;
            newSource.clip = sfx.clip;
            newSource.volume = sfx.volume;
            newSource.pitch = sfx.pitch;
            newSource.Play((ulong)sfx.startTime);
            StartCoroutine(DestroySource(GetSFXLength(sfx), newSFXInstance));
        }
    }
    public void PauseAllActiveSFX()
    {
        foreach(SFXInstance instance in allSources)
        {
            if(!instance.sfx.useRealTimeSeconds)
            {
                instance.source.Pause();
            }
        }
    }
    public void ResumeAllActiveSFX()
    {
        foreach(SFXInstance instance in allSources)
        {
            if(!instance.sfx.useRealTimeSeconds)
            {
                instance.source.UnPause();
            }
        }
    }
    IEnumerator DestroySource(float sec, SFXInstance source)
    {
        if (source.sfx.useRealTimeSeconds)
        {
            yield return new WaitForSecondsRealtime(sec);
        }
        else
        {
            yield return new WaitForSeconds(sec);
        }
        sourcePool.Release(source);
    } 
}
