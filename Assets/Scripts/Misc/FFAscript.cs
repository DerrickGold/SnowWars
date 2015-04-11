/****************************************************************************************************
 * Primary Contributor: Shaun Yonkers
 * 
 * Description:  This script is placed on the global game object which creates a Free For All match. 
 * This keeps track of all the gameplay statistics and manages spawning players when they die and at 
 * the beginning of the match.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class FFAscript : MonoBehaviour {
	static private int MAX_SCORE = 100;

	private Common common;

	private int maxPlayerSize = 31;
	private int topScore;
	private int playerScore;
	private bool gameEnd = false;
	private GameObject play;
	public GameObject AIprefab;
	public GameObject player;

	private List<GameObject> AIList = new List<GameObject> ();
	private List<string> hatColors = new List<string>();
	
	// Use this for initialization
	void Start () {
		common = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common> ();
		Transform buffsObj = GameObject.FindGameObjectWithTag ("Buffs").transform; //get all the buffs in the map
		for (int i = 0; i < buffsObj.childCount; i++) { //add all the buffs to the list of buffs
			common.buffs.Add (buffsObj.GetChild (i));
		}

		populateHatColors ();
		float randX = Random.Range(35, 269);
		float randZ = Random.Range(20, 280);
		play = (GameObject)Instantiate(player, new Vector3(randX, Terrain.activeTerrain.SampleHeight(new Vector3(randX, 0 , randZ)), randZ), transform.rotation);
		play.tag = "Team0";
		play.GetComponent<PlayerController>().setHatColor(hatColors[Random.Range(0, hatColors.Count)]);;

		for (int i = 0; i < maxPlayerSize; i++){
			float randomX = Random.Range(35, 269);
			float randomZ = Random.Range(20, 280);
			GameObject AI = (GameObject)Instantiate(AIprefab, new Vector3(randomX, Terrain.activeTerrain.SampleHeight(new Vector3(randomX, 0 , randomZ)), randomZ), transform.rotation);
			AI.tag = "Team0";
			AI.GetComponent<AIController>().setHatColor(hatColors[Random.Range(0, hatColors.Count)]);
			AIList.Add (AI);
		}

	}
	
	// Update the score for each player and AI to see who is winning
	void Update () {
		//get the player score and check if they won
		playerScore = play.GetComponent<CharacterBase> ().score;
		if (playerScore >= MAX_SCORE) {
			common.alertText.text = "Player Wins!!";
			common.gameEnd = true;
		}
		// Loop through all the AI and find the one with the highest kills and see if any of them won
		foreach (GameObject AI in AIList) {
			int checkScore = AI.GetComponent<CharacterBase>().score;
			if (checkScore >= MAX_SCORE){
				common.alertText.text = "AI Wins!!";
				common.gameEnd = true;
			}
			if (checkScore > topScore)
				topScore = checkScore;
		}
		// Update the Hud to display the playerscore and top AI score
		if (topScore > playerScore) {
			common.TEAM_A_KILLS = topScore;
			common.TEAM_A_COLOR = Color.red;
			common.TEAM_B_KILLS = playerScore;
			common.TEAM_B_COLOR = Color.blue;
		}
		if (playerScore > topScore) {
			common.TEAM_A_KILLS = playerScore;
			common.TEAM_A_COLOR = Color.blue;
			common.TEAM_B_KILLS = topScore;
			common.TEAM_B_COLOR = Color.red;
		}
	}
	
/***************************************************************************************************
* Description: This is a helper function. This simply populates the list of hat colors that can    *
*              be chosen from.                                                                     *
* Syntax: populateHatColors();                                                                     *
***************************************************************************************************/
	private void populateHatColors()
	{
		hatColors.AddRange(new string[] { "BlackHat",
			"BlueHat",
			"GreenHat",
			"OrangeHat",
			"PurpleHat",
			"RedHat",
			"YellowHat",});
	}
}
