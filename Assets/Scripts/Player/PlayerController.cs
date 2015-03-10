using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    //Player variables
    private Vector3 moveDirection = Vector3.zero;
    private CharacterController controller;

    private bool isWalking = false;
    private bool isJumping = false;
    private bool isGrounded = false;

    private float hp = 100.0f;

    private float walkSpeed = 10.0f;
    private float runSpeed = 20.0f;
    private float jumpSpeed = 10.0f;
    private float gravity = 30.0f;

    private Common globalScript;

    //Game variables
    //public GameObject snowball;

    void Start()
    {
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        controller = GetComponent<CharacterController>();
    }

    void Update()
    {
        Movement();
    }

    /*
     * Description: Deals with the movement of the player
     */
    void Movement()
    {
        //Hold "Run" to stop running
        isWalking = true;
        if (Input.GetKey(KeyCode.LeftShift))
            isWalking = !isWalking;

        //Only allow movement and jumps while isGrounded 
        if (isGrounded)
        {
            moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));

            //If moving forward and to the side at the same time, compensate for distance 
            if (Input.GetMouseButton(1) && (Input.GetAxis("Horizontal") != 0) && (Input.GetAxis("Vertical") != 0))
                moveDirection *= 0.7f;

            //Use run or walkspeed 
            moveDirection *= isWalking ? walkSpeed : runSpeed;

            moveDirection = transform.TransformDirection(moveDirection);
        }

        //Jump
        if (Input.GetButton("Jump") && !isJumping)
        {
            isJumping = true;
            moveDirection.y = jumpSpeed;
        }

        //Apply gravity
        moveDirection.y -= gravity * Time.deltaTime;

        //Make sure the player doesn't fall faster than gravity
        if (moveDirection.y < -70)
            moveDirection.y = -70;

        //Move Charactercontroller and check if isGrounded
        if (controller != null)
            isGrounded = ((controller.Move(moveDirection * Time.deltaTime)) & CollisionFlags.Below) != 0;

        //Check if the player has landed after jumping
        isJumping = isGrounded ? false : isJumping;

        //Keep the player on the ground when they are not jumping
        //GroundPlayer();
    }

    /*
     * Description: Keeps the player on the ground when walking down hills (Prevents bouncing)
     */
    void GroundPlayer()
    {
        //Make sure the player is not jumping
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

    Vector3 MoveTo(Vector3 newPos)
    {
        Vector3 moveVector = newPos - transform.position;
        return moveVector;
    }
}