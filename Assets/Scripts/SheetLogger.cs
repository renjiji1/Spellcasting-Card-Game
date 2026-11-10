using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;
 
// Attach to a GameObject. Call Log(...) anywhere; lines are sent in batches.
public class SheetLogger : MonoBehaviour
{
    public static SheetLogger instance;
    [SerializeField] string scriptUrl = "https://script.google.com/macros/s/AKfycbw0r-61XK5QDGP7aO8BkhqQ8OLP46bhNqN8PtsrtmSC5ZwwPnVur-A8duM8qn499CjY/exec";
    [SerializeField] string secret = "Linguistics";
    [NonSerialized] public List<string> currentData = new List<string>();

    void Awake()
    {
        instance = this;
    }
 
    [Serializable]
    class Payload
    {
        public string secret;
        public string player;
        public string mode;        // "append" = after the last filled row, "set" = overwrite from startRow
        public int startRow;       // only used by "set" (row 1 is the header, so 2 or higher)
        public string[] values;    // one entry per row
    }
 
    // A stable id for this player/device, created once and remembered
    public static string PlayerId
    {
        get
        {
            string id = PlayerPrefs.GetString("sheet_player_id", "");
            if (id == "") { id = Guid.NewGuid().ToString("N").Substring(0, 8); PlayerPrefs.SetString("sheet_player_id", id); }
            return id;
        }
    }
 
    // Add many values to the bottom of this player's column in ONE request
    public IEnumerator Append() { return Send("append", 0); }
 
    // Overwrite cells starting at a given row (e.g. startRow = 2 rewrites the column from the top)
    public IEnumerator Set(int startRow) { return Send("set", startRow); }
 
    IEnumerator Send(string mode, int startRow)
    {
        var p = new Payload { secret = secret, player = PlayerId, mode = mode, startRow = startRow, values = currentData.ToArray() };
        byte[] body = Encoding.UTF8.GetBytes(JsonUtility.ToJson(p));
 
        using (var req = new UnityWebRequest(scriptUrl, "POST"))
        {
            req.uploadHandler   = new UploadHandlerRaw(body);
            req.downloadHandler = new DownloadHandlerBuffer();
            req.SetRequestHeader("Content-Type", "text/plain");   // avoids a CORS preflight in WebGL builds
            yield return req.SendWebRequest();
 
            if (req.result == UnityWebRequest.Result.Success)
            {
                currentData.Clear();
                Debug.Log("Sheet reply: " + req.downloadHandler.text);   // {"ok":true,"column":3,"firstRow":2,"count":500}
            }
            else
                Debug.LogWarning("Sheet write failed: " + req.error + " " + req.downloadHandler.text);
        }
    }
}