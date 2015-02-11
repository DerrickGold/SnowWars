using UnityEngine;
using System.Collections;

public class PlayerSpawn : MonoBehaviour {
	
	public bool fixSpawnHeight = true;
	public float spawnHeight = 200f;
	public float playerHeight = 5f;
	public float underWorld = -100f;
	
	void Update()
	{
		if (transform.position.y < underWorld)
		{
			// Player fell under the world
			Vector3 target = transform.position;
			target.y = spawnHeight;
			transform.position = target;

			Debug.Log( "Player fell through the world - Moving to: X=" + transform.position.x + ", Y=" + transform.position.y + ", Z=" + transform.position.z);
					
			fixSpawnHeight = true;
		}
		
		if (fixSpawnHeight) {
			// When spawning a character on a randomly generated terrain, position them near the ground
			Ray ray = new Ray(transform.position, Vector3.down);
			RaycastHit hit;
			if (Physics.Raycast (ray, out hit, 300f)) {
				if (hit.distance > 10) {
					Vector3 target = transform.position;
					target.y = hit.point.y + playerHeight;
					transform.position = target;

					Debug.Log( "Set player position near the ground." );
					
					fixSpawnHeight = false;
				}
			}
		}
	}
	
}
