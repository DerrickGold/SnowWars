/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray
 * 
 * Description: Keeps track of any global variables and gameobjects. This script can be called by
 *              any other script to access any of its variables
 ****************************************************************************************************/

using UnityEngine;
using UnityEngine.UI; 
using System.Collections;

public class Common: MonoBehaviour {
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

	public int TEAM_A_KILLS = 0;
	public int TEAM_B_KILLS = 0;

	public Text teamB_score;
	public Text teamA_score;

	void Start()
	{
		GameObject hud = GameObject.FindGameObjectWithTag ("hud");//<"hud">();
		teamA_score = hud.transform.FindChild("teamA_score").GetComponent<Text>();
		teamB_score = hud.transform.FindChild ("teamB_score").GetComponent<Text> ();

	}

	void Update()
	{
		teamA_score.text = TEAM_A_KILLS.ToString ();
		teamB_score.text = TEAM_B_KILLS.ToString ();
	}
}