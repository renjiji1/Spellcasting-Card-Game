using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;

public class MainMenuManager : MonoBehaviour
{
    [SerializeField] SettingsManager settings;
    [SerializeField] Slider difficultySlider;

    void Start()
    {
        SaveData.instance.Load();
        difficultySlider.value = SaveData.instance.currentDifficulty;
    }
    void Update()
    {
        settings.UpdateSettings();
    }

    public void SetDifficulty(float difficulty)
    {
        SaveData.instance.currentDifficulty = (int)difficulty;
    }

    public void Play()
    {
        SceneManager.LoadSceneAsync("Game");
    }
    public void Quit()
    {
        Application.Quit();
    }
    private void OnApplicationQuit()
    {
        Debug.Log("Saved");
        SaveData.instance.Save();
    }
}
