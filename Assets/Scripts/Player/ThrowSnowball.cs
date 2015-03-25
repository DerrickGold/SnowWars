using UnityEngine;
using System.Collections;

public class ThrowSnowball : MonoBehaviour
{
    private PlayerController playerController;
    private AIController aiController;

    void Start()
    {
        if (gameObject.transform.root.name == "Player")
            playerController = gameObject.transform.root.GetComponent<PlayerController>();
        else if (gameObject.transform.root.name == "AI")
            aiController = gameObject.transform.root.GetComponent<AIController>();
    }

	void PlayerThrow()
    {
        playerController.Throwing();
	}

    void AIThrow()
    {
        aiController.Throwing();
    }
}
