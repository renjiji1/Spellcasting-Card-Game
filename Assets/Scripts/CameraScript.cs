using UnityEngine;

public class CameraScript : MonoBehaviour
{
    Camera cam;
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.transparencySortMode = TransparencySortMode.CustomAxis;
        cam.transparencySortAxis = transform.forward;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    void LateUpdate()
    {
        cam.transparencySortAxis = transform.forward;
    }
}
