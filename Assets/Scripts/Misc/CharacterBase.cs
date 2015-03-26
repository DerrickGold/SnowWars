/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray
 * 
 * Description: Anything that is common between the player and the AI is put into here. Both the
 *              player and the AI inherit this script. Things such as hitpoints, buffs, ammo, body
 *              parts, stamina, etc are all placed in this script.
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
	public HitBox HitCollider;
	public GameObject deathExplosionEffect;
    public Vector3 spawnPosition;

	public Vector3[] oldPartPositions = new Vector3[3];


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

	public void toggleCollider(GameObject part, bool flag) {
		SphereCollider temp = part.GetComponent<SphereCollider> ();
		temp.enabled = flag;
	}

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


	public void dieAnimation() {
		Instantiate(deathExplosionEffect, transform.position, transform.rotation);
		//Add physics to the players body
		//Base.AddComponent<SphereCollider>();
		//toggleCollider (Base, true);
		Rigidbody bottomRigidbody = Base.AddComponent<Rigidbody>();
		bottomRigidbody.drag = 2;
		
		//toggleCollider (Thorax, true);
		Rigidbody middleRigidbody = Thorax.AddComponent<Rigidbody>();
		middleRigidbody.drag = 2;
		//bodyMiddle.transform.position += Vector3.up * 0.50f;
		//toggleCollider (Head, true);
		Rigidbody topRigidbody = Head.AddComponent<Rigidbody>();
		topRigidbody.drag = 2;
	}

	//Set an effect to activate on a character
	public void activateBuff(BuffFlag effect) {
		ActiveBuffs |= (int)effect;
		//re-activate timer
	}

	//clear an effect on a player
	public void clearBuff(BuffFlag effect) {
		ActiveBuffs &= (int)~effect;
		//remove timer
	}

	//returns true or false if an effect is active
	public bool isEffectActive(BuffFlag effect) {
		//what a hack to return a bool
		return (ActiveBuffs & (int)effect) > 0;
	}

	//set a time for a given effect
	public void setBuffTimer(BuffFlag effect, float time) {
		BuffTimers[(int)effect % BuffCount] = time;
	}

	//update all effect timers for a player/ai
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

	public void resetBuffs() {
		ActiveBuffs = 0;
		for(int i = 0; i < BuffCount; i++) {
			BuffTimers[i] = 0;
		}

	}


	//Get the players max health
	public float getMaxHealth() {
		if (isEffectActive (BuffFlag.MAX_HEALTH_BOOST)) 
			return Common.BaseMaxHealth + Common.MaxHealthBoost;

		return Common.BaseMaxHealth;
	}

	public float getHealth() {
		if(isEffectActive (BuffFlag.INF_HEALTH))
			return getMaxHealth();

		return Health;
	}
	
	public int getMaxStamina() {
		return Common.BaseMaxStamina;
	}

	public float getStamina() {
		if (isEffectActive (BuffFlag.INF_STAMINA))
			return Common.BaseMaxStamina;
		return Stamina;
	}

	//processess a throw from the player
	public void subtractAmmo() {
		//infinite ammo, doesn't subtract from health
		if (isEffectActive(BuffFlag.INF_AMMO) || isEffectActive(BuffFlag.INF_HEALTH)) return;
		//subtract one hit point for every throw
		if (isEffectActive(BuffFlag.SUPER_SNOWBALL)) {
			Health -= (Common.AmmoSubtractAmmount + Common.SuperSnowSubtract);
		} else {
			Health -= Common.AmmoSubtractAmmount;
		}	           
	}

	//check if player should get boosted speed
	public float getSpeedBoost() {
		if (isEffectActive(BuffFlag.SPEED_BOOST)) return Common.SpeedBoost;
		return 0.0f;
	}


	public int getSnowBallDamage() {
		if (isEffectActive(BuffFlag.SUPER_SNOWBALL)) {
			return Common.BaseSnowBallDamage + Common.SuperSnowBallBoost;
		}
		return Common.BaseSnowBallDamage;
	}






}
