using UnityEngine;
using System.Collections;

public class Common: MonoBehaviour {
    //Player variables
	static public int MaxPlayers = 32;
	static public int AIViewRange = 50;
	static public float AIAimAdjustFactor = 1.0f;
	static public float MaxThrowForce = 20;

	static public int BaseMaxHealth = 100;
	static public int MaxHealthBoost = 20;

	static public int BaseMaxStamina = 100;

	//How much health to take away for every throw
	static public int AmmoSubtractAmmount = 100;
	static public int SuperSnowSubtract = 5;

	static public float BaseWalkSpeed = 4.0f;
	static public float SpeedBoost = 1.0f;

	static public int BaseSnowBallDamage = 15;
	static public int SuperSnowBallBoost = 15;

	static public float RespawnTime = 1.0f; //in seconds

    public GameObject player;

    //AI variables
	public GameObject[] ai;

    //Sound variables
	public enum AudioSFX {
			SNOWBALL_THROW = 0, SNOWBALL_HIT = 1, FOOTSTEP = 2
	};
	public AudioSource[] sfx;

    //Game variables
	public GameObject SnowBall;
}