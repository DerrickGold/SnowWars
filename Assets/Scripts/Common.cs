﻿using UnityEngine;
using System.Collections;

public class Common: MonoBehaviour {
    //Player variables
	static public int MaxPlayers = 32;
	static public int AIViewRange = 20;
	static public float MaxThrowForce = 1200.0f;

	static public int BaseMaxHealth = 100;
	static public int MaxHealthBoost = 20;
	//how much health to take away for every throw
	static public int AmmoSubtractAmmount = 1;
	static public int SuperSnowSubtract = 5;

	static public float BaseWalkSpeed = 4.0f;
	static public float SpeedBoost = 1.0f;

	static public int BaseSnowBallDamage = 15;
	static public int SuperSnowBallBoost = 15;



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