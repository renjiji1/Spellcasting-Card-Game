using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;
 
// Collects observations (one row each) and uploads many of them to a Google Sheet in one request.
public class SheetLogger : MonoBehaviour
{
    public static SheetLogger instance;
    [SerializeField] string scriptUrl = "https://script.google.com/macros/s/AKfycbx4n_dimcTNVEvP7pWiqmawc48Dn016iDOOmuCqCGhuxatGGMvh_7XfRkeTI6wiLtmZ/exec";
    [SerializeField] string secret = "Linguistics";   // must match ObservationWriter.gs
    [SerializeField] string[] columns = { "level", "score", "time" };   // variable names = sheet column headers (the Inspector value overrides this default!)
    [SerializeField] float flushInterval = 10f;                          // seconds between automatic uploads (0 = only upload when you call Flush)
    [NonSerialized] string[] currentData;
 
    [Serializable] class Row { public string[] v; }
    [Serializable] class Payload
    {
        public string secret;
        public string player;
        public string[] columns;
        public Row[] rows;
    }
 
    readonly List<Row> pending = new List<Row>();
    bool sending;
 
    void Awake()
    {
        instance = this;
        currentData = new string[columns.Length];
        SetData("PlayerID", PlayerId);
    }
 
    // A stable id for this player, created once and remembered (written to the "player" column)
    public static string PlayerId
    {
        get
        {
            string id = PlayerPrefs.GetString("sheet_player_id", "");
            if (id == "") { id = Guid.NewGuid().ToString("N").Substring(0, 8); PlayerPrefs.SetString("sheet_player_id", id); }
            return id;
        }
    }
 
    // Record ONE observation. Give the values in the same order as `columns`:  Add(3, 1250, 42.5f)
    public void Add(params object[] values)
    {
        if (values.Length != columns.Length)
        {
            Debug.LogWarning("Expected " + columns.Length + " values (" + string.Join(", ", columns) + ") but got " + values.Length + ". Row was NOT added.");
            return;
        }
        var cells = new string[values.Length];
        for (int i = 0; i < values.Length; i++)
            cells[i] = values[i] == null ? "" :
                       (values[i] is IFormattable f ? f.ToString(null, CultureInfo.InvariantCulture) : values[i].ToString());
        pending.Add(new Row { v = cells });
    }
 
    // Queue the values stored with SetData as one observation, then start a fresh one
    public void Send()
    {
        if (SaveData.instance.sendPlayerData) { 
            Add(currentData);
            StartCoroutine(Flush());
        }
    }
 
    public void SetData(string colName, object value)
    {
        int colIndx = Array.IndexOf(columns, colName);
        if (colIndx < 0) { Debug.LogWarning("SetData: no column named '" + colName + "' in " + string.Join(", ", columns)); return; }
        currentData[colIndx] = value == null ? "" :
                               (value is IFormattable f ? f.ToString(null, CultureInfo.InvariantCulture) : value.ToString());
    }
 
    // Upload every observation collected so far in a single request
    public IEnumerator Flush()
    {
        if (sending || pending.Count == 0) yield break;   // nothing to send, or an upload is already running
        sending = true;
 
        var batch = pending.ToArray();
        var payload = new Payload { secret = secret, player = PlayerId, columns = columns, rows = batch };
        byte[] body = Encoding.UTF8.GetBytes(JsonUtility.ToJson(payload));
 
        using (var req = new UnityWebRequest(scriptUrl, "POST"))
        {
            req.uploadHandler   = new UploadHandlerRaw(body);
            req.downloadHandler = new DownloadHandlerBuffer();
            req.SetRequestHeader("Content-Type", "text/plain");   // avoids a CORS preflight in WebGL builds
            yield return req.SendWebRequest();
 
            string reply = req.downloadHandler.text;
            if (req.result == UnityWebRequest.Result.Success && reply.Contains("\"ok\":true"))
            {
                pending.RemoveRange(0, batch.Length);              // sent: drop only those rows
                Debug.Log("Sheet reply: " + reply);
            }
            else
                Debug.LogWarning("Sheet write failed, will keep and retry: " + req.error + " " + reply);
        }
        sending = false;
    }
 
    void OnApplicationPause(bool paused) { if (paused) StartCoroutine(Flush()); }
}