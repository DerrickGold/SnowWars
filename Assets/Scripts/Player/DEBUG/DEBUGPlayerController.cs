/// <summary> 
/// Charactercontrollercs.cs 
/// Character Controller in CSharp v2.3 
/// </summary> 
using UnityEngine; 

public class DEBUGPlayerController : MonoBehaviour 
{
    //Player variables
    private bool grounded = false;
    private bool isJumping = false;
     
    //Movement speeds 
    private float jumpSpeed = 10.0f;
     
    private Vector3 moveDirection = Vector3.zero;
    private CharacterController controller;

    //Static variables
    private static float GRAVITY = 30.0f;

    void Start()
    {
        //Get CharacterController
        controller = GetComponent<CharacterController>();
    }

    void Update () 
    {
        Movement();
    }

    void Movement()
    {
        //Only allow movement and jumps while grounded 
        if (grounded)
        {
            moveDirection = new Vector3((Input.GetMouseButton(1) ? Input.GetAxis("Horizontal") : 0), 0, Input.GetAxis("Vertical"));

            //Strafing move (like Q/E movement)
            moveDirection.x -= Input.GetAxis("Strafing");

            //If moving forward and to the side at the same time, compensate for distance 
            if (Input.GetMouseButton(1) && (Input.GetAxis("Horizontal") != 0) && (Input.GetAxis("Vertical") != 0))
                moveDirection *= 0.7f;

            //Use run or walkspeed 
            moveDirection *= 5.0f;

            //Change the transform direction 
            moveDirection = transform.TransformDirection(moveDirection);
        }

        //Jump
        if (Input.GetButton("Jump") && isJumping == false)
        {
            isJumping = true;
            moveDirection.y = jumpSpeed;
        }

        //Allow turning at anytime. Keep the character facing in the same direction as the Camera if the right mouse button is down. 
        if (Input.GetMouseButton(1))
            transform.rotation = Quaternion.Euler(0, Camera.main.transform.eulerAngles.y, 0);

        //Apply gravity
        moveDirection.y -= GRAVITY * Time.deltaTime;

        //Make sure the player doesn't fall faster than gravity
        if (moveDirection.y < -GRAVITY)
            moveDirection.y = -GRAVITY;

        //Move Charactercontroller and check if grounded
        grounded = ((controller.Move(moveDirection * Time.deltaTime)) & CollisionFlags.Below) != 0;

        //Reset jumping after landing
        isJumping = grounded ? false : isJumping;

        //Keep the player on the ground when not jumping
        GroundPlayer();
    }
    
    /****************************************************************************************************
     * Description: Keeps the player on the ground when the player is not jumping                       *
     ****************************************************************************************************/
    void GroundPlayer()
    {
        //Not jumping?
        if (!isJumping)
        {
            RaycastHit hit;
            Vector3 slopeAdjust = Vector3.zero;
            if (Physics.Raycast(transform.position, -Vector3.up, out hit))
            {
                //Make sure not to drop the player if they fall from too high a place
                if (hit.distance < 2.0)
                {
                    slopeAdjust = new Vector3(slopeAdjust.x, hit.distance - controller.height / 2, slopeAdjust.z);
                    controller.Move(MoveTo(new Vector3(transform.position.x, transform.position.y - slopeAdjust.y, transform.position.z)));
                }
            }
        }
    }

    /****************************************************************************************************
     * Description: Instantly move a gameobject using controller.Move and not transform.position        *
     ****************************************************************************************************/
    Vector3 MoveTo(Vector3 newPos)
    {
        Vector3 moveVector = newPos - transform.position;
        return moveVector;
    }
}