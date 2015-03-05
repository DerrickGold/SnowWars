using UnityEngine;
using System.Collections;

public class Common: MonoBehaviour {
	public static int MaxPlayers = 32;
	public GameObject player;

	public GameObject[] ai;

	public enum AudioSFX {
			THROW, SNOWBALL_HIT, FOOTSTEP
	};
	private AudioSource[] sfx; 

	public GameObject SnowBall;





}
