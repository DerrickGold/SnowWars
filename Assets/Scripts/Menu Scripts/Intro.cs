/****************************************************************************************************
 * Primary Contributor: Curtis Murray                                                               *
 *                                                                                                  *
 * Description: This script is solely used in the intro cutscene. Helps to time animations and      *
 *              events.                                                                             *
 ****************************************************************************************************/
using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Intro : MonoBehaviour 
{
    private Image image;
    private GameObject music;
    private float fadeSpeed = 1.0f;
    private bool clicked = false;

    /****************************************************************************************************
     * Description: Gets all required variables.                                                        *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start()
    {
        foreach (GameObject g in GameObject.FindObjectsOfType(typeof(GameObject)))
        {
            if (g.name == "Image")
                image = g.GetComponent<Image>();
            if (g.name == "Music")
                music = g;
        }
    }

    /****************************************************************************************************
     * Description: This is used solely to check to see if the player would like to skip the intro      *
     *              and head straight to the main menu. Also handles fading to white.                   *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        if (Input.GetMouseButtonDown(0) && clicked == false)
            fadeToWhite();

        if (clicked)
            image.color = Color.Lerp(image.color, Color.white, fadeSpeed * Time.deltaTime * 2);
    }

    /****************************************************************************************************
     * Description: This is called right before the intro ends to give the scene a bit of time to fade  *
     *              before loading the main menu.                                                       *
     * Syntax: fadeToWhite();                                                                           *
     ****************************************************************************************************/
    void fadeToWhite()
    {
        clicked = true;
        StartCoroutine("changeScene");
    }

    /****************************************************************************************************
     * Description: Waits fadeSpeed long before changing to the main menu.                              *
     * Syntax: StartCoroutine("changeScene");                                                           *
     ****************************************************************************************************/
    IEnumerator changeScene()
    {
        DontDestroyOnLoad(music);
        yield return new WaitForSeconds(fadeSpeed * 2);
        Application.LoadLevel("MainMenu");
    }
}