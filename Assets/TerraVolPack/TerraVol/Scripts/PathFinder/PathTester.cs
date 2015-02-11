using UnityEngine;
using TerraVol;
using System.Collections;
using System.Collections.Generic;


/// <summary>
/// A simple behaviour to test path finding. Press 'I' to set start point, move where you want, and then press 'I' again to
/// find path between the start point and your position.
/// </summary>
[AddComponentMenu("TerraVol/Path tester")]
public class PathTester : MonoBehaviour {
	
	public Camera mCamera;
	public TerraMap map;
	public bool aboveGroundOnly = true;
	private bool act = true;
	
	private Vector3i start = Vector3i.zero;
	private List<GameObject> cubes = new List<GameObject>();
	
	
	public void Update()
	{
		if (Input.GetKeyDown (KeyCode.I)) {
			if (act) {
				Test();
				act = false;
			}
		}
		if (Input.GetKeyUp (KeyCode.I)) {
			act = true;
		}
		
	}
	
	
	public void Test()
	{
		Vector3i end = Chunk.ToTerraVolPosition (mCamera.transform.position);
		if (aboveGroundOnly) {
			while (end.y > 0) {
				end.y--;
				ChunkData chunk = map.GetChunkData( Chunk.ToChunkPosition(end) );
				Vector3i localPosition = Chunk.ToLocalPosition( end );
				if (chunk != null && chunk.GetBlock(localPosition).IsInside) {
					end.y++;
					break;
				}
			}
		}
		
		Debug.Log("Find path from "+start+" to "+end+" (in Block units)");
		SearchNode path = PathFinder.FindPath(map, start, end, aboveGroundOnly, false);
		
		// Set "start" to "end" for next time
		start = end;
		
		if (path == null) {
			Debug.Log("PATH NOT FOUND");
			return;
		}
		Debug.Log("PATH FOUND");
		
		SearchNode current = path;
		while (current != null)
		{
			GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
			cube.transform.position = new Vector3(current.position.x * Chunk.SIZE_X_BLOCK, current.position.y * Chunk.SIZE_Y_BLOCK, current.position.z * Chunk.SIZE_Z_BLOCK);
			cube.transform.localScale = new Vector3(1.1f, 1f, 1.1f);
			cube.collider.enabled = false;
			cube.renderer.material.color = Color.yellow;
			cube.layer = 2;
			cubes.Add(cube);
			Debug.Log(current);
			current = current.next;
		}
	}
	
	
	public void Clear()
	{
		foreach (GameObject cube in cubes)
		{
			Destroy( cube );
		}
		cubes.Clear();
	}
	
}