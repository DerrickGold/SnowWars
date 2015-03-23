using UnityEngine;
using System.Collections;

public class HitBox : MonoBehaviour {

	public bool isHit;

	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
	
	}


	public void reset() {
		isHit = false;
	}


	void OnTriggerEnter(Collider collision) {
		if (collision.tag == "Snowball") {
			isHit = true;
		}
	}

}
