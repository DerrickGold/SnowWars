using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class TerrainFootprints : MonoBehaviour 
{
    [SerializeField]
	private new AudioSource audio;
	private CSCharacterMotor body;

	// Use this for initialization
	void Start () 
    {
		body = GetComponentInParent<CSCharacterMotor> ();
	}
	
	// Update is called once per frame
	void Update () 
    {
		float velocity = body.movement.velocity.magnitude;

		if (body.grounded && velocity > 1.0f && !audio.isPlaying) 
        {
			audio.pitch = (velocity / body.movement.maxForwardSpeed) + 1.0f;
			if (audio.pitch < 1.3f) audio.pitch = 1.3f;
			audio.Play ();
		}
		//player in air, stop footsteps
		else if (velocity < 1.0f && audio.isPlaying)
			audio.Stop ();
	}
}
