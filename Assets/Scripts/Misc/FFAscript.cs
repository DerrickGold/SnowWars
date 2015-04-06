using UnityEngine;
using System.Collections;

public class FFAscript : MonoBehaviour {
	private Common common;
	public GameObject AIprefab;
	public GameObject player;

	private int maxPlayerSize;
	private int topScore;
	private int secondScore;
	private int playerScore;

	// Use this for initialization
	void Start () {
		common = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common> ();

	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
