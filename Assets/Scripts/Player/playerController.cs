using UnityEngine;
using System.Collections;

public class playerController : MonoBehaviour 
{
	[SerializeField]
	private GameObject snowball;
    [SerializeField]
    private Transform snowballSpawn;
	[SerializeField]
	private new AudioSource audio;
    [SerializeField]
    private int throwSpeed = 1200;

    //DEBUG MODE VARIABLES
    private bool debugMode = false;
    public MouseLook mouseXScript;
    public MouseLook mouseYScript;
    public DEBUGCameraController cameraScript;
    public DEBUGPlayerController playerScript;
    public Builder builderScript;
    public Transform debugPosition;

	void Update () 
	{
		if (Input.GetButtonDown("Fire1") && !debugMode)
		{
			Rigidbody instantiatedProjectile = Instantiate(snowball.rigidbody, snowballSpawn.position, snowballSpawn.rotation) as Rigidbody;
			instantiatedProjectile.AddForce(snowballSpawn.forward * throwSpeed);
			audio.Play();
		}

        //DEBUG MODE (REMOVE BEFORE SUBMISSION)
        if (Input.GetKeyDown(KeyCode.BackQuote))
        {
            debugMode = Input.GetKeyDown(KeyCode.BackQuote) ? !debugMode : debugMode;
            if (debugMode)
            {
                mouseXScript.enabled = mouseYScript.enabled = false;
                cameraScript.enabled = playerScript.enabled = builderScript.enabled = true;
            }
            else
            {
                mouseXScript.enabled = mouseYScript.enabled = true;
                cameraScript.enabled = playerScript.enabled = builderScript.enabled = false;
                Camera.main.transform.position = new Vector3(Camera.main.transform.parent.position.x, Camera.main.transform.parent.position.y + 1, Camera.main.transform.parent.position.z);
                Camera.main.transform.rotation = debugPosition.rotation;
            }
        }
	}
}