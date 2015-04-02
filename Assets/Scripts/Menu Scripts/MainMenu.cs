/****************************************************************************************************
 * Primary Contributor: Shaun Yonkers (VERIFY LAST NAME SPELLING)
 * 
 * Description: This script is the driving force behind the main menu as well as the in-game menu.
 *              This allows the player to start and stop games, change options, etc.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class MainMenu : MonoBehaviour 
{
	public GUISkin guiSkin;
	public Texture2D background, LOGO;
	public bool DragWindow = false;
	public bool snowEffects = true;
	public bool Fullscreen;
	
	private string clicked = "";
	private Rect WindowRect = new Rect((Screen.width/2)-50, (Screen.height/2)-50, Screen.width / 4, Screen.height / 2);
    private float volume = 1.0f;

    private float startingScreenHeight;
    private float startingScreenWidth;

    void Start()
    {
        startingScreenHeight = Screen.height;
        startingScreenWidth = Screen.width;
    }


    /****************************************************************************************************
     * Description: Allow the user to return to the main menu using the escape key. Also handles        *
     *              resizing                                                                            *
     *              of the menu if the screen size changes.                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    private void Update()
    {
        if (Input.GetKey(KeyCode.Escape))
            clicked = "";

        if (startingScreenHeight != Screen.height || startingScreenWidth != Screen.width)
            WindowRect.Set((Screen.width / 2) - 50, (Screen.height / 2)-50, Screen.width / 4, Screen.height / 2);
    }
	

    /****************************************************************************************************
     * Description: Decide what is drawn on the gui based on the clicked variable.                                                 *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    private void OnGUI()
	{
		if (background != null)
			GUI.DrawTexture(new Rect(0,0,Screen.width , Screen.height),background);
		if (LOGO != null)
			GUI.DrawTexture(new Rect((Screen.width / 2) - 100, 30, 200, 200), LOGO);
		
		GUI.skin = guiSkin;
		if (clicked == "") {
			WindowRect = GUI.Window (0, WindowRect, menuFunc, "Main Menu");
		} else if (clicked == "options") {
			WindowRect = GUI.Window (1, WindowRect, optionsFunc, "Options");
		} else if (clicked == "video") {
			resolutionBtns ();
			antiAlias ();
			tripleBufferingBtns ();
			vSyncBtns ();
			QualityBtns ();
			if (GUILayout.Button ("Back")) {
				clicked = "options";
			}
		} 
		else if (clicked == "GameMode") {
			clicked = "GameMode";
			WindowRect = GUI.Window(2, WindowRect, gameModeFunc, "Game Mode");
		}
	}
	
	private void gameModeFunc(int id)
	{
		if (GUILayout.Button ("Team Deathmatch")) {
			Application.LoadLevel("LevelOne");
			Debug.Log("Team Deathmatch");
		}
		if (GUILayout.Button ("Free For All")) {
			Application.LoadLevel (null);
			Debug.Log("Free for All");
		}
		if (GUILayout.Button("Back"))
		{
			clicked = "";
		}

	}
    /****************************************************************************************************
     * Description: Create the menu screen when the options button is clicked                                                   *
     * Syntax: optionsFunc(int id);                                                                     *                                                                *
     ****************************************************************************************************/
	private void optionsFunc(int id)
	{
		if (GUILayout.Button("Video"))
		{
			clicked = "video";
		}
		GUILayout.Box("Volume");
		volume = GUILayout.HorizontalSlider(volume ,0.0f,1.0f);
		AudioListener.volume = volume;
		if (GUILayout.Button ("Snow Effects"))
		{
			snowEffects = !snowEffects;
		}
		if (GUILayout.Button("Back"))
		{
			clicked = "";
		}
		if (DragWindow)
			GUI.DragWindow(new Rect (0,0,Screen.width,Screen.height));
	}


    /****************************************************************************************************
     * Description: Navigte the main menu to decide what screen to create.                                                   *
     * Syntax: menuFunc(int id);                                                                     *
     * Values:                                                                                          *
     *          id = DESCRIBE WHAT id IS                                                                *
     ****************************************************************************************************/
	private void menuFunc(int id)
	{
		//Buttons 
		if (GUILayout.Button("Play Game"))
		{
			//Play game is clicked
			clicked = "GameMode";
		}
		if (GUILayout.Button("Options"))
		{
			clicked = "options";
		}
		if (GUILayout.Button("Quit Game"))
		{
			Application.Quit();
		}
		if (DragWindow)
			GUI.DragWindow(new Rect(0, 0, Screen.width, Screen.height));
	}


    /****************************************************************************************************
     * Description: Create the resolution buttons in the video options                                              *
     * Syntax: resolutionBtns();                                                                        (
     ****************************************************************************************************/
	private void resolutionBtns(){
		GUI.TextField(new Rect(300, 50, 100, 50), "Resolution");
			//1080p
			if(GUI.Button(new Rect(400, 50, 93,50), "1080p")) {
				Screen.SetResolution(1920, 1080, Fullscreen);
				Debug.Log ("1080p");
			}
			//720p
			if(GUI.Button(new Rect(493, 50, 93, 50), "720p")) {
				Screen.SetResolution(1280, 720, Fullscreen);
				Debug.Log ("720p");
			}
			//480p
			if(GUI.Button(new Rect(586, 50, 93, 50), "480p")) {
				Screen.SetResolution(640, 480, Fullscreen);
				Debug.Log ("480p");
			}
	}


    /****************************************************************************************************
     * Description: Called when the player changes the value of antiAliasing in the menu.               *
     * Syntax: antiAlias();                                                                             *
     ****************************************************************************************************/
	private void antiAlias(){
		GUI.TextField (new Rect (300, 100, 100, 50), "Anti-Alising");
		if (GUI.Button (new Rect (400, 100, 69.75f, 50), "2X")) {
			QualitySettings.antiAliasing = 2;
			Debug.Log ("2X");
		}
		if (GUI.Button (new Rect (469.75f, 100, 69.75f, 50), "4X")) {
			QualitySettings.antiAliasing = 4;
			Debug.Log ("4X");
		}
		if (GUI.Button (new Rect (539.5f, 100, 69.75f, 50), "8X")) {
			QualitySettings.antiAliasing = 8;
			Debug.Log ("8X");
		}
		if (GUI.Button (new Rect (609.25f, 100, 69.75f, 50), "Off")) {
			QualitySettings.antiAliasing = 0;
			Debug.Log ("Off");
		}
	}
	/****************************************************************************************************
     * Description: Called when the player turns triple buffering on or off in the menu.                *
     * Syntax: tripleBufferingBtns();                                                                   *
     ****************************************************************************************************/

	private void tripleBufferingBtns(){
				GUI.TextField (new Rect (300, 150, 100, 50), "Triple Buffering");
				if (GUI.Button (new Rect (400, 150, 100.0f, 50), "On")) {
						QualitySettings.maxQueuedFrames = 3;
						Debug.Log ("On");
				}
				if (GUI.Button (new Rect (500, 150, 100.0f, 50), "Off")) {
						QualitySettings.maxQueuedFrames = 0;
						Debug.Log ("Off");
				}
	}
	/****************************************************************************************************
     * Description: Called when the player turns vertical sync on or off in the menu.                   *
     * Syntax: vSyncBtns();                                                                             *
     ****************************************************************************************************/
	private void vSyncBtns(){
		GUI.TextField (new Rect (300, 200, 100, 50), "Vertical Sync");
		if (GUI.Button (new Rect (400, 200, 100.0f, 50), "On")) {
			QualitySettings.vSyncCount = 1;
			Debug.Log ("On");
		}
		if (GUI.Button (new Rect (500, 200, 100.0f, 50), "Off")) {
			QualitySettings.vSyncCount = 0;
			Debug.Log ("Off");
		}
	}
	/****************************************************************************************************
     * Description: Called when the player increases or decreases the overall settings in the menu.     *
     * Syntax: QualityBtns();                                                                             *
     ****************************************************************************************************/
	private void QualityBtns(){
		GUI.TextField (new Rect (300, 250, 100, 50), "Quality");
		if (GUI.Button (new Rect (400, 250, 100.0f, 50), "Increase")) {
			QualitySettings.IncreaseLevel();
			Debug.Log ("Increase");
		}
		if (GUI.Button (new Rect (500, 250, 100.0f, 50), "Decrease")) {
			QualitySettings.DecreaseLevel();
			Debug.Log ("Decrease");
		}
	}

}