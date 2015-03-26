using UnityEngine;
using System.Collections;

public class ThrowSnowball : MonoBehaviour
{
    private PlayerController playerController;
    private AIController aiController;

    /****************************************************************************************************
     * Description: This is called in the players's throwing animation to help sync the arm swing with  *
     *              the throwing of a snowball.                                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void PlayerThrow()
    {
        if (playerController == null)
            playerController = gameObject.transform.root.GetComponent<PlayerController>();
        playerController.throwing();
	}

    /****************************************************************************************************
     * Description: This is called in the AI's throwing animation to help sync the arm swing with       *
     *              the throwing of a snowball.                                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void AIThrow()
    {
        if (aiController == null)
            aiController = gameObject.transform.root.GetComponent<AIController>();
        aiController.throwing();
    }
}
