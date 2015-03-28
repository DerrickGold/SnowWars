/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: This script is placed on the global game object. This keeps track of all the gameplay
 * statistics and manages spawning players when they die and at the beginning of the match.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GameplayStats : MonoBehaviour {

	public int teamSizeA = 16;
	public int teamSizeB = 16;
	public float TEAM_A_KILLS = 0;
	public float TEAM_B_KILLS = 0;

	public GameObject SpawnpointsA;
	public GameObject SpawnpointsB;

	//private Transform[] spawnA;
	//private Transform[] spawnB;

	private List<Transform> spawnA = new List<Transform> ();
	private List<Transform> spawnB = new List<Transform> ();

	public GameObject player;

	// Use this for initialization
	void Start () {
		player = GameObject.FindGameObjectWithTag ("Player");
		//determine which team the main player is on
		int team = Random.Range (0, 2);
		//team A if team = 0 and team B if team = 1

		//get a list of spawn points for both teams
		foreach (Transform child in SpawnpointsA.transform){
			//spawnA[idx++] = child;
			spawnA.Add(child);
		}
		foreach (Transform child in SpawnpointsB.transform){
			//spawnB[idx++] = child;
			spawnB.Add(child);
		}

		if(team == 0) {
			teamSizeA--;
			player.transform.position = spawnA[0].position + new Vector3(0, 1f, 0);
		}
		else {
			teamSizeB--;
			player.transform.position = spawnB[0].position + new Vector3(0, 1f, 0);
		}

		//spawn all snowmen
		for (int i = 0; i < teamSizeA; i++){

		}
		for (int i = 0; i < teamSizeB; i++){
			
		}

	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
