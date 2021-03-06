/****************************************************************************************************
 * Primary Contributor: Unity Forums
 * Secondary Contributor: Curtis Murray
 * 
 * Description: This script is used for when the palyer dies. If the player has chosen to use third
 *              person upon death, this script will take control of the camera and zoom out so the
 *              player can see their ragdolled corpse.
 *              
 * Disclaimer: This script is a work-in-progress, as several minds across the world online have
 *             assisted in the creation of this script. This script is constantly being modified
 *             and tweaked to try and recreate the camera from the infamous MMORPG World of Warcraft.
 ****************************************************************************************************/
	using UnityEngine;
    using System.Collections;

public class ThirdPersonCameraController : MonoBehaviour 
{  
    public GameObject target;                  // Target to follow
    public float targetHeight = 1.0f;          // Vertical offset adjustment
    public float distance = 12.0f;             // Default Distance
    public float offsetFromWall = 0.1f;        // Bring camera away from any colliding objects
    public float maxDistance = 20f;            // Maximum zoom Distance
    public float minDistance = 0.6f;           // Minimum zoom Distance
    public float xSpeed = 200.0f;              // Orbit speed (Left/Right)
    public float ySpeed = 200.0f;              // Orbit speed (Up/Down)
    public float yMinLimit = -80f;             // Looking up limit
    public float yMaxLimit = 80f;              // Looking down limit
    public float zoomRate = 40f;               // Zoom Speed
    public float rotationDampening = 3.0f;     // Auto Rotation speed (higher = faster)
    public float zoomDampening = 5.0f;         // Auto Zoom speed (Higher = faster)
    public LayerMask collisionLayers = -1;     // What the camera will collide with
    public bool lockToRearOfTarget = false;    // Lock camera to rear of target
    public bool allowMouseInputX = true;       // Allow player to control camera angle on the X axis (Left/Right)
    public bool allowMouseInputY = true;       // Allow player to control camera angle on the Y axis (Up/Down)
         
    private float xDeg = 0.0f;
    private float yDeg = 0.0f;
    private float currentDistance;
    private float desiredDistance;
    private float correctedDistance;
    private bool rotateBehind = false;
    private bool mouseSideButton = false;   
    private float pbuffer = 0.0f;              //Cooldownpuffer for SideButtons
//    private float coolDown;             //Cooldowntime for SideButtons 
    public bool shake = false;                   //Should the camera shake?
    public float shakeAmount = 0.0f;           // Amplitude of the shake. A larger value shakes the camera harder.

    private bool editMode = true;


