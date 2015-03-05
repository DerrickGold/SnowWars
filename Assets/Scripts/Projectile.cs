using UnityEngine;
using System.Collections;

public class Projectile : MonoBehaviour {
	float speed = 60.0f;
	bool collided = false;
	private AudioSource audio;
	// Use this for initialization
	void Start () {
		audio = GetComponent<AudioSource> ();

	}
	
	// Update is called once per frame
	void Update () {
		if(collided && !audio.isPlaying) Destroy (gameObject);
	}

	void OnCollisionEnter(Collision collision) {
		audio.Play ();
		collided = true;
		//stop the snowball in its track
		Destroy (rigidbody);
		Destroy (collider);
	}

}
