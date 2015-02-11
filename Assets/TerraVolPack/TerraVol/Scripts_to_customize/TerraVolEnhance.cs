// Uncomment the following line to test the "2 biomes" scene
//#define TERRAVOL_2_BIOMES

using UnityEngine;
using TerraVol;
using System.Collections;

/// <summary>
/// This class allows you to customize terrain creation. You can do a lot here, without the need to modify TerraVol sources.</summary>
public class TerraVolEnhance : ITerraVolEnhance
{
	private TerraMap map;
	private Block sandBlock;

	private Block winterDefaultBlock;
	private Block winterTransitionBlock;
	private Block transitionBlock;

	
	/// <summary>
	/// Called during map initilization. Add here everything you need to initialize for later use.</summary>
	public TerraVolEnhance (TerraMap map)
	{
		this.map = map;

		#if TERRAVOL_2_BIOMES
		
		winterDefaultBlock = this.map.GetBlockSet().GetBlock ("WinterDefault");
		winterTransitionBlock = this.map.GetBlockSet().GetBlock ("WinterTransition");
		transitionBlock = this.map.GetBlockSet().GetBlock ("Transition");
		
		#else
		
		// Load "sand" block to be able to use it in OnBlockGenerateBeforeInThread method
		sandBlock = this.map.GetBlockSet().GetBlock ("Sand");
		
		#endif
	}
	
	/// <summary>
	/// Called during terrain generation. Use it to choose the type of blocks depending on their position.</summary>
	/// <remarks>
	/// IMPORTANT: this method may be called from different threads. Everything you do in this method MUST BE THREAD-SAFE.</remarks>
	public Block OnBlockGenerateBeforeInThread (Vector3i position)
	{
		#if TERRAVOL_2_BIOMES
		
		if (position.x > 10) {
			return winterDefaultBlock; // WinterDefault block will be used
		
		} else if (position.x > 8) {
			return winterTransitionBlock; // Transition block will be used
			
		} else if (position.x > 6) {
			return transitionBlock; // Transition block will be used
		
		}
		return null; // Default block will be used
		
		#else
		
		if (sandBlock != null && position.y < -2)
			return sandBlock;
		return null;
		
		#endif
	}
	
	/// <summary>
	/// Called right before chunk has been built.</summary>
	/// <remarks>
	/// This method is called on the main thread.</remarks>
	public void OnChunkBuildBefore (Chunk chunk)
	{
	
	}
	
	/// <summary>
	/// Called right after chunk has been built.</summary>
	/// <remarks>
	/// This method is called on the main thread.</remarks>
	public void OnChunkBuildAfter (Chunk chunk)
	{		
		
	}
	
	/// <summary>
	/// Called after chunk build to create vegetation (except grass). You can customize this method to change the way vegetation is created.</summary>
	/// <remarks>
	/// This method is called on the main thread.</remarks>
	public void CreateVegetation (Chunk chunk)
	{
		// Get chunk data from chunk
		ChunkData chunkData = chunk.ChunkData;

		#if TERRAVOL_2_BIOMES
		// Don't put trees on winter biome
		if (chunkData.Position.x > 0)
			return;
		#endif
		
		// Get trees array from TerraMap component
		GameObject[] trees = chunkData.TerraMap.trees;
		float[] treesDeepInTheGround = chunkData.TerraMap.treesDeepInTheGround;
		
		// Check if trees array is empty
		if (trees.Length == 0)
			return;
		
		// Chunk position in Chunks coordinates
		Vector3i cpos = chunkData.Position;
		
		// Density of vegetation
		float density = chunkData.TerraMap.treesDensity;
		
		// Compute position offset from Perlin noise
		float offset = -4f * Mathf.PerlinNoise (cpos.x, cpos.z);
		
		// Loop over X & Z to place some trees
		for (float x = offset; x < Chunk.SIZE_X_TOTAL; x += 1/density) {
			for (float z = offset; z < Chunk.SIZE_Z_TOTAL; z += 1/density) {
				
				// Get current world position
				Vector3 wpos = Chunk.ToWorldPosition (cpos, new Vector3 (x, 0, z));
				
				// Compute Perlin noise at this position
				float perlin = Mathf.PerlinNoise (wpos.x, wpos.z);
				
				// If noise if lower than 0.2, perform raycast
				if (perlin < 0.2f) {
					Ray ray = new Ray (wpos + new Vector3 (offset * (perlin - 0.5f), Chunk.SIZE_Y_TOTAL, perlin * (offset - 2f)), Vector3.down);
					RaycastHit hit = new RaycastHit ();
					RaycastHit hit2 = new RaycastHit ();
					
					// Perform raycast to check if we can place a tree at this position
					if (Physics.Raycast (ray.origin, ray.direction, out hit, Chunk.SIZE_Y_TOTAL) && hit.transform.GetComponent<Chunk>() != null) {
						
						// You may want to change this condition
						if (hit.normal.normalized.y > 0.8f && 
							hit.point.y > TerrainGenerator.WATER_LEVEL * Chunk.SIZE_Y_BLOCK) {
							
							// Get tree from trees array
							int index = getIndexFromPerlin (perlin, 0.2f, chunkData.TerraMap.trees.Length);
							GameObject treePrefab = chunkData.TerraMap.trees [index];
							
							// Check if there is enough place to position tree
							if (!Physics.Raycast (hit.point + Vector3.up, Vector3.up, out hit2, treePrefab.renderer.bounds.size.y * 2.2f)) {
								Vector3 pos = hit.point;
								pos.y -= treesDeepInTheGround[index];
								// Finally, add a tree
								GameObject tree = Chunk.Instantiate (treePrefab, pos, Quaternion.identity) as GameObject;
								tree.transform.parent = chunk.transform;
								tree.renderer.enabled = true;
							}
						}
					}
					
				}
			}
		}
	}
	
	// Returns the index of the tree we are going to add
	private int getIndexFromPerlin (float perlin, float maxValue, int maxIndex)
	{
		return Mathf.Clamp ((int)(maxIndex * perlin / maxValue), 0, maxIndex);
	}
	
}
