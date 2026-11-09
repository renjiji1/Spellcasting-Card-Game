using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;
 
// Attach to a GameObject. Call Log(...) anywhere; lines are sent in batches.
public class SheetLogger : MonoBehaviour
{
    public static SheetLogger instance;
    [SerializeField] string scriptUrl = "https://script.google.com/macros/s/AKfycbyGmuspvkXCcRKBQuk-XTsEQFSqES4s04_eKSo__hTEz28xKxNZx7p7rmToTDHw748e/exec";
    [SerializeField] string secret = "Linguistics";
    public List<string> currentData = new List<string>();

    void Awake()
    {
        instance = this;
    }

    public IEnumerator LogToSheet()
    {
        string body = secret + "\n" + string.Join("\n", currentData);
 
        using (var req = new UnityWebRequest(scriptUrl, "POST"))
        {
            req.uploadHandler   = new UploadHandlerRaw(Encoding.UTF8.GetBytes(body));
            req.downloadHandler = new DownloadHandlerBuffer();
            req.SetRequestHeader("Content-Type", "text/plain");
            yield return req.SendWebRequest();
 
            if (req.result == UnityWebRequest.Result.Success && req.downloadHandler.text.Contains("ok"))
                currentData.Clear();
            else
                Debug.LogWarning("Sheet log failed, will retry: " + req.error + " " + req.downloadHandler.text);
        }
    }
}