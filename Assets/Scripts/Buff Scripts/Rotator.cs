/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins                                                            *
 *                                                                                                  *
 * Description: This script controls the movement of the physical buffs laying around the levels.   *
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Rotator : MonoBehaviour
{
	public Text buffText;
	public Text buffIcon;
	private Vector3 originalPos;
	public float buffBounceSpeed;
	public float buffBounceHeight;
	private bool destroyed = false;
	public float cooldownTime = 5f;
	private float pickedUpTime;


    /****************************************************************************************************
     * Description: Used to initialized required variables.                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start()
	{
		originalPos = transform.position;
	}


    /****************************************************************************************************
     * Description: Used to give the physical buff a bouncing effect.                                   *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update () 
	{
		if(!destroyed)
            transform.GetChild(0).gameObject.SetActive (true);

		transform.position = new Vector3 (originalPos.x, originalPos.y + buffBounceHeight * Mathf.Abs (Mathf.Sin (Time.time*buffBounceSpeed)), originalPos.z);
	}

	public void destroy()
    {
		destroyed = true;
		pickedUpTime = Time.time;
		transform.GetChild(0).gameObject.SetActive (false);
		StartCoroutine("cooldown");
	}

	public IEnumerator cooldown()
    {
		while((Time.time-pickedUpTime) < cooldownTime )
			yield return null;
		destroyed = false;
	}
}
