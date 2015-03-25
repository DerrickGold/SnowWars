﻿using UnityEngine;
using System.Collections;

public class ThrowSnowball : MonoBehaviour
{
    private PlayerController playerController;

    void Start()
    {
        playerController = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }

	void PlayerThrow()
    {
        playerController.Throwing();
	}

    void AIThrow()
    {

    }
}
