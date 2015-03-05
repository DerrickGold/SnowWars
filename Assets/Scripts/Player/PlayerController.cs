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
    };
    private PlayerState state;
    private bool isJumping = false;
    private float hp = 100.0f;
    private Vector3 moveDirection = Vector3.zero;

    //Game variables
    //public GameObject snowball;

    void Start()
    {
        state = PlayerState.IDLE;
        Common.player = gameObject;
        
    }

    void Update()
    {
        //Get the direction the player is moving
        moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0.0f, Input.GetAxis("Vertical"));
        
        switch (state)
        {
            case PlayerState.IDLE:
                break;
            case PlayerState.WALKING:
                break;
            case PlayerState.RUNNING:
                break;
        }
    }
}