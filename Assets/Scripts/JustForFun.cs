using UnityEngine;
using System.Collections;

public class JustForFun : MonoBehaviour
{
    public GameObject ai;

    void Start()
    {
        for (float amount = 100f, radius = 50f; amount > 0; amount--)
        {
            float randomX = Random.Range(transform.position.x - radius, transform.position.x + radius);
            float randomZ = Random.Range(transform.position.z - radius, transform.position.z + radius);
            Instantiate(ai, new Vector3(randomX, Terrain.activeTerrain.SampleHeight(new Vector3(randomX, 0 , randomZ)), randomZ), transform.rotation);
        }
    }
}
