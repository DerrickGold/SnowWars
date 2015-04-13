/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray, Shaun Yonkers
 * 
 * Description: Keeps track of any global variables and gameobjects. This script can be called by
 *              any other script to access any of its variables
 ****************************************************************************************************/

using UnityEngine;
using UnityEngine.UI; 
using System.Collections;
using System.Collections.Generic;

public class Common: MonoBehaviour
{
    //Player GameObjects
    [HideInInspector]
    public GameObject player;

    //AI GameObjects
    [HideInInspector]
	public GameObject[] ai;

    //Sound GameObjects
	public enum AudioSFX {
			SNOWBALL_THROW = 0, SNOWBALL_HIT = 1
	};
	public AudioSource[] sfx;

    //Misc GameObjects
	public GameObject SnowBall;
    public GameObject DeathExplosion;
	public Sprite infAmmonIcon;
	public Sprite infHealthIcon;
	public Sprite infStaminIcon;
	public Sprite speedBoostIcon;
	public Sprite superSnowballIcon;
	public Sprite healthIcon;

	public bool gameEnd = false;
	private bool oneShot = false;

	public string TEAM_A_KILLS;
	public string TEAM_B_KILLS;

	public Color TEAM_A_COLOR = Color.black;
	public Color TEAM_B_COLOR = Color.black;
	public string playerTeam;

	public Text topText;
	public Text bottomText;
	public Text alertText;
	public Text buffText;

	public List<Transform> buffs;

	private GameObject hud;

    /****************************************************************************************************
     * Description: Assigns required variables.                                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Awake()
	{
		buffs = new List<Transform> ();
	}


    /****************************************************************************************************
     * Description: Sets important game variables.                                                      *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start()
	{
		if ((Application.loadedLevelName != "Intro") && (Application.loadedLevelName != "MainMenu"))
        {
			Time.timeScale = 1.0f;
			Screen.lockCursor = true;
            hud = GameObject.FindGameObjectWithTag("hud");
            topText = hud.transform.FindChild("teamA_score").GetComponent<Text>();
            bottomText = hud.transform.FindChild("teamB_score").GetComponent<Text>();
			alertText = hud.transform.FindChild("Alerts").GetComponent<Text>();
			buffText = hud.transform.FindChild("buff text").GetComponent<Text>();

			alertText.text = "";
			buffText.text = "";
			TEAM_A_KILLS = "You >> 0";
			TEAM_A_COLOR = Color.red;
			TEAM_B_KILLS = "Leading AI: 0";
			TEAM_B_COLOR = Color.blue;
        }
	}


    /****************************************************************************************************
     * Description: Keeps track of player and AI score, as well as keeps track of game progress.        *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update()
	{
        //Make sure not to run anything during the intro
        if ((Application.loadedLevelName != "Intro") && (Application.loadedLevelName != "MainMenu"))
        {
            	topText.text = TEAM_A_KILLS.ToString();
				topText.color = TEAM_A_COLOR;
            	bottomText.text = TEAM_B_KILLS.ToString();
				bottomText.color = TEAM_B_COLOR;

                if (gameEnd && !oneShot)
                {
					oneShot = true;

                    //Set the game time to 0 and unlock the cursor
                    Time.timeScale = 0.0f;
                    Screen.lockCursor = false;

                    //Show the game over buttons and give them listeners
                    hud.transform.FindChild("menuButton").gameObject.SetActive(true);
					hud.transform.FindChild("menuButton").GetComponent<Button>().onClick.AddListener(() => {loadMenu();});
                    hud.transform.FindChild("exitButton").gameObject.SetActive(true);
					hud.transform.FindChild("exitButton").GetComponent<Button>().onClick.AddListener(() => {exitGame();});

                    //Disable the control from the player when the game ends
                    GameObject player = GameObject.Find("Player(Clone)");
                    player.GetComponent<MouseLook>().enabled = false;
                    Camera.main.gameObject.GetComponent<MouseLook>().enabled = false;
                    //player.GetComponent<CharacterController>().enabled = false;
                }
        }
	}


    /****************************************************************************************************
     * Description: Closes the game.                                                                    *
     * Syntax: exitGame();                                                                              *
     ****************************************************************************************************/
	public void exitGame()
	{
		Application.Quit ();
	}


    /****************************************************************************************************
     * Description: Loads the main menu.                                                                *
     * Syntax: loadMenu();                                                                              *
     ****************************************************************************************************/
	public void loadMenu()
	{
		Application.LoadLevel ("MainMenu");
	}
}