using UnityEngine;
using System.Collections;

public class HitBox : MonoBehaviour {

	public bool isHit;
	public float Damage = 0.0f;

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
