using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class BuffPickup : MonoBehaviour {

	private float buffDisplay;
	private bool buffAquired;
	private Text[] buffText = new Text[2];
	// Use this for initialization
	void Start () {
		buffAquired = false;
	}
	
	// Update is called once per frame

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

	void OnTriggerEnter(Collider other) 
	{
		if (other.gameObject.tag == "PickUp")
		{
			Rotator buffScript = other.gameObject.GetComponent<Rotator>(); //get the script
			buffScript.destroy = true;
			//other.gameObject.SetActive(false); //deactivate the buff object
			/*
			Rotator buffScript = other.gameObject.GetComponent<Rotator>(); //get the script
			Text buff = buffScript.buffText; //get the buff info text
			buffText[0] = buffScript.buffText; 
			//buffText[0] = buff;
			buffText[1] = buffScript.buffIcon; //store the buff icon text
			//buffText = {buffScript.buffText, buffScript.buffIcon};
			buff.gameObject.SetActive(true); //set the buff info text to true
			buffDisplay = Time.time; 
			buffAquired = true; //we picked up a buff 
			*/
		}

	}
}
