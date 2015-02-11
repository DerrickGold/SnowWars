using UnityEngine;
using System.Collections;
using System.Collections.Generic;


namespace TerraVol
{

	/// <summary>
    /// Tool to debug path info of a chunk.</summary>
	public static class PathDebuger
	{
	
		private static Dictionary<ChunkData, List<GameObject>> cubes = new Dictionary<ChunkData, List<GameObject>>();
		
		public static void Clear(ChunkData chunk)
		{
			List<GameObject> ccubes;
			if (cubes.TryGetValue(chunk, out ccubes)) {
				foreach (GameObject cube in ccubes) {
					Object.Destroy(cube);
				}
				ccubes.Clear();
			}
		}
		
		public static void DebugPath(ChunkData chunk)
		{
			Clear(chunk);
			
			for (int x=0; x < Chunk.SIZE_X; x++) {
				for (int y=0; y < Chunk.SIZE_Y; y++) {
					for (int z=0; z < Chunk.SIZE_Z; z++) {
						
						BlockData block = chunk.GetBlock(x, y, z);
						
						if (block != null && block.IsPathBlocked) {
							// blockAbove is free and above the ground
							GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
							cube.transform.position = new Vector3((block.Position.x + chunk.Position.x) * Chunk.SIZE_X_BLOCK,
							                                      (block.Position.y + chunk.Position.y) * Chunk.SIZE_Y_BLOCK,
							                                      (block.Position.z + chunk.Position.z) * Chunk.SIZE_Z_BLOCK);
							cube.transform.localScale = new Vector3(1f, 2f, 1f);
							cube.collider.enabled = false;
							cube.renderer.material.color = (block.IsPathBlocked ? Color.red : Color.blue);
							cube.layer = 2;
							
							List<GameObject> ccubes;
							if (!cubes.TryGetValue(chunk, out ccubes)) {
								ccubes = new List<GameObject>();
								cubes.Add(chunk, ccubes);
							}
							ccubes.Add(cube);
						}
					}
				}
			}
		}
		
	}
}