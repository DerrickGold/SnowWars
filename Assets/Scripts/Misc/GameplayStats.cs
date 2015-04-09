/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: This script is placed on the global game object. This keeps track of all the gameplay
 * statistics and manages spawning players when they die and at the beginning of the match.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GameplayStats : MonoBehaviour
{
	private Common common;

    public GameObject AIprefab;
    public GameObject player;

    public int teamSizeA = 16;
    public int teamSizeB = 16;
    public int TEAM_A_KILLS = 0;
    public int TEAM_B_KILLS = 0;
	public int GAME_MAX_SCORE = 20;

    public GameObject SpawnpointsA;
    public GameObject SpawnpointsB;

    private List<Transform> spawnA = new List<Transform>();
    private List<Transform> spawnB = new List<Transform>();

	private List<GameObject> teamA = new List<GameObject> ();
	private List<GameObject> teamB = new List<GameObject> ();

    private List<string> hatColors = new List<string>();


    void Start()
    {
		common = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common> ();
		Transform buffsObj = GameObject.FindGameObjectWithTag ("Buffs").transform; //get all the buffs in the map
		for (int i = 0; i < buffsObj.childCount; i++) { //add all the buffs to the list of buffs
			common.buffs.Add(buffsObj.GetChild(i));
		}
        //Choose a random color of hat for each team
        populateHatColors();
        int teamOneColor = Random.Range(0, hatColors.Count);
        int teamTwoColor;
        do
            teamTwoColor = Random.Range(0, hatColors.Count);
        while (teamOneColor == teamTwoColor);

        //Determine which team the main player is on
        int team = Random.Range(0, 2); //team A = 0 || team B = 1

        //Get a list of spawn points for both teams
        foreach (Transform child in SpawnpointsA.transform)
            spawnA.Add(child);
        foreach (Transform child in SpawnpointsB.transform)
            spawnB.Add(child);

        //This is for the player
        if (team == 0) {
            teamSizeA--;
            GameObject play = (GameObject)Instantiate(player, spawnA[0].position + new Vector3(0, 1f, 0), spawnA[0].rotation);
			teamA.Add(play); //add player to team A list
			play.tag = "TeamA";
            play.GetComponent<PlayerController>().setHatColor(hatColors[teamOneColor]);
			common.TEAM_A_COLOR = Color.blue;
			common.TEAM_B_COLOR = Color.red;
        }
        else {
            teamSizeB--;
			GameObject play = (GameObject)Instantiate(player, spawnB[0].position + new Vector3(0, 1f, 0), spawnB[0].rotation);
			teamB.Add(play); //add player to team B list
			play.tag = "TeamB";
            play.GetComponent<PlayerController>().setHatColor(hatColors[teamTwoColor]);
			common.TEAM_A_COLOR = Color.red;
			common.TEAM_B_COLOR = Color.blue;
        }

        //Spawn all snowmen
        int spawnpoint;
        for (int i = 0; i < teamSizeA; i++)
        {
            //Random spawn location for this team
            spawnpoint = Random.Range(0, spawnA.Count);
            GameObject AI = (GameObject)Instantiate(AIprefab, spawnA[spawnpoint].position + new Vector3(0, 1f, 0), transform.rotation);
			teamA.Add(AI); //add AI to team A list
			AI.tag = "TeamA";
            AI.GetComponent<AIController>().setHatColor(hatColors[teamOneColor]);

        }
        for (int i = 0; i < teamSizeB; i++)
        {
            //Random spawn location for this team
            spawnpoint = Random.Range(0, spawnB.Count);
			GameObject AI = (GameObject)Instantiate(AIprefab, spawnB[spawnpoint].position + new Vector3(0, 1f, 0), transform.rotation);
			teamB.Add(AI); //add AI to team B list
			AI.tag = "TeamB";
            AI.GetComponent<AIController>().setHatColor(hatColors[teamTwoColor]);
        }
    }

	void Update()
	{
		TEAM_A_KILLS = 0;
		TEAM_B_KILLS = 0;
		foreach (GameObject snowman in teamA) {
			TEAM_A_KILLS += snowman.GetComponent<CharacterBase> ().score;
		}
		foreach (GameObject snowman in teamB) {
			TEAM_B_KILLS += snowman.GetComponent<CharacterBase> ().score;
		}
		common.TEAM_A_KILLS = TEAM_A_KILLS;
		common.TEAM_B_KILLS = TEAM_B_KILLS;
		
		if (TEAM_A_KILLS == GAME_MAX_SCORE) {
			common.alertText.text = "Team A Wins!";
		}
		else if (TEAM_B_KILLS == GAME_MAX_SCORE){
			common.alertText.text = "Team B Wins!";
		}
	}

    /****************************************************************************************************
     * Description: This is a helper function. This simply populates the list of hat colors that can    *
     *              be chosen from.                                                                     *
     * Syntax: populateHatColors();                                                                     *
     ****************************************************************************************************/
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