using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;

public class MainMenuManager : MonoBehaviour
{
    [SerializeField] SettingsManager settings;
    [SerializeField] Slider difficultySlider;
    [SerializeField] GameObject[] DifficultyTxts;

    void Start()
    {
        SaveData.instance.Load();
        difficultySlider.value = SaveData.instance.currentDifficulty;
        DifficultyTxts[SaveData.instance.currentDifficulty].SetActive(true);
    }
    void Update()
    {
        settings.UpdateSettings();
    }

    public void SetDifficulty(float difficulty)
    {
        DifficultyTxts[SaveData.instance.currentDifficulty].SetActive(false);
        SaveData.instance.currentDifficulty = (int)difficulty;
        DifficultyTxts[(int)difficulty].SetActive(true);
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
