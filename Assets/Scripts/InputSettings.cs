using UnityEngine;
using UnityEngine.InputSystem;

public class InputSettings : MonoBehaviour
{
    private void Awake()
    {
        // Set to 0 to remove the limit entirely
        InputSystem.settings.maxEventBytesPerUpdate = 0;
    }
}
