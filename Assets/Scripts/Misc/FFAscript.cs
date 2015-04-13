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

public class FFAscript : MonoBehaviour
{
	public int GAME_MAX_SCORE;

	private Common common;

	public int playerCount = 31;
	private int topScore;
	private int playerScore;
	private GameObject play;
	public GameObject AIprefab;
	public GameObject player;

	private List<GameObject> AIList = new List<GameObject> ();
	private List<string> hatColors = new List<string>();


    /****************************************************************************************************
     * Description: Deals with spawning the player and all of the AI randomly around the map. Also      *
     *              grabs a list of the buffs.                                                          *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start ()
    {
        GAME_MAX_SCORE = 5;
        common = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common> ();

        //Get all the buffs in the map
        Transform buffsObj = GameObject.FindGameObjectWithTag ("Buffs").transform;
		
        //Add all the buffs to the list of buffs
        for (int i = 0; i < buffsObj.childCount; i++)
            common.buffs.Add (buffsObj.GetChild (i));

        //Grab a list of all the hat colors
        populateHatColors ();

        float randX = Random.Range(35, 269);
        float randZ = Random.Range(20, 280);

        //Spawn the player anywhere but the water
        bool oneShot = false;
        RaycastHit hit;
        while (Physics.Raycast(new Vector3(randX, 500, randZ), -Vector3.up, out hit) && !oneShot)
        {
            if (hit.transform.gameObject.tag != "WATER")
            {
                oneShot = true;
                play = (GameObject)Instantiate(player, hit.point, transform.rotation);
                play.tag = "Team0";
                play.GetComponent<PlayerController>().setHatColor(hatColors[Random.Range(0, hatColors.Count)]);
            }
            else
            {
                randX = Random.Range(35, 269);
                randZ = Random.Range(20, 280);
            }
        }

        //Spawn the appropriate amount of AI
        for (int i = 0; i < playerCount; i++)
        {
            randX = Random.Range(35, 269);
            randZ = Random.Range(20, 280);

            oneShot = false;
            //Spawn the AI anywhere but the water
            while (Physics.Raycast(new Vector3(randX, 500, randZ), -Vector3.up, out hit) && !oneShot)
            {
                if (hit.transform.gameObject.tag != "WATER")
                {
                    oneShot = true;
                    GameObject AI = (GameObject)Instantiate(AIprefab, hit.point, transform.rotation);
                    AI.tag = "Team0";
                    AI.GetComponent<AIController>().setHatColor(hatColors[Random.Range(0, hatColors.Count)]);
                    AIList.Add(AI);
                }
                else
                {
                    randX = Random.Range(35, 269);
                    randZ = Random.Range(20, 280);
                }
            }
        }

    }


    /****************************************************************************************************
     * Description: Update the score for each player and AI to see who is winning.                      *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update ()
    {
        //Get the player score and check if they won
        playerScore = play.GetComponent<CharacterBase> ().score;
        if (playerScore >= GAME_MAX_SCORE)
        {
            common.alertText.text = "Player Wins!!";
            common.gameEnd = true;
        }
        //Loop through all the AI and find the one with the highest kills and see if any of them won
        foreach (GameObject AI in AIList)
        {
            int checkScore = AI.GetComponent<CharacterBase>().score;
            if (checkScore >= GAME_MAX_SCORE){
                common.alertText.text = "AI Wins!!";
                common.gameEnd = true;
            }
            if (checkScore > topScore)
                topScore = checkScore;
        }
        //Update the Hud to display the playerscore and top AI score
        if (topScore > playerScore)
        {
            common.TEAM_A_KILLS = "Leading AI: " + topScore.ToString();
            common.TEAM_A_COLOR = Color.red;
            common.TEAM_B_KILLS = "You >> " + playerScore.ToString();
            common.TEAM_B_COLOR = Color.blue;
        }
        if (playerScore > topScore)
        {
            common.TEAM_A_KILLS = "You >> " + playerScore.ToString();
            common.TEAM_A_COLOR = Color.blue;
            common.TEAM_B_KILLS = "Leading AI: " + topScore.ToString();
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