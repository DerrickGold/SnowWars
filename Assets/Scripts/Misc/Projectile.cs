using UnityEngine;
using System.Collections;

public class Projectile : MonoBehaviour
{
	float speed = 60.0f;
	bool collided = false;
	private AudioSource audio;
	public float damage = Common.BaseSnowBallDamage;
    public Transform origin;
    public float originHP;

	void Start()
    {
		audio = GetComponent<AudioSource>();
	}

	void Update()
    {
        //Destroy the gameobject if it hit the ground and the hit sound is finished playing
        if (collided && !audio.isPlaying)
            Destroy(gameObject);
        //Disable the sphere collider and mesh renderer upon collision
        else if (collided)
            GetComponent<MeshRenderer>().enabled = false;
	}

	void OnCollisionEnter(Collision collision)
    {
		audio.Play();
		collided = true;

        //Remove the physics of the snowball
		Destroy (rigidbody);
		Destroy (collider);
	}
}
