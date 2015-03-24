using UnityEngine;
using System.Collections;

public class HitBox : MonoBehaviour {

	public bool isHit;
	public float Damage = 0.0f;

	// Use this for initialization
	void Start () {

	}

	// Update is called once per frame
	void Update () {

	}


	public void reset() {
		isHit = false;
		Damage = 0.0f;
	}


	void OnTriggerEnter(Collider collision) {
		if (collision.tag == "Snowball") {
			isHit = true;

			Projectile snowBall = collision.gameObject.GetComponent<Projectile>();
			Damage = snowBall.damage;

		}
	}

}
