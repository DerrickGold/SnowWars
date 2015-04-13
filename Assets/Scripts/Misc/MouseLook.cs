/****************************************************************************************************
 * Primary Contributors: Unity Technologies
 * Secondary Contributors: Curtis Murray
 * 
 * Description: This script rotates the transform based on the mouse delta. Minumum and Maximum
 *              values can be used to constrain the possible rotation.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

[AddComponentMenu("Camera-Control/Mouse Look")]
public class MouseLook : MonoBehaviour
{
	public enum RotationAxes { MouseXAndY = 0, MouseX = 1, MouseY = 2 }
	public RotationAxes axes = RotationAxes.MouseXAndY;
	public float sensitivityX = 15F;
	public float sensitivityY = 15F;

	public float minimumX = -360F;
	public float maximumX = 360F;

	public float minimumY = -60F;
	public float maximumY = 60F;

	float rotationY = 0F;

    private bool editMode = false;


    /****************************************************************************************************
     * Description: Used to make sure the rigidbody does not change rotation.                           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start()
    {
        if (GetComponent<Rigidbody>())
            GetComponent<Rigidbody>().freezeRotation = true;
    }


    /****************************************************************************************************
     * Description: Used to control the camera. Also used to allow the player to enter a debug mode     *
     *              which unlocks the mouse from the center of the screen. This will be disabled upon   *
     *              completion of the game.                                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update ()
	{
        //Check to see if player wants to go into edit mode
        if (Input.GetKeyDown (KeyCode.BackQuote)) {
			editMode = !editMode;
			Screen.lockCursor = !editMode;
		}


        //Edit mode
        if (editMode == false)
        {
            if (axes == RotationAxes.MouseXAndY)
            {
                float rotationX = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * sensitivityX;

                rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
                rotationY = Mathf.Clamp(rotationY, minimumY, maximumY);

                transform.localEulerAngles = new Vector3(-rotationY, rotationX, 0);
            }
            else if (axes == RotationAxes.MouseX)
            {
                transform.Rotate(0, Input.GetAxis("Mouse X") * sensitivityX, 0);
            }
            else
            {
                rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
                rotationY = Mathf.Clamp(rotationY, minimumY, maximumY);

                transform.localEulerAngles = new Vector3(-rotationY, transform.localEulerAngles.y, 0);
            }
        }
	}
}