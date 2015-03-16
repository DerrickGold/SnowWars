using UnityEngine;
using System.Collections;

/*
 * The base of all players and AI 
 * 
 * Handles hitpoints, buffs, ammo, etc
 * 
 * 
 * Created by Derrick!
 */


public class CharacterBase {
	public enum BuffFlag {
		MAX_HEALTH_BOOST = 1<<1, 
		INF_AMMO = 1<<2,
		SPEED_BOOST = 1<<3,
		SUPER_SNOWBALL = 1<<4
	};
	public static int BuffCount = 10;



	public int Health = Common.BaseMaxHealth;
	public int ActiveBuffs;
	public float[] BuffTimers = new float[BuffCount];


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
			BuffFlag curEffect = (BuffFlag)(1<<i);

			if (!isEffectActive (curEffect)) continue;
			BuffTimers[i] -= Time.deltaTime;
			clearBuff (curEffect);
		}
	
	}



	//Get the players max health
	public int getMaxHealth() {
		if (isEffectActive (BuffFlag.MAX_HEALTH_BOOST)) 
			return Common.BaseMaxHealth + Common.MaxHealthBoost;

		return Common.BaseMaxHealth;
	}
	
	//processess a throw from the player
	public void subtractAmmo() {
		//infinite ammo, doesn't subtract from health
		if (isEffectActive(BuffFlag.INF_AMMO)) return;
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