    /****************************************************************************************************
     * Description: Used to initialized required variables.                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start ()
    {      
        Vector3 angles = transform.eulerAngles;
        xDeg = angles.x;
        yDeg = angles.y;
        currentDistance = distance;
        desiredDistance = distance;
        correctedDistance = distance;
           
        // Make the rigid body not change rotation
        if (rigidbody)
            rigidbody.freezeRotation = true;
               
        if (lockToRearOfTarget)
            rotateBehind = true;
        }


    /****************************************************************************************************
     * Description: Used to check to make sure the camera always has a target to look at.               *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        if (target == null)
        {
            target = GameObject.FindGameObjectWithTag("Player") as GameObject;
            Debug.Log("Looking for Player");
        }
    }

    
    /****************************************************************************************************
     * Description: Used to control the cameras movement and behaviour.                                 *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void LateUpdate ()
    {
        // Don't do anything if target is not defined
        if (target == null)
            return;
        if(pbuffer>0)
            pbuffer -=Time.deltaTime;
        if(pbuffer<0)pbuffer=0;
            
    	if(mouseSideButton && Input.GetAxis("Vertical") != 0 )
    		mouseSideButton = false;		
           
        Vector3 vTargetOffset;
                       
        // If either mouse buttons are down, let the mouse govern camera position
        if (GUIUtility.hotControl == 0)
        {
            if ((Input.GetMouseButton(0) && editMode == false) || Input.GetMouseButton(1))
            {
                //Check to see if mouse input is allowed on the axis
                if (allowMouseInputX)
                    xDeg += Input.GetAxis ("Mouse X") * xSpeed * 0.02f;
                else
                    RotateBehindTarget();
                if (allowMouseInputY)
                    yDeg -= Input.GetAxis ("Mouse Y") * ySpeed * 0.02f;
                   
                //Interrupt rotating behind if mouse wants to control rotation
                if (!lockToRearOfTarget)
                    rotateBehind = false;
            }
     
            //Otherwise, ease behind the target if any of the directional keys are pressed
            else if (Input.GetAxis("Vertical") != 0 || Input.GetAxis("Horizontal") != 0 || rotateBehind || mouseSideButton)
                RotateBehindTarget();
        }
        yDeg = ClampAngle (yDeg, yMinLimit, yMaxLimit);
         
        // Set camera rotation
        Quaternion rotation = Quaternion.Euler (yDeg, xDeg, 0);
         
        // Calculate the desired distance
        desiredDistance -= Input.GetAxis ("Mouse ScrollWheel") * Time.deltaTime * zoomRate * Mathf.Abs (desiredDistance);
        desiredDistance = Mathf.Clamp (desiredDistance, minDistance, maxDistance);
         
        // Calculate desired camera position
        vTargetOffset = new Vector3 (0, -targetHeight, 0);
        Vector3 position = target.transform.position - (rotation * Vector3.forward * desiredDistance + vTargetOffset);
         
        // For smoothing, lerp distance only if either distance wasn't corrected, or correctedDistance is more than currentDistance
        currentDistance = correctedDistance > currentDistance ? Mathf.Lerp (currentDistance, correctedDistance, Time.deltaTime * zoomDampening) : correctedDistance;
         
        // Keep within limits
        currentDistance = Mathf.Clamp (currentDistance, minDistance, maxDistance);
         
        // Recalculate position based on the new currentDistance
        position = target.transform.position - (rotation * Vector3.forward * currentDistance + vTargetOffset);
           
        // Finally Set rotation and position of camera
        transform.rotation = rotation;
        transform.position = position;
    }


    /****************************************************************************************************
     * Description: This is a helper function. Used to rotate the camera behind the player when needed. *
     * Syntax: RotateBehindTarget();                                                                    *
     ****************************************************************************************************/
    private void RotateBehindTarget()
    {
        float targetRotationAngle = target.transform.eulerAngles.y;
        float currentRotationAngle = transform.eulerAngles.y;
        xDeg = Mathf.LerpAngle (currentRotationAngle, targetRotationAngle, rotationDampening * Time.deltaTime);
           
        // Stop rotating behind if not completed
        if (targetRotationAngle == currentRotationAngle)
        {
            if (!lockToRearOfTarget)
                rotateBehind = false;
        }
        else
            rotateBehind = true;
         
    }


    /****************************************************************************************************
     * Description: Used to set the distance the camera should be at in relation to the player.         *
     * Syntax: SetDesiredDistance(float newDesiredDistance);                                            *
     * Values:                                                                                          *
     *          newDesiredDistance = the new distance the camera should float at                        *
     ****************************************************************************************************/
    public void SetDesiredDistance(float newDesiredDistance)
    {
        desiredDistance = newDesiredDistance;
    }

         
    /****************************************************************************************************
     * Description: ################################################################################### *
     * Syntax: float value = ClampAngle(float angle, float min, float max);                             *
     * Values:                                                                                          *
     *          angle = ############################################################################### *
     *          min = ################################################################################# *
     *          max = ################################################################################# *
     * Returns: float representing #################################################################### *
     ****************************************************************************************************/
    private float ClampAngle (float angle, float min, float max)
    {
        if (angle < -360f)
            angle += 360f;
        if (angle > 360f)
            angle -= 360f;
        return Mathf.Clamp (angle, min, max);
    }
}