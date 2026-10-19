using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;
using TMPro;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using System;
using UnityEngine.Events;

public class SettingsManager : MonoBehaviour
{
    public static SettingsManager instance;
    [NonSerialized] public static UnityEvent<float, float> OnAnimationSpeedChanged = new UnityEvent<float, float>();
    InputAction settingsInput;
    [SerializeField] AudioMixer Mixer;
    [SerializeField] float maxDb = 10;
    [SerializeField] Slider MasterSlider;
    [SerializeField] Slider MusicSlider;
    [SerializeField] Slider SFXSlider;
    [SerializeField] Slider AnimationSpeedSlider;
    [SerializeField] TMP_Text MasterNumTxt;
    [SerializeField] TMP_Text MusicNumTxt;
    [SerializeField] TMP_Text SFXNumTxt;
    [SerializeField] TMP_Text AnimationSpeedTxt;
    float ogMusicVolume = 1;
    float ogAnimationSpeed = 1;
    float animationSpeed = 1;

    void Awake()
    {
        instance = this;
        if(settingsInput == null)
        settingsInput = InputSystem.actions.FindAction("Settings");
    }
    void OnEnable()
    {
        if(SaveData.instance.masterVolume == -1)
        {
            float masterVolume;
            Mixer.GetFloat("Master", out masterVolume);
            masterVolume = Mathf.Pow(10f, (masterVolume - maxDb) / 20f);
            MasterSlider.value = masterVolume;
            MasterNumTxt.GetComponent<TMP_Text>().text = masterVolume.ToString("F2");
        } else
        {
            MasterSlider.value = SaveData.instance.masterVolume;
            OnMasterVolumeChange(SaveData.instance.masterVolume);
        }
        
        if(SaveData.instance.musicVolume == -1)
        {
            float musicVolume;
            Mixer.GetFloat("Music", out musicVolume);
            musicVolume = Mathf.Pow(10f, (musicVolume - maxDb) / 20f);
            MusicSlider.value = musicVolume;
            MusicNumTxt.GetComponent<TMP_Text>().text = musicVolume.ToString("F2");
        } else
        {
            MusicSlider.value = SaveData.instance.musicVolume;
            OnMusicVolumeChange(SaveData.instance.musicVolume);
        }
        
        if(SaveData.instance.SFXVolume == -1)
        {
            float SFXVolume;
            Mixer.GetFloat("SFX", out SFXVolume);
            SFXVolume = Mathf.Pow(10f, (SFXVolume - maxDb) / 20f);
            SFXSlider.value = SFXVolume;
            SFXNumTxt.GetComponent<TMP_Text>().text = SFXVolume.ToString("F2");  
        } else
        {
            SFXSlider.value = SaveData.instance.SFXVolume;
            OnSFXVolumeChange(SaveData.instance.SFXVolume);
        }

        if(SaveData.instance.animationSpeed != -1)
        {
            AnimationSpeedSlider.value = SaveData.instance.animationSpeed;
            OnAnimationSpeedValueChange(SaveData.instance.animationSpeed);
        } else
        {
            AnimationSpeedTxt.GetComponent<TMP_Text>().text = AnimationSpeedSlider.value.ToString("F2");
        }
        
    }
    public void OnMasterVolumeChange(float sliderValue)
    {
        Mixer.SetFloat("Master", Mathf.Log10(sliderValue) * 20 + maxDb);
        SaveData.instance.masterVolume = sliderValue;
        if(sliderValue == 0)
        {
            Mixer.SetFloat("Master", -80);
        }
        MasterNumTxt.GetComponent<TMP_Text>().text = sliderValue.ToString("F2");
    }
    public void OnMusicVolumeChange(float sliderValue)
    {
        Mixer.SetFloat("Music", Mathf.Log10(sliderValue) * 20 + maxDb);
        SaveData.instance.musicVolume = sliderValue;
        if (sliderValue == 0)
        {
            Mixer.SetFloat("Music", -80);
        }
        MusicNumTxt.GetComponent<TMP_Text>().text = sliderValue.ToString("F2");
    }
    public void OnSFXVolumeChange(float sliderValue)
    {
        Mixer.SetFloat("SFX", Mathf.Log10(sliderValue) * 20 + maxDb);
        SaveData.instance.SFXVolume = sliderValue;
        if (sliderValue == 0)
        {
            Mixer.SetFloat("SFX", -80);
        }
        SFXNumTxt.GetComponent<TMP_Text>().text = sliderValue.ToString("F2");
    }
    public void OnAnimationSpeedValueChange(float value)
    {
        SaveData.instance.animationSpeed = value;
        AnimationSpeedTxt.GetComponent<TMP_Text>().text = value.ToString("F2");
        GameManager.instance.ChangeAnimationSpeed(value);
        animationSpeed = value;
    }
    public void MainMenu()
    {
        Time.timeScale = 1;
        SceneManager.LoadSceneAsync("MainMenu");
    }
    public void CloseSettings()
    {
        gameObject.SetActive(false);
        GameManager.paused = false;
        GameManager.ResumeGame.Invoke();
        MusicPlayer.instance.InterruptFade();
        MusicPlayer.instance.GetComponent<AudioSource>().volume = ogMusicVolume;
        if(ogAnimationSpeed != animationSpeed)
        {
            OnAnimationSpeedChanged.Invoke(ogAnimationSpeed, animationSpeed);
        }
        ogAnimationSpeed = animationSpeed;
    }
    public void OpenSettings()
    {
        gameObject.SetActive(true);
        GameManager.paused = true;
        GameManager.PauseGame.Invoke();
        ogMusicVolume = MusicPlayer.instance.GetComponent<AudioSource>().volume;
        MusicPlayer.instance.FadeOut(.4f, 3, true, false);
    }
    public void UpdateSettings()
    {
        Awake();
        if(settingsInput.WasPressedThisFrame())
        {
            if(gameObject.activeSelf)
            {
                CloseSettings(); 
            } else if(!GameManager.paused)
            {
                OpenSettings();
            }
        }
    }
}
