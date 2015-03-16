using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    //Player variables
    private enum PlayerState
    {
        IDLE,
        WALKING,
        RUNNING
    };

    private Vector3 moveDirection = Vector3.zero;
    private CharacterController controller;
    private PlayerState playerState = PlayerState.IDLE;
    public Animation throwingAnimation;

    private bool isJumping = false;
    private bool isGrounded = false;

    private float hp = 100.0f;

    private float walkSpeed = 10.0f;
    private float runSpeed = 20.0f;
    private float jumpSpeed = 10.0f;
    private float gravity = 30.0f;

    //Game variables
    private Common globalScript;
    private AudioSource audio;
    public Transform snowballSpawnLocation;


    void Start()
    {
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        controller = GetComponent<CharacterController>();
    }


    void Update()
    {
        //Is the player moving?
        if (Input.GetAxis("Horizontal") != 0 || Input.GetAxis("Vertical") != 0)
        {
            //Is the player walking or running?
            if (Input.GetKey(KeyCode.LeftShift))
                playerState = PlayerState.RUNNING;
            else
                playerState = PlayerState.WALKING;
        }
        else
            playerState = PlayerState.IDLE;

        switch (playerState)
        {
            case PlayerState.IDLE:
                Movement(0.0f);
                break;

            case PlayerState.WALKING:
                Movement(walkSpeed);
                break;

            case PlayerState.RUNNING:
                Movement(runSpeed);
                break;
        }

        if (Input.GetButtonDown("Fire1") && hp > 0)
            throwingAnimation.Play("throwingAnimation");
    }


    /*
     * Description: Call this function to apply gravity to the player
     */
    void ApplyGravity()
    {
        moveDirection.y -= gravity * Time.deltaTime;
        
        //Make sure the player isn't falling faster than gravity should allow
        if (moveDirection.y < -70)
            moveDirection.y = -70;
    }


    /*
     * Description: Call this function keep track of player jumping
     */
    void Jumping()
    {
        //Check to see if the player can jump again
        if (isGrounded)
            isJumping = false;

        //Deal with jumping
        if (Input.GetButton("Jump") && !isJumping)
        {
            isJumping = true;
            moveDirection.y = jumpSpeed;
        }
    }


    /*
     * Description: Deals with letting the player throw snowballs
     */
    public void Throwing()
    {
        Rigidbody snowBall = Instantiate(globalScript.SnowBall.rigidbody, snowballSpawnLocation.position, Camera.main.transform.rotation) as Rigidbody;
        snowBall.AddForce(Camera.main.transform.forward * 1200.0f);
        globalScript.sfx[(int)Common.AudioSFX.SNOWBALL_THROW].Play();
        hp -= 1;
        print("Player HP: " + hp);
    }


    /*
     * Description: Deals with the movement of the player
     * Syntax: Movement(float);
     * Values:
     *       : speed = The max speed the player can move at
     */
    void Movement(float speed)
    {
        if (isGrounded)
        {
            moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));

            //If moving forward and to the side at the same time, compensate for distance 
            if (Input.GetMouseButton(1) && (Input.GetAxis("Horizontal") != 0) && (Input.GetAxis("Vertical") != 0))
                moveDirection *= 0.7f;

            moveDirection *= speed;
            moveDirection = transform.TransformDirection(moveDirection);
        }

        Jumping();
        ApplyGravity();

        //Move the player and check if the player is grounded
        isGrounded = ((controller.Move(moveDirection * Time.deltaTime)) & CollisionFlags.Below) != 0;
    }

    /*
     * Description: Keeps the player on the ground when walking down hills (Prevents bouncing)
     */
    void GroundPlayer()
    {
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