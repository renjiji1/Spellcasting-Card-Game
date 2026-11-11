using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.InputSystem;
using System;
using TMPro;
using NaughtyAttributes;

public class TutorialManager : MonoBehaviour
{
    [SerializeField, ReorderableList] List<GameObject> tutorialPages;
    int tutorialPageIndx = 0;
    [SerializeField] GameObject FirstTimePlayingPanel;
    [SerializeField] GameObject TutorialPanel;

    void Start()
    {
        if(SaveData.instance.firstTimePlaying)
        {
            FirstTimePlayingPanel.SetActive(true);
            GameManager.paused = true;
            Time.timeScale = 0;
        }
        SaveData.instance.firstTimePlaying = false;
    }
    public void OpenTutorial()
    {
        tutorialPageIndx = 0;
        TutorialPanel.SetActive(true);
        tutorialPages[tutorialPageIndx].SetActive(true);
        GameManager.paused = true;
        Time.timeScale = 0;
    }
    public void CloseTutorial() 
    {
        TutorialPanel.SetActive(false);
        tutorialPages[tutorialPageIndx].SetActive(false);
        GameManager.paused = false;
    }
    public void NextPage()
    {
        if(tutorialPageIndx < tutorialPages.Count-1)
        {
            tutorialPages[tutorialPageIndx].SetActive(false);
            tutorialPageIndx++;
            tutorialPages[tutorialPageIndx].SetActive(true);
        }
    }
    public void PrevPage()
    {
        if(tutorialPageIndx > 0)
        {
            tutorialPages[tutorialPageIndx].SetActive(false);
            tutorialPageIndx--;
            tutorialPages[tutorialPageIndx].SetActive(true);
        }
    }
    public void CloseFirstTimePlayingPanel()
    {
        FirstTimePlayingPanel.SetActive(false);
        GameManager.paused = false;
    }
}