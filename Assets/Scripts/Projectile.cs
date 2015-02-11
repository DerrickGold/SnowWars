using UnityEngine;
using System.Collections;

public class Projectile : MonoBehaviour
{
    [SerializeField]
    private new AudioSource audio;
	private bool collided = false;

	void Start() 
    {
		audio = GetComponent<AudioSource> ();
	}
	
	void Update() 
    {
		if(collided && !audio.isPlaying)
            Destroy(gameObject);
	}

	void OnCollisionEnter(Collision collision) 
    {
		audio.Play();
		collided = true;

		Destroy (rigidbody);
		Destroy (collider);
        GetComponent<MeshRenderer>().enabled = false;
	}

}
