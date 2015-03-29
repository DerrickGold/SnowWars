/****************************************************************************************************
 * Primary Contributor: Curtis Murray
 * 
 * Description: This script is for testing purposes ONLY. This creates a certain amount of enemy AI
 *              around the player randomly. Used mostly to quickly create awesome war zones with
 *              hundreds of enemy AI without having to individually place them.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class JustForFun : MonoBehaviour
{
    public GameObject ai;


    /****************************************************************************************************
     * Description: Only called once. Spawns 'amount' of AI in 'radius' of the player.                  *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start()
    {
        for (float amount = 1f, radius = 10f; amount > 0; amount--)
        {
            float randomX = Random.Range(transform.position.x - radius, transform.position.x + radius);
            float randomZ = Random.Range(transform.position.z - radius, transform.position.z + radius);
            Instantiate(ai, new Vector3(randomX, Terrain.activeTerrain.SampleHeight(new Vector3(randomX, 0 , randomZ)), randomZ), transform.rotation);
        }
    }
}
