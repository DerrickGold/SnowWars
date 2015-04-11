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
    private AudioSource audio;
    public Transform origin;
    public float originHP;
	public bool isSuper = false;

    private float speed = 60.0f;
    public float damage = CharacterBase.BASE_SNOWBALL_DAMAGE;
	bool collided = false;
	float scale = 1.0f;
	float maxScale = 5.0f;
	float minScale = 1.0f;
	int maxCluster = 20;
	int minClusterForce = 10;
	int maxClusterForce = 20;

    /****************************************************************************************************
     * Description: Used to initialize required variables.                                              *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start() {
		audio = GetComponent<AudioSource>();
		SnowBallTemplate = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common>().SnowBall;
	}


    /****************************************************************************************************
     * Description: Keeps track of projectile trajectory. Deletes projectile when required.             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update() {
        //Destroy the gameobject if it hit the ground and the hit sound is finished playing
        if (collided && !audio.isPlaying) {
			Destroy (gameObject);

			if(isSuper) {
				for(int i = 0; i < maxCluster; i++) {

					Vector3 tempPosition = transform.position;

				
					tempPosition.x += Random.Range(-maxCluster>>1, maxCluster>>1);
					tempPosition.z += Random.Range(-maxCluster>>1, maxCluster>>1);
					Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody,
					                                               tempPosition, Quaternion.identity) as Rigidbody;

					Vector3 test = new Vector3(Random.Range (-90, 90), Vector3.up.y, Random.Range (-90, 90));

					instantiatedProjectile.transform.Rotate(test);
					Projectile snowBallScript = instantiatedProjectile.GetComponent<Projectile>();
					snowBallScript.damage = 50;
			
					float Velocity = Random.Range (minClusterForce, maxClusterForce);
					instantiatedProjectile.AddForce (instantiatedProjectile.transform.up * Velocity, ForceMode.Impulse);
				}

			}

			//Disable the sphere collider and mesh renderer upon collision
		} else if (collided)
			GetComponent<MeshRenderer> ().enabled = false;
		else {
			if (isSuper) {
				if(scale < maxScale) scale += (Time.deltaTime/maxScale);
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
        //Do not collide with walls
        if (collision.gameObject.layer != 9)
        {
            audio.Play();
            collided = true;

            Destroy(rigidbody);
            Destroy(collider);
        }
	}
}
