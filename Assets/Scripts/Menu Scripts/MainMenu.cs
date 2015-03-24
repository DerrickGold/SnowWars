using UnityEngine;
using System.Collections;

public class MainMenu : MonoBehaviour 
{
	public GUISkin guiSkin;
	public Texture2D background, LOGO;
	public bool DragWindow = false;
	public bool snowEffects = true;
	public bool Fullscreen;
	public string levelToLoad = "";
	
	
	private string clicked = "";
	private Rect WindowRect = new Rect((Screen.width/2)-200, Screen.height/2 - 100, 400, 400);
	private float volume = 1.0f;
	
	private void Start()
	{

	}
	
	private void OnGUI()
	{
		if (background != null)
			GUI.DrawTexture(new Rect(0,0,Screen.width , Screen.height),background);
		if (LOGO != null)
			GUI.DrawTexture(new Rect((Screen.width / 2) - 100, 30, 200, 200), LOGO);
		
		GUI.skin = guiSkin;
		if (clicked == "")
		{
			WindowRect = GUI.Window(0, WindowRect, menuFunc, "Main Menu");
		}
		else if (clicked == "options")
		{
			WindowRect = GUI.Window(1, WindowRect, optionsFunc, "Options");
		}
		else if (clicked == "video")
		{
			resolutionBtns();
			antiAlias();
			if (GUILayout.Button("Back"))
			{
				clicked = "options";
			}
		}
	}
	
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
	
	private void menuFunc(int id)
	{
		//buttons 
		if (GUILayout.Button("Play Game"))
		{
			//play game is clicked
			Application.LoadLevel(levelToLoad);
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
	
	private void Update()
	{
		if (Input.GetKey (KeyCode.Escape))
			clicked = "";
	}

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
}