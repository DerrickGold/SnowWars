using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    //Player variables
    private enum PlayerState
    {
        IDLE,
        WALKING,
        RUNNING,
        JUMPING
    };
    private PlayerState state;
    private Vector3 moveDirection = Vector3.zero;
    private bool isJumping = false;
    private bool isGrounded = false;
    private float hp = 100.0f;

    //Game variables
    //public GameObject snowball;

    void Start()
    {
        state = PlayerState.IDLE;
        Common.player = gameObject;
        
    }

    void Update()
    {
        //Is player grounded?
        if (isGrounded)
        {
            //Get the direction the player is moving
            moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0.0f, Input.GetAxis("Vertical"));
            moveDirection.x -= Input.GetAxis("Strafing");

            switch (state)
            {
                case PlayerState.IDLE:
                    break;
                case PlayerState.WALKING:
                    
                    break;
                case PlayerState.RUNNING:
                    break;
                case PlayerState.JUMPING:
                    break;
            }
        }
    }
}