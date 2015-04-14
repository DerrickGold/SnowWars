/****************************************************************************************************
 * Primary Contributor: Curtis Murray
 * Secondary Contributors: Derrick Gold
 * 
 * Description: Gives life to the trebuchets on the team deathmatch map. It controls how the
 *              trebuchets work, and fires them as environmental snowballs. I.E. no team is awarded
 *              a kill upon death.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Trebuchet : MonoBehaviour
{
    public GameObject crazySnowball;
    private Vector3 startingRotation;
    private bool onCooldown = false;


    /****************************************************************************************************
     * Description: Used only to grab the starting rotation of the trebuchet.                           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start()
    {
        startingRotation = transform.eulerAngles;
    }


    /****************************************************************************************************
     * Description: Keeps firing the trebuchet when possible.                                           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        if (!onCooldown)
            StartCoroutine("FireZeMissiles");
    }


    /****************************************************************************************************
     * Description: Deals with rotating and firing the trebuchet in random directions with random force *
     *              speeds.                                                                             *
     * Syntax: StartCoroutine("FireZeMissiles");                                                                  *
     ****************************************************************************************************/
    IEnumerator FireZeMissiles()
    {
        onCooldown = true;

        //Wait to fire
        int waitTime = Random.Range(1, 3);
        yield return new WaitForSeconds(waitTime);

        //Give it a random rotation
        transform.eulerAngles = new Vector3(startingRotation.x + Random.Range(-60, -65), startingRotation.y + Random.Range(-20, 20), startingRotation.z);

        //Make it rain =3
        Rigidbody projectile = Instantiate(crazySnowball.rigidbody, transform.position, transform.rotation) as Rigidbody;
        Projectile snowBallScript = projectile.GetComponent<Projectile>();
        snowBallScript.damage = 1000;
        snowBallScript.isSuper = true;
        projectile.AddForce(transform.forward * Random.Range(55, 65), ForceMode.Impulse);

        onCooldown = false;
    }
}