using UnityEngine;
using System.Collections;

public class ThrowSnowball : MonoBehaviour
{
    private PlayerController playerController;
    private AIController aiController;

	void PlayerThrow()
    {
        if (playerController == null)
            playerController = gameObject.transform.root.GetComponent<PlayerController>();
        playerController.Throwing();
	}

    void AIThrow()
    {
        if (aiController == null)
            aiController = gameObject.transform.root.GetComponent<AIController>();
        aiController.Throwing();
    }
}
