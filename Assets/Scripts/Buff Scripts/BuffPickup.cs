/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickens
 * 
 * Description: This script is attached to any gameobject that is a buff. PLEASE ADD MORE OF A
 *              DESCRIPTION HERE.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class BuffPickup : MonoBehaviour {

	private float buffDisplay;
	private bool buffAquired;
	private Text[] buffText = new Text[2];


    /****************************************************************************************************
     * Description: Used to initialize required variables.                                              *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start () {
		buffAquired = false;
	}


    /****************************************************************************************************
     * Description: PLEASE CHECK IF UPDATE IS REQUIRED. IF NOT, PLEASE REMOVE.                          *
     * Syntax: ---
     ****************************************************************************************************/
    /*
    void Update () {
        if (buffAquired) {
            if(Time.time-buffDisplay > 2.5f){
                //print (Time.time + " " + buffDisplay);
                buffText[0].gameObject.SetActive(false);
                buffText[1].gameObject.SetActive(true);
                buffAquired= false;
            }
        }
    }*/


    /****************************************************************************************************
     * Description: Called when something collides with the buff.                                       *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnTriggerEnter(Collider other) 
	{
		if (other.gameObject.tag == "PickUp")
		{
			Rotator buffScript = other.gameObject.GetComponent<Rotator>();
			buffScript.destroy = true;
            /*
			other.gameObject.SetActive(false);
			Rotator buffScript = other.gameObject.GetComponent<Rotator>();
			Text buff = buffScript.buffText;
			buffText[0] = buffScript.buffText; 
			buffText[0] = buff;
			buffText[1] = buffScript.buffIcon;
			buffText = {buffScript.buffText, buffScript.buffIcon};
			buff.gameObject.SetActive(true);
			buffDisplay = Time.time; 
			buffAquired = true; //we picked up a buff 
			*/
		}

	}
}
