using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class BulletTest : MonoBehaviour {


	public GameObject projectile;
	private AudioSource audio;


	// Use this for initialization
	void Start () {
		//audio = GetComponentInChild<AudioSource> ();audio
		audio = GetComponentInChildren<AudioSource> ();
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetButtonDown("Fire1"))
		{
			Rigidbody instantiatedProjectile = Instantiate(projectile.rigidbody,
			                                               transform.position,
			                                               transform.rotation)
				as Rigidbody;

			instantiatedProjectile.AddForce (transform.forward * 1200.0f);
			audio.Play ();
		
		}
	}
	
}
