/*
 * This script is used to display general stats about the current build of the game while playing
 */

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class HUDDebugger : MonoBehaviour 
{
    public Text uiText;
    private int fps;

    void Update()
    {
        //Calculate FPS
        fps = (int)(1.0f / Time.smoothDeltaTime);

        //Display game stats
        uiText.text = "FPS: " + fps;
    }
}