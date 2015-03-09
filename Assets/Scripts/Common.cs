using UnityEngine;
using System.Collections;

public class Common: MonoBehaviour {
    //Player variables
	static public int MaxPlayers = 32;
	static public GameObject player;

    //AI variables
	public GameObject[] ai;

    //Sound variables
	public enum AudioSFX {
			THROW, SNOWBALL_HIT, FOOTSTEP
	};
	static public AudioSource[] sfx;

    //Game variables
	static public GameObject SnowBall;
}