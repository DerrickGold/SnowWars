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
        JUMPING,
    };
    private PlayerState state;
    private float hp = 100.0f;
    private Vector3 moveDirection = Vector3.zero;

    //Game variables
    public GameObject snowball;

    void Start()
    {
        state = PlayerState.IDLE;
    }

    void Update()
    {
        moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0.0f, Input.GetAxis("Vertical"));
        

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