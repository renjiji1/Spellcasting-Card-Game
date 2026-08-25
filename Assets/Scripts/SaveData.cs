using System.IO;
using UnityEngine;

public class SaveData
{
    public static SaveData instance = new SaveData();
    public int currentDifficulty;
    public float masterVolume = -1;
    public float SFXVolume = -1;
    public float musicVolume = -1;
    public float animationSpeed = -1;
    public int[] numOfWinsPerDifficulty = new int[5];
    public int[] numOfLossesPerDifficulty = new int[5];
    private string savePath;

    private bool SetPath()
    {
        // Automatically selects the correct persistent folder for PC, Mobile, or Console
        if (string.IsNullOrEmpty(savePath))
        {
            savePath = Path.Combine(Application.persistentDataPath, "ArcaneWordSaveData.json");
        }
        return !string.IsNullOrEmpty(savePath);
    }
    public void Save()
    {
        if (!SetPath()) return;
        string json = JsonUtility.ToJson(this);
        File.WriteAllText(savePath, json);
    }
    public void Load()
    {
        if (!SetPath()) return;
        if (File.Exists(savePath))
        {
            string json = File.ReadAllText(savePath);
            JsonUtility.FromJsonOverwrite(json, this);
        }
    }

}