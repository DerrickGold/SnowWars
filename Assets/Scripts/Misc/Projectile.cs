/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray
 * 
 * Description: This script is the driving force of the snowball. Lets the snowball keep track of
 *              important information such as the damage output it does, the owner of the snowball,
 *              the sound associated with the snowball, etc.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Projectile : MonoBehaviour
{
	public GameObject SnowBallTemplate;
    private AudioSource audio1;
    public Transform origin = null;
	public bool isSuper = false;
    private bool oneShot = false;

    public float damage = CharacterBase.BASE_SNOWBALL_DAMAGE;
	bool collided = false;
	float scale = 1.0f;
	float maxScale = 5.0f;
	float minScale = 1.0f;
	int maxCluster = 25;


    /****************************************************************************************************
     * Description: Used to initialize required variables.                                              *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start()
    {
		audio1 = GetComponent<AudioSource>();
		SnowBallTemplate = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common>().SnowBall;
	}


    /****************************************************************************************************
     * Description: Keeps track of projectile trajectory. Deletes projectile when required.             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update()
    {
        //Destroy the gameobject if it hit the ground and the hit sound is finished playing
        if (collided && !audio1.isPlaying)
			Destroy (gameObject);
        else if (collided)
        {
            //Disable the sphere collider and mesh renderer upon collision
            GetComponent<MeshRenderer>().enabled = false;

            //If the snowball was a super snowball
            if (isSuper && !oneShot)
            {
                oneShot = true;

                //For every junior super snowball
                for (int i = 0; i < maxCluster; i++)
                {
                    //Spawn a new junior super snowball
                    Vector3 randomOffset = new Vector3(transform.position.x + Random.Range(-1.0f, 1.0f), transform.position.y, transform.position.z + Random.Range(-1.0f, 1.0f));
                    Rigidbody tempProjectile = Instantiate(SnowBallTemplate.rigidbody, randomOffset, Quaternion.identity) as Rigidbody;

                    //Give each junior snowball extra damage and an owner
                    Projectile tempScript = tempProjectile.GetComponent<Projectile>();
                    tempScript.damage = 50;
                    tempScript.origin = origin;

                    tempProjectile.AddForce(new Vector3(Random.Range(-5, 5), 14, Random.Range(-5, 5)), ForceMode.Impulse);
                }
            }
        }
        //Increase the size of the super snowball
        else
        {
            if (isSuper)
            {
                if (scale < maxScale)
                    scale += (Time.deltaTime / maxScale);
                transform.localScale = new Vector3(minScale * scale, minScale * scale, minScale * scale);
            }
        }
	}


    /****************************************************************************************************
     * Description: Called when the projectile collides with something.                                 *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnCollisionEnter(Collision collision)
    {
        audio1.Play();
        collided = true;

        Destroy(rigidbody);
        Destroy(collider);
	}
}