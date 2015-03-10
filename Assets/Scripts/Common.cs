using UnityEngine;
using System.Collections;

public class Common: MonoBehaviour {
    //Player variables
	static public int MaxPlayers = 32;
	static public int AIViewRange = 20;
	static public float MaxThrowForce = 1200.0f;
	static public GameObject player;

    //AI variables
	public GameObject[] ai;

    //Sound variables
	public enum AudioSFX {
			THROW, SNOWBALL_HIT, FOOTSTEP
	};
	static public AudioClip[] sfx;

    //Game variables
	public GameObject SnowBall;
}