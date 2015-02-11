using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class BulletTest : MonoBehaviour 
{
	public GameObject projectile;
	[SerializeField]
	private new AudioSource audio;

	void Update () 
	{
		if (Input.GetButtonDown("Fire1"))
		{
			Rigidbody instantiatedProjectile = Instantiate(projectile.rigidbody, transform.position, transform.rotation) as Rigidbody;
			instantiatedProjectile.AddForce (transform.forward * 1200.0f);
			audio.Play();
		
		}
	}
}