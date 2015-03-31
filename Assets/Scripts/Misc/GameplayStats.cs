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

    public GameObject AIprefab;
    public GameObject player;

    public int teamSizeA = 16;
    public int teamSizeB = 16;
    public float TEAM_A_KILLS = 0;
    public float TEAM_B_KILLS = 0;

    public GameObject SpawnpointsA;
    public GameObject SpawnpointsB;

    //private Transform[] spawnA;
    //private Transform[] spawnB;

    private List<Transform> spawnA = new List<Transform>();
    private List<Transform> spawnB = new List<Transform>();


    // Use this for initialization
    void Start()
    {
        //determine which team the main player is on
        int team = Random.Range(0, 2);
        //team A if team = 0 and team B if team = 1

        //get a list of spawn points for both teams
        foreach (Transform child in SpawnpointsA.transform)
        {
            //spawnA[idx++] = child;
            spawnA.Add(child);
        }
        foreach (Transform child in SpawnpointsB.transform)
        {
            //spawnB[idx++] = child;
            spawnB.Add(child);
        }

        //this is for the player
        if (team == 0)
        {
            teamSizeA--; //one less player for this team
            //player.transform.position = spawnA[0].position + new Vector3(0, 1f, 0);
            GameObject play = (GameObject)Instantiate(player, spawnA[0].position + new Vector3(0, 1f, 0), spawnA[0].rotation);
			play.tag = "TeamA";
        }
        else
        {
            teamSizeB--; //one less player for this team
            //player.transform.position = spawnB[0].position + new Vector3(0, 1f, 0);
			GameObject play = (GameObject)Instantiate(player, spawnB[0].position + new Vector3(0, 1f, 0), spawnB[0].rotation);
			play.tag = "TeamB";
        }

        int spawnpoint;
        //spawn all snowmen
        for (int i = 0; i < teamSizeA; i++)
        {
            spawnpoint = Random.Range(0, spawnA.Count); //random spawn location for this team
            GameObject AI = (GameObject)Instantiate(AIprefab, spawnA[spawnpoint].position + new Vector3(0, 1f, 0), transform.rotation);
			AI.tag = "TeamA";

        }
        for (int i = 0; i < teamSizeB; i++)
        {
            spawnpoint = Random.Range(0, spawnB.Count); //random spawn location for this team
			GameObject AI = (GameObject)Instantiate(AIprefab, spawnB[spawnpoint].position + new Vector3(0, 1f, 0), transform.rotation);
			AI.tag = "TeamB";
        }

    }

    // Update is called once per frame
    void Update()
    {

    }
}
