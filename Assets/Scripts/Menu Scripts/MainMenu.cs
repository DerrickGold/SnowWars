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
			GUI.TextField(new Rect(500, 380, 300, 50), "Resolution");
			//1080p
			if(GUI.Button(new Rect(500, 430, 93, 100), "1080p")) {
				Screen.SetResolution(1920, 1080, Fullscreen);
				Debug.Log ("1080p");
			}
			//720p
			if(GUI.Button(new Rect(596, 430, 93, 100), "720p")) {
				Screen.SetResolution(1280, 720, Fullscreen);
				Debug.Log ("720p");
			}
			//480p
			if(GUI.Button(new Rect(692, 430, 93, 100), "480p")) {
				Screen.SetResolution(640, 480, Fullscreen);
				Debug.Log ("480p");
			}
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
}