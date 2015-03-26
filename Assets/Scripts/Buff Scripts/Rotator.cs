/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: This script controls the movement of the physical buffs laying around the levels.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Rotator : MonoBehaviour {
	public Text buffText;
	public Text buffIcon;
	private Vector3 originalPos;
	public float buffBounceSpeed;
	public float buffBounceHeight;
	public bool destroy = false;


    /****************************************************************************************************
     * Description: Used to initialized required variables.                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start()
	{
		buffBounceSpeed = 2f;
		buffBounceHeight = 2f;
		originalPos = transform.position;
	}


    /****************************************************************************************************
     * Description: Used to give the physical buff a bouncing effect.                                   *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update () 
	{
		if (destroy) gameObject.SetActive(false);
		transform.position = new Vector3 (originalPos.x, originalPos.y + buffBounceHeight * Mathf.Abs (Mathf.Sin (Time.time*buffBounceSpeed)), originalPos.z);
	}
}
