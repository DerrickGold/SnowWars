/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray
 * 
 * Description: Anything that is common between the player and the AI is put into this script. Both
 *              the player and the AI inherit this script. Things such as hitpoints, buffs, ammo,
 *              body parts, stamina, etc are all placed in this script.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class CharacterBase: MonoBehaviour {
	public enum BuffFlag {
		MAX_HEALTH_BOOST = 1<<1, 
		INF_AMMO = 1<<2,
		SPEED_BOOST = 1<<3,
		SUPER_SNOWBALL = 1<<4,
		INF_STAMINA = 1<<5,
		INF_HEALTH = 1<<6
	};
	public static int BuffCount = 10;

	public float Health = Common.BaseMaxHealth;
	public float Stamina = Common.BaseMaxStamina;
    public Vector3 lastRegenLocation;

	public int ActiveBuffs;
	public float[] BuffTimers = new float[BuffCount];

	public GameObject Base, Thorax, Head;
	public GameObject SnowBallTemplate;
	public GameObject deathExplosionEffect;
    public Vector3 spawnPosition;

	public Vector3[] oldPartPositions = new Vector3[3];


    /****************************************************************************************************
     * Description: Used to initialize the core of the player and AI. Gets the snowball prefab that is  *
     *              used as well as keeps track of initial spawn locations.                             *
     * Syntax: baseInitialization();                                                                    *
     ****************************************************************************************************/
    public void baseInitialization()
    {
		SnowBallTemplate = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common>().SnowBall;

		foreach (Transform o in GetComponentsInChildren<Transform> ()){
			if (o.name == "Head") Head = o.gameObject;
			else if (o.name == "Thorax") Thorax = o.gameObject;
			else if (o.name == "Base") Base = o.gameObject;
		}

		oldPartPositions [0] = Base.transform.localPosition;
		oldPartPositions [1] = Thorax.transform.localPosition;
		oldPartPositions [2] = Head.transform.localPosition;
	}


    /****************************************************************************************************
     * Description: This is a helper function. Used to toggle individual sphere colliders off of        *
     *              specific gameobjects.                                                               *
     * Syntax: toggleCollider(GameObject part, bool flag);                                              *
     * Values:                                                                                          *
     *          part = The gameobject that needs to have the sphere collider enabled or removed         *
     *          flag = Specifies whether to enable or remove the sphere collider                        *
     ****************************************************************************************************/
	public void toggleCollider(GameObject part, bool flag) {
		SphereCollider temp = part.GetComponent<SphereCollider> ();
		temp.enabled = flag;
	}


    /****************************************************************************************************
     * Description: This is a helper function. Called when the player or AI needs to respawn. This      *
     *              reassembles their body parts back to the starting spawn position.                   *
     * Syntax: rebuild();                                                                               *
     ****************************************************************************************************/
	public void rebuild() {
		Destroy (Base.rigidbody);
		Destroy (Thorax.rigidbody);
		Destroy (Head.rigidbody);

		//toggleCollider (Base, false);
		//toggleCollider (Thorax, false);
		//toggleCollider (Head, false);
		
		Base.transform.localPosition = oldPartPositions [0];
        Base.transform.eulerAngles = new Vector3(0, 0, 0);
        Thorax.transform.localPosition = oldPartPositions[1];
        Thorax.transform.eulerAngles = new Vector3(0, 0, 0);
        Head.transform.localPosition = oldPartPositions[2];
        Head.transform.eulerAngles = new Vector3(0, 0, 0);

	}


    /****************************************************************************************************
     * Description: Used to apply physics to the characters body to simulate a ragdoll.                 *
     * Syntax: dieAnimation();                                                                          *
     ****************************************************************************************************/
	public void dieAnimation() {
		Instantiate(deathExplosionEffect, transform.position, transform.rotation);
		//Add physics to the players body
        if (Base.GetComponent<Rigidbody>() == null)
        {
            Rigidbody bottomRigidbody = Base.AddComponent<Rigidbody>();
            bottomRigidbody.drag = 2;
        }
        if (Thorax.GetComponent<Rigidbody>() == null)
        {
            Rigidbody middleRigidbody = Thorax.AddComponent<Rigidbody>();
            middleRigidbody.drag = 2;
        }
        if (Head.GetComponent<Rigidbody>() == null)
        {
            Rigidbody topRigidbody = Head.AddComponent<Rigidbody>();
            topRigidbody.drag = 2;
        }
	}


    /****************************************************************************************************
     * Description: Set an effect to activate on a character.                                           *
     * Syntax: activateBuff(BuffFlag effect);                                                           *
     * Values:                                                                                          *
     *          effect = The effect that needs to be activated on the character                         *
     ****************************************************************************************************/
	public void activateBuff(BuffFlag effect) {
		ActiveBuffs |= (int)effect;
		//re-activate timer
	}


    /****************************************************************************************************
     * Description: Clear an effect on a player.                                                        *
     * Syntax: cleafBuff(BuffFlag effect);                                                              *
     * Values:                                                                                          *
     *          effect = The effect that needs to be cleared off of the character                       *
     ****************************************************************************************************/
	public void clearBuff(BuffFlag effect) {
		ActiveBuffs &= (int)~effect;
		//remove timer
	}


    /****************************************************************************************************
     * Description: Returns true or false if an effect if active.                                       *
     * Syntax: bool value = isEffectActive(BuffFlag effect);                                            *
     * Values:                                                                                          *
     *          effect = The effect that needs to be checked for                                        *
     * Returns: True if effect is active | False if effect is inactive                                  *
     ****************************************************************************************************/
	public bool isEffectActive(BuffFlag effect) {
		return (ActiveBuffs & (int)effect) > 0;
	}


    /****************************************************************************************************
     * Description: Set a time for a given effect.                                                      *
     * Syntax: setBuffTimer(BuffFlag effect, float time);                                               *
     * Values:                                                                                          *
     *          effect = The effect requires a set time                                                 *
     *          time = How long the effect should last for                                              *
     ****************************************************************************************************/
	public void setBuffTimer(BuffFlag effect, float time) {
		BuffTimers[(int)effect % BuffCount] = time;
	}


    /****************************************************************************************************
     * Description: Update all effect times for a player or AI.                                         *
     * Syntax: updateBuffTimers();                                                                      *
     ****************************************************************************************************/
	public void updateBuffTimers() {
		for (int i = 0; i < BuffCount; i++) { 
			BuffFlag curEffect = (BuffFlag)(1<<(i + 1));
			if (!isEffectActive (curEffect)) continue;

			int timer = (int)curEffect % BuffCount;
			BuffTimers[timer] -= Time.deltaTime;

			if (BuffTimers[timer] <= 0.0f) {
				clearBuff (curEffect);
				BuffTimers[timer] = 0.0f;
			}
		}
	
	}


    /****************************************************************************************************
     * Description: Reset all buff timers.                                                              *
     * Syntax: resetBuffs();                                                                            *
     ****************************************************************************************************/
	public void resetBuffs() {
		ActiveBuffs = 0;
		for(int i = 0; i < BuffCount; i++) {
			BuffTimers[i] = 0;
		}
	}


    /****************************************************************************************************
     * Description: Get the characters max health.                                                      *
     * Syntax: float value = getMaxHealth();                                                            *
     * Returns: float representing the characters max health                                            *
     ****************************************************************************************************/
	public float getMaxHealth() {
		if (isEffectActive (BuffFlag.MAX_HEALTH_BOOST)) 
			return Common.BaseMaxHealth + Common.MaxHealthBoost;
		return Common.BaseMaxHealth;
	}


    /****************************************************************************************************
     * Description: Get the characters current health.                                                  *
     * Syntax: float value = getHealth();                                                               *
     * Returns: float representing the characters current health                                        *
     ****************************************************************************************************/
	public float getHealth() {
		if(isEffectActive (BuffFlag.INF_HEALTH))
			return getMaxHealth();
		return Health;
	}


    /****************************************************************************************************
     * Description: Get the characters max stamina.                                                     *
     * Syntax: float value = getMaxStamina();                                                           *
     * Returns: float representing the characters max stamina                                           *
     ****************************************************************************************************/
	public int getMaxStamina() {
		return Common.BaseMaxStamina;
	}


    /****************************************************************************************************
     * Description: Get the characters current stamina.                                                 *
     * Syntax: float value = getStamina();                                                              *
     * Returns: float representing the characters current stamina                                       *
     ****************************************************************************************************/
	public float getStamina() {
		if (isEffectActive (BuffFlag.INF_STAMINA))
			return Common.BaseMaxStamina;
		return Stamina;
	}


    /****************************************************************************************************
     * Description: Processess a throw from the character. Subtracts the characters health if required. *
     * Syntax: subtractAmmo();                                                                          *
     ****************************************************************************************************/
	public void subtractAmmo() {
		//Infinite ammo, doesn't subtract from health
		if (isEffectActive(BuffFlag.INF_AMMO) || isEffectActive(BuffFlag.INF_HEALTH)) return;

		//Subtract one hit point for every throw
		if (isEffectActive(BuffFlag.SUPER_SNOWBALL))
			Health -= (Common.AmmoSubtractAmmount + Common.SuperSnowSubtract);
		else
			Health -= Common.AmmoSubtractAmmount;         
	}


    /****************************************************************************************************
     * Description: Get the speed of the boosted character if possible.                                 *
     * Syntax: float value = getSpeedBoost();                                                           *
     * Returns: float representing the new speed to use for the character                               *
     ****************************************************************************************************/
	public float getSpeedBoost() {
		if (isEffectActive(BuffFlag.SPEED_BOOST)) return Common.SpeedBoost;
		return 0.0f;
	}


    /****************************************************************************************************
     * Description: Gets the damage of the snowball that the character can throw.                       *
     * Syntax: int value = getSnowBallDamage();                                                         *
     * Returns: int representing the damage output of the characters snowball                           *
     ****************************************************************************************************/
	public int getSnowBallDamage() {
		if (isEffectActive(BuffFlag.SUPER_SNOWBALL)) {
			return Common.BaseSnowBallDamage + Common.SuperSnowBallBoost;
		}
		return Common.BaseSnowBallDamage;
	}






}
