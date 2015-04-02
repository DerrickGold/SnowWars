/****************************************************************************************************
 * Primary Contributor: Shaun Yonkers
 * 
 * Description: This script is the driving force of the players radar. Tracks the player and all AI
 *              movement and displays it in an easy to read radar at the top-right corner of the
 *              screen.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Radar : MonoBehaviour
{
	public enum RadarTypes : int {Textured, Round, Transparent};
	
	// Display Location
	public RadarTypes radarType = RadarTypes.Transparent;
	public Color radarBackgroundA = new Color(255, 255, 0);
	public Color radarBackgroundB = new Color(0, 255, 255);
	public Texture2D radarTexture;
	public float radarSize = 0.10f;  // The amount of the screen the radar will use
	public float radarZoom = 2.0f;
	
	// Center Object information
	public Color  radarCenterColor = new Color(255, 255, 255);
	private int team = 0; //0 = FFA | 1 = TeamA | 2 = TeamB
	
	// Blip information
	public Color  radarEnemyColor = new Color(255, 0, 0);
	public Color  radarFriendlyColor = new Color(0, 255, 0);
	
	// Internal vars
	private GameObject centerObject;
	private int        radarWidth;
	private int        radarHeight;
	private Vector2    radarCenter;
	private Texture2D  radarCenterTexture;
	private Texture2D  radarBlip1Texture;
	private Texture2D  radarBlip2Texture;
	
    /****************************************************************************************************
     * Description: Used to initialize the radar.                                                       *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start ()
	{
		// Determine the size of the radar
		radarWidth = (int)(Screen.width * radarSize);
		radarHeight = radarWidth;
		
		// Set the location of the radar
		radarCenter = new Vector2(Screen.width - radarWidth / 2, radarHeight / 2);
		
		// Create the blip textures
		radarCenterTexture = new Texture2D(3, 3, TextureFormat.RGB24, false);
		radarBlip1Texture = new Texture2D(3, 3, TextureFormat.RGB24, false);
		radarBlip2Texture = new Texture2D(3, 3, TextureFormat.RGB24, false);
		
		CreateBlipTexture(radarCenterTexture, radarCenterColor);
		CreateBlipTexture(radarBlip1Texture, radarEnemyColor);
		CreateBlipTexture(radarBlip2Texture, radarFriendlyColor);

		if (radarType != RadarTypes.Textured)
		{
			radarTexture = new Texture2D(radarWidth, radarHeight, TextureFormat.RGB24, false);
			CreateRoundTexture(radarTexture, radarBackgroundA, radarBackgroundB);
		}

		
		// Get our center object
		foreach (GameObject g in GameObject.FindObjectsOfType(typeof(GameObject))) {
			if (g.name == "Player(Clone)") {
				centerObject = g;
				if (centerObject.tag == "TeamA")
					team = 1;
				else if (centerObject.tag == "TeamB")
					team = 2;
			}
		}
	}
	
	
    /****************************************************************************************************
     * Description: Used to update and draw the radar.                                                  *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnGUI (){
		// Draw the radar background
		if (radarType != RadarTypes.Transparent)
		{
			Rect radarRect = new Rect(radarCenter.x - radarWidth / 2, radarCenter.y - radarHeight / 2, radarWidth, radarHeight);
			GUI.DrawTexture(radarRect, radarTexture);
		}
		if (centerObject == null) {
			foreach (GameObject g in GameObject.FindObjectsOfType(typeof(GameObject))) {
				if (g.name == "Player(Clone)") {
					centerObject = g;
					if (centerObject.tag == "TeamA")
						team = 1;
					else if (centerObject.tag == "TeamB")
						team = 2;
				}
			}
		}
		// Find all game objects
		if (centerObject != null) {
			foreach (GameObject g in GameObject.FindObjectsOfType(typeof(GameObject))) {
				if (g.name == "AI(Clone)") {
					////
					if (centerObject.tag == g.tag)
						drawBlip (g, radarBlip2Texture);
					else
						drawBlip (g, radarBlip1Texture);
				}
			}
		}
			
		/* Iterate through them and call drawBlip function
		foreach (GameObject go in gos)
			drawBlip(go, radarBlip1Texture);
		gos = GameObject.FindGameObjectsWithTag(radarBlip2Tag);
			
		foreach (GameObject go in gos)
			drawBlip(go, radarBlip2Texture);*/

		// Draw center oject
		Rect centerRect;
		centerRect = new Rect(radarCenter.x - 1.5f, radarCenter.y - 1.5f, 3, 3);
		GUI.DrawTexture(centerRect, radarCenterTexture);

	}
	

	// Draw a blip for an object
    /****************************************************************************************************
     * Description: This is a helper function. Used to draw a dot (blip) for an individual gameobject.  *
     * Syntax: drawBlip(GameObject go, Texture2D blipTexture);                                          *
     * Values:                                                                                          *
     *          go = The gameobject that needs to have a dot (blip) displayed for it                    *
     *          blipTexture = The texture to use when drawing the dot (blip)                            *
     ****************************************************************************************************/
	void drawBlip(GameObject go, Texture2D blipTexture)
	{
		if (centerObject)
		{
			Vector3 centerPos = centerObject.transform.position;
			Vector3 extPos = go.transform.position;

			
			// Get the distance to the object from the centerObject
			float dist = Vector3.Distance(centerPos, extPos);
			
			// Get the object's offset from the centerObject
			float bX = centerPos.x - extPos.x;
			float bY = centerPos.z - extPos.z;

			float deltay = Mathf.Atan2(bX,bY)*Mathf.Rad2Deg - 270 - centerObject.transform.eulerAngles.y;

			bX = dist*Mathf.Cos(deltay * Mathf.Deg2Rad)*-1;
			bY = dist*Mathf.Sin(deltay * Mathf.Deg2Rad);

			// Scale the objects position to fit within the radar
			bX = bX * radarZoom;
			bY = bY * radarZoom;

			// For a round radar, make sure we are within the circle
			if(dist <= (radarWidth - 2) * 0.5 / radarZoom)
			{
				Rect clipRect = new Rect(radarCenter.x - bX - 1.5f, radarCenter.y + bY - 1.5f, 3, 3);
				GUI.DrawTexture(clipRect, blipTexture);
			}
		}
	}
	

    /****************************************************************************************************
     * Description: This is a helper function. Used to create a blip texture.                           *
     * Syntax: CreateBlipTexture(Texture2D texture, Color color);                                       *
     * Values:                                                                                          *
     *          texture = The texture to use when creating the blip                                     *
     *          color = The color of the blip                                                           *
     ****************************************************************************************************/
	void CreateBlipTexture(Texture2D tex, Color c)
	{
		Color[] cols = {c, c, c, c, c, c, c, c, c};
		tex.SetPixels(cols, 0);
		tex.Apply();
	}
	

    /****************************************************************************************************
     * Description: This is a helper function. Used to create a round bullseye texture.                 *
     * Syntax: CreateRoundTexture(Texture2D texture, Color colorOne, Color colorTwo);                   *
     * Values:                                                                                          *
     *          texture = The texture to use when creating the round bullseye                           *
     *          colorOne = DESCRIBE WHAT THE FIRST COLOR IS USED FOR                                    *
     *          colorTwo = DESCRIBE WHAT THE SECOND COLOR IS USED FOR                                   *
     ****************************************************************************************************/
    void CreateRoundTexture(Texture2D tex, Color a, Color b)
	{
		Color c = new Color(0, 0, 0);
		int size = (int)((radarWidth / 2) / 4);
		
		// Clear the texture
		for (int x = 0; x < radarWidth; x++)
		{
			for (int y = 0; y < radarWidth; y++)
			{
				tex.SetPixel(x, y, c);
			}
		}
		
		for (int r = 4; r > 0; r--)
		{
			if (r % 2 == 0)
			{
				c = a;
			}
			else
			{
				c = b;
			}
			DrawFilledCircle(tex, (int)(radarWidth / 2), (int)(radarHeight / 2), (r * size), c);
		}
		
		tex.Apply();
	}


    /****************************************************************************************************
     * Description: This is a helper function. Used to draw a filled colored circle into a texture.     *
     * Syntax: DrawFilledCircle(Texture2D texture, int cx, int cy, int r, Color c);                     *
     * Values:                                                                                          *
     *          texture = The texture to use when creating a filled colored circle                      *
     *          cx = DESCRIBE WHAT CX INT IS USED FOR                                                   *
     *          cy = DESCRIBE WHAT CY INT IS USED FOR                                                   *
     *          r = DESCRIBE WHAT R INT IS USED FOR                                                     *
     *          c = The color that should be applied to the colored circle                              *
     ****************************************************************************************************/
    // Draw a filled colored circle onto a texture
	void DrawFilledCircle(Texture2D tex, int cx, int cy, int r, Color c)
	{
		for (int x = -r; x < r ; x++)
		{
			int height = (int)Mathf.Sqrt(r * r - x * x);
			
			for (int y = -height; y < height; y++)
				tex.SetPixel(x + cx, y + cy, c);
		}
	}		
}