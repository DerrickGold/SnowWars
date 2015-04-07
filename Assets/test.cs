using UnityEngine;
using System.Collections;

public class test : MonoBehaviour {

	RaycastHit testHit = new RaycastHit();

	// Use this for initialization
	void Start () {
		Debug.Log("Start");
	}
	
	// Update is called once per frame
	void Update () {
		Vector3 fwd = transform.TransformDirection(Vector3.down);
		Debug.Log ("lvl1");
		if (Physics.Raycast(transform.position, -transform.up,out testHit,10)){
			Debug.Log ("lvl2");
			if(testHit.collider.gameObject.tag == "WATER") {
				Debug.Log("found water");
			}
			else{
				Debug.Log ("not water");
			}
		}
	}
}

