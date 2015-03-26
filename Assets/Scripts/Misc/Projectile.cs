/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray
 * 
 * Description: This script is the driving force of the snowball. Lets the snowball keep track of
 *              important information such as the damage output it does, the owner of the snowball,
 *              the sound associated with the snowball, etc.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Projectile : MonoBehaviour
{
    private AudioSource audio;
    public Transform origin;
    public float originHP;
    private float speed = 60.0f;
    public float damage = Common.BaseSnowBallDamage;
	bool collided = false;


    /****************************************************************************************************
     * Description: Used to initialize required variables.                                              *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start() {
		audio = GetComponent<AudioSource>();
	}


    /****************************************************************************************************
     * Description: Keeps track of projectile trajectory. Deletes projectile when required.             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update() {
        //Destroy the gameobject if it hit the ground and the hit sound is finished playing
        if (collided && !audio.isPlaying)
            Destroy(gameObject);
        //Disable the sphere collider and mesh renderer upon collision
        else if (collided)
            GetComponent<MeshRenderer>().enabled = false;
	}


    /****************************************************************************************************
     * Description: Called when the projectile collides with something.                                 *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnCollisionEnter(Collision collision) {
		audio.Play();
		collided = true;

		Destroy (rigidbody);
		Destroy (collider);
	}
}
