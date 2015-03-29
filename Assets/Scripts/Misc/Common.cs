/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray
 * 
 * Description: Keeps track of any global variables and gameobjects. This script can be called by
 *              any other script to access any of its variables
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Common: MonoBehaviour {
    public GameObject player;

    //AI variables
	public GameObject[] ai;

    //Sound variables
	public enum AudioSFX {
			SNOWBALL_THROW = 0, SNOWBALL_HIT = 1
	};
	public AudioSource[] sfx;

    //Game variables
	public GameObject SnowBall;
    public GameObject DeathExplosion;
}