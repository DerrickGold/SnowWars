// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using TerraVol;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System;


/// <summary>
/// TerraMapGenerator component. This is the core component of terrain dynamic generation.</summary>
/// <remarks>
/// Requires TerraMap component.</remarks>
[AddComponentMenu("TerraVol/Map Generator")]
[RequireComponent (typeof (TerraMap))]
public class TerraMapGenerator : MonoBehaviour
{
	[SerializeField]
	public Camera playerCamera;
	
	// Customize terrain generation
	[HideInInspector]
	public bool randomize = true;
	[SerializeField]
	public float HeightCoefOfCliffs = 40f;
	[SerializeField]
	public float HeightCoefOfHills = 70f;
	[SerializeField]
	public float MaxHeightOfCliffsAboveHills = 80f;
	[SerializeField]
	public float MaxHeightOfHills = 220f;
	[SerializeField]
	public float MinHeightOfGround = 0f;
	[SerializeField]
	[HideInInspector]
	public float roughness = 0f;
	[SerializeField]
	[HideInInspector]
	public float granularity = 30f;
	
	// Misc
	private TerraMap map;
	private TerrainGenerator terrainGenerator;
	private ThreadManager threadManager;
	private Vector3i oldPos;
	private Chunk2D lastChunk2D = null;
	private Vector2i lastChunk2DPos;
	private bool genDone = false;
	private bool buildDone = false;
	private bool grassDone = false;
	
	/// <summary>Get TerrainGenerator instance.</summary>
	internal TerrainGenerator TerrainGenerator {
		get {
			return terrainGenerator;
		}
		set {
			terrainGenerator = value;
		}
	}
		
	public void Awake ()
	{
		map = GetComponent<TerraMap> ();
		if (map == null) {
			enabled = false;
			Debug.LogError ("[TerraVol] TerraMapGenerator needs a TerraMap component");
			return;
		}
		roughness = Mathf.Clamp (roughness, 0f, 100f);
		lastChunk2D = null;
		lastChunk2DPos = Vector2i.zero;
	}
		
	public void Start ()
	{
		System.DateTime start = System.DateTime.Now;
			
		// Checks
		if (map == null || map.TerraMap2D == null) {
			enabled = false;
			throw new UnityException ("TerraMap has not been initialized properly");
		}

		// pools
		BlockPool.Init(map.defaultBlock);
		ChunkPool.Init(map);
		
		// Get thread manager instance
		threadManager = ThreadManager.GetInstance(map);
		
		// Handle map generation at start
		if (!Application.isEditor || Application.isPlaying) {
			// Generate terrain around player
			Vector3 pos = playerCamera.transform.position;
			int posX = Mathf.RoundToInt (pos.x / Chunk.SIZE_X_BLOCK);
			int posY = Mathf.RoundToInt (pos.y / Chunk.SIZE_Y_BLOCK);
			int posZ = Mathf.RoundToInt (pos.z / Chunk.SIZE_Z_BLOCK);
			Vector3i s = Chunk.ToChunkPosition (posX, posY, posZ);
			
			// If we are not in Unity's editor, we generate the terrain on the main thread and build it on multiple threads
			Debug.Log ("[TerraVol] Generating map...");
			for (int cx = s.x-map.sizeXAtStart/2-1; cx < s.x+map.sizeXAtStart/2+1; cx++) {
				for (int cz = s.z-map.sizeZAtStart/2-1; cz < s.z+map.sizeZAtStart/2+1; cz++) {
					if (map.limitSize && (cx < map.minGX || cx > map.maxGX || cz < map.minGZ || cz > map.maxGZ))
						continue;
					GenerateColumn (cx, cz);
				}
			}
			Debug.Log ("[TerraVol] TerraMap generated.");
			Debug.Log ("[TerraVol] Initilizing build...");
			for (int cx = s.x-map.sizeXAtStart/2; cx < s.x+map.sizeXAtStart/2; cx++) {
				for (int cz = s.z-map.sizeZAtStart/2; cz < s.z+map.sizeZAtStart/2; cz++) {
					if (map.limitSize && (cx < map.minGX || cx > map.maxX || cz < map.minGZ || cz > map.maxZ))
						continue;
					BuildColumn (cx, cz);
					BuildGrassColumn (cx, cz);
				}
			}
			Debug.Log ("[TerraVol] Build initialized...");
			
		} else {
			Vector3i s = Vector3i.zero;
#if UNITY_EDITOR
			if (SceneView.lastActiveSceneView != null) {
				s = Chunk.ToChunkPosition(Chunk.ToTerraVolPosition(SceneView.lastActiveSceneView.pivot));
			}
#endif
			// If we are in Unity's editor, we generate and build the terrain on the main thread
			for (int cx = s.x-5; cx < s.x+5; cx++) {
				for (int cz = s.z-5; cz < s.z+5; cz++) {
					if (map.limitSize && (cx < map.minGX || cx > map.maxGX || cz < map.minGZ || cz > map.maxGZ))
						continue;
					GenerateColumn (cx, cz);
				}
			}
			for (int cx = s.x-4; cx < s.x+4; cx++) {
				for (int cz = s.z-4; cz < s.z+4; cz++) {
					if (map.limitSize && (cx < map.minGX || cx > map.maxX || cz < map.minGZ || cz > map.maxZ))
						continue;
					BuildColumn (cx, cz);
				}
			}
			
		}
			
		GC.Collect ();
		Debug.Log ("[TerraVol] Total generation time : " + (System.DateTime.Now - start));
	}
        
	public void Update ()
	{
		try
		{				
			if (map == null || !map.buildDynamically)
				return;
				
			Vector3 pos = playerCamera.transform.position;
			
			UpdateAround(pos, true);
		}
		catch (TerraEditorException e)
		{
			Debug.LogWarning("TerraVol Editor Tool tried to execute terrain generation while it was null: "+e.Message);
		}
	}
	
	/// <summary>
	/// Generate terrain. Internal use only, for in-editor tool.</summary>
	/// <param name="pos"> Terrain will be generated around this position.</param>
	public void GenerateForEditor(Vector3 pos)
	{
		try
		{
			int posX = Mathf.RoundToInt (pos.x / Chunk.SIZE_X_BLOCK);
			int posY = Mathf.RoundToInt (pos.y / Chunk.SIZE_Y_BLOCK);
			int posZ = Mathf.RoundToInt (pos.z / Chunk.SIZE_Z_BLOCK);
			Vector3i current = Chunk.ToChunkPosition (posX, posY, posZ);
			
			// If we are in Unity's editor, we generate and build the terrain in the main thread
			for (int cx = -map.buildDistance-1; cx < map.buildDistance+1; cx++) {
				for (int cz = -map.buildDistance-1; cz < map.buildDistance+1; cz++) {
					// Map size limit
					int x = cx + current.x;
					int z = cz + current.z;
					if (map.limitSize && (x < map.minGX || x > map.maxGX || z < map.minGZ || z > map.maxGZ))
						continue;
					
					GenerateColumn (x, z);
				}
			}
			for (int cx = -map.buildDistance; cx < map.buildDistance; cx++) {
				for (int cz = -map.buildDistance; cz < map.buildDistance; cz++) {
					// Map size limit
					int x = cx + current.x;
					int z = cz + current.z;
					if (map.limitSize && (x < map.minGX || x > map.maxX || z < map.minGZ || z > map.maxZ))
						continue;
					
					BuildColumnThreaded(GetChunk2D (x, z));
				}
			}
		}
		catch (TerraEditorException e)
		{
			Debug.LogWarning("TerraVol Editor Tool tried to execute terrain generation while it was null: "+e.Message);
		}
	}
	
	/// <summary>
	/// Generate terrain around the position.</summary>
	/// <param name="pos"> Terrain will be generated around this position.</param>
	/// <param name="threaded"> If true, terrain generation & building will be multithreaded.</param>
	public void UpdateAround(Vector3 pos, bool threaded)
	{
		try
		{
			int posX = Mathf.RoundToInt (pos.x / Chunk.SIZE_X_BLOCK);
			int posY = Mathf.RoundToInt (pos.y / Chunk.SIZE_Y_BLOCK);
			int posZ = Mathf.RoundToInt (pos.z / Chunk.SIZE_Z_BLOCK);
			Vector3i current = Chunk.ToChunkPosition (posX, posY, posZ);
			if (current != oldPos) {
				genDone = false;
				buildDone = false;
				grassDone = false;
			}

			// Hide chunks far away
			map.FreeColumns(current.x, current.z);
			
			// Generate dynamically
			if (!genDone) {
				List<Vector3i> nearEmpties = LazyFindNearestNotGeneratedColumn (current.x, current.z, map.buildDistance+1, 1, 1);
				if (nearEmpties.Count != 0) {
					for (int i=0; i < nearEmpties.Count; i++) {
						Vector3i nearEmpty = nearEmpties[i];
						int cx = nearEmpty.x;
						int cz = nearEmpty.z;
						if (threaded)
							GenerateColumnThreaded (GetChunk2D (cx, cz));
						else
							GenerateColumn (cx, cz);
					}
				} else {
					genDone = true;
				}
			}
				
			// Build dynamically
			if (!buildDone) {
				List<Vector3i> nearEmpties = LazyFindNearestNotBuiltColumn (current.x, current.z, map.buildDistance, 1, 1);
				if (nearEmpties.Count != 0) {
					for (int i=0; i < nearEmpties.Count; i++) {
						Vector3i nearEmpty = nearEmpties[i];
						int cx = nearEmpty.x;
						int cz = nearEmpty.z;
						if (NeighbourColumnsAreGenerated (cx, cz)) {
							if (threaded)
								BuildColumnThreaded(GetChunk2D (cx, cz));
							else
								BuildColumn (cx, cz);
						}
					}
				} else {
					buildDone = true;
				}
			}
			

			
			// Display grass
			if (threaded && !grassDone) {
				Vector3i? nearEmpty = LazyFindNearestNoGrassColumn (current.x, current.z, (int)(map.grassDrawDistance / (Chunk.SIZE_AVERAGE_BLOCK * Chunk.SIZE_X)) + 1, 1);
				if (nearEmpty.HasValue) {
					int cx = nearEmpty.Value.x;
					int cz = nearEmpty.Value.z;
					BuildGrassColumn (cx, cz);
				} else {
					grassDone = true;
				}
			}
			
			oldPos = current;
		}
		catch (TerraEditorException e)
		{
			Debug.LogWarning("TerraVol Editor Tool tried to execute terrain generation while it was null: "+e.Message);
		}
	}

	/// <summary>
	/// Useful to know if neighbour columns have already been generated.</summary>
	private bool NeighbourColumnsAreGenerated (int cx, int cz)
	{			
		for (int z=cz-1; z<=cz+1; z++) {
			for (int x=cx-1; x<=cx+1; x++) {
				if (!GetChunk2D (x, z).generated && (!map.limitSize || (x >= map.minGX && x <= map.maxX && z >= map.minGZ && z <= map.maxZ))){
					return false;
				}
			}
		}
		return true;
	}
	
	/// <summary>
	/// Find the nearest not-yet-generated columns and returns them.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units from which to search around</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units from which to search around</param>
	/// <param name="radius"> Search radius in chunks' units</param>
	/// <param name="startRadius"> Search radius in chunks' units in which wolumns will be ignored</param>
	/// <param name="count"> Maximum number of columns to return.</param>
	/// <returns> Found columns</returns>
	private List<Vector3i> LazyFindNearestNotGeneratedColumn (int cx, int cz, int radius, int startRadius, int count)
	{
		List<Vector3i> result = new List<Vector3i>();
		Chunk2D chunk2D = GetChunk2D (cx, cz);
		if (!chunk2D.generated && !chunk2D.generating && 
				(!map.limitSize || (cx >= map.minGX && cx <= map.maxGX && cz >= map.minGZ && cz <= map.maxGZ)))
		{
			result.Add( new Vector3i (cx, 0, cz) );
			count--;
		}
		
		if (count > 0) {
			for (int rad=startRadius; rad <= radius; rad++) {
				for (int z=cz-rad; z<=cz+rad; z++) {
					for (int x=cx-rad; x<=cx+rad; x++) {
						if (x < cx - rad + 1 || x > cx + rad - 1 || z < cz - rad + 1 || z > cz + rad - 1) {
							// Map size limit
							if (map.limitSize && (x < map.minGX || x > map.maxGX || z < map.minGZ || z > map.maxGZ))
								continue;
							
							chunk2D = GetChunk2D (x, z);
							if (!chunk2D.generated && !chunk2D.generating) {
								result.Add( new Vector3i (x, 0, z) );
								count--;
								if (count == 0)
									return result;
							}
						}
					}
				}
			}
		}
		return result;
	} 
	
	/// <summary>
	/// Find the nearest not-yet-built columns and returns them.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units from which to search around</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units from which to search around</param>
	/// <param name="radius"> Search radius in chunks' units</param>
	/// <param name="startRadius"> Search radius in chunks' units in which wolumns will be ignored</param>
	/// <param name="count"> Maximum number of columns to return.</param>
	/// <returns> Found columns</returns>
	private List<Vector3i> LazyFindNearestNotBuiltColumn (int cx, int cz, int radius, int startRadius, int count)
	{
		List<Vector3i> result = new List<Vector3i>();
		if (!GetChunk2D (cx, cz).built && 
				(!map.limitSize || (cx >= map.minGX && cx <= map.maxX && cz >= map.minGZ && cz <= map.maxZ)))
		{
			result.Add( new Vector3i (cx, 0, cz) );
			count--;
		}
		
		if (count > 0) {
			for (int rad=startRadius; rad <= radius; rad++) {
				for (int z=cz-rad; z<=cz+rad; z++) {
					for (int x=cx-rad; x<=cx+rad; x++) {
						if (x <= cx - rad || x >= cx + rad || z <= cz - rad || z >= cz + rad) {
							// Map size limit
							if (map.limitSize && (x < map.minGX || x > map.maxX || z < map.minGZ || z > map.maxZ))
								continue;
									
							Chunk2D c2d = GetChunk2D (x, z);
							if (!c2d.built) {
								result.Add( new Vector3i (x, 0, z) );
								count--;
								if (count == 0)
									return result;
							} else if (!c2d.display) {
								map.DisplayColumn(c2d, true);
							}
						}
					}
				}
			}
		}
		return result;
	}
	
	/// <summary>
	/// Find the nearest column on which grass hasn't been generated yet, and returns them.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units from which to search around</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units from which to search around</param>
	/// <param name="radius"> Search radius in chunks' units</param>
	/// <param name="startRadius"> Search radius in chunks' units in which wolumns will be ignored</param>
	/// <returns> Found column</returns>
	private Vector3i? LazyFindNearestNoGrassColumn (int cx, int cz, int radius, int startRadius)
	{
		if (!GetChunk2D (cx, cz).grassBuilt && 
				(!map.limitSize || (cx >= map.minX && cx <= map.maxX && cz >= map.minZ && cz <= map.maxZ)))
			return new Vector3i (cx, 0, cz);
			
		for (int rad=startRadius; rad <= radius; rad++) {
			for (int z=cz-rad; z<=cz+rad; z++) {
				for (int x=cx-rad; x<=cx+rad; x++) {
					// Map size limit
					if (map.limitSize && (x < map.minX || x > map.maxX || z < map.minZ || z > map.maxZ))
						continue;
					
					if (x < cx - rad + 1 || x > cx + rad - 1 || z < cz - rad + 1 || z > cz + rad - 1) {
						if (!GetChunk2D (x, z).grassBuilt) {
							return new Vector3i (x, 0, z);
						}
					}
				}
			}
		}
		return null;
	}
	
	/// <summary>
	/// Generate column (not multithreaded).</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units</param>
	public void GenerateColumn (int cx, int cz)
	{
		Chunk2D chunk2D = GetChunk2D (cx, cz);
		if (chunk2D.generated)
			return;
		terrainGenerator.Generate (chunk2D);
		chunk2D.generated = true;
		chunk2D.generating = false;
		chunk2D.built = false;
	}
	
	/// <summary>
	/// Generate column (multithreaded). If a heightmap is used, multithreading will be disabled for generation.</summary>
	/// <param name="chunk2D"> The column.</param>
	public void GenerateColumnThreaded (Chunk2D chunk2D)
	{
		if (chunk2D.generated)
			return;
		chunk2D.generating = true;
		if (!terrainGenerator.useHeightmap) {
			threadManager.EnqueueForGeneration( chunk2D );
		} else {
			terrainGenerator.Generate (chunk2D);
			chunk2D.generated = true;
			chunk2D.generating = false;
			chunk2D.built = false;
		}
	}
	
	/// <summary>
	/// Build column (not multithreaded).</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units</param>
	public void BuildColumn (int cx, int cz)
	{
		Chunk2D chunk2D = GetChunk2D (cx, cz);
		if (chunk2D.built)
			return;
		map.BuildColumnImmediately (cx, cz);
		chunk2D.built = true;
		chunk2D.building = false;
	}
	
	/// <summary>
	/// Build column (multithreaded).</summary>
	/// <param name="chunk2D"> The column.</param>
	public void BuildColumnThreaded (Chunk2D chunk2D)
	{
		if (chunk2D.built)
			return;
		chunk2D.built = true;
		chunk2D.building = true;
		map.BuildColumn (chunk2D.position.x, chunk2D.position.y);
	}
	
	/// <summary>
	/// Display grass on column.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units</param>
	public void BuildGrassColumn (int cx, int cz)
	{
		Chunk2D chunk2D = GetChunk2D (cx, cz);
		if (chunk2D.grassBuilt)
			return;
		map.BuildGrassColumnImmediately (cx, cz);
		chunk2D.grassBuilt = true;
	}
		
	/// <summary>
	/// Get column. Create it if necessary.</summary>
	/// <param name="x"> X coordinate of the column in chunks' units</param>
	/// <param name="z"> Z coordinate of the column in chunks' units</param>
	private Chunk2D GetChunk2D (int x, int z)
	{
		if (map == null || map.TerraMap2D == null) {
			throw new TerraEditorException("Map or TerraMap2D is null");
		}
		Vector2i p = new Vector2i (x, z);
		if (lastChunk2D != null && lastChunk2DPos == p) {
			return lastChunk2D;
		} else {
			lastChunk2DPos = p;
			lastChunk2D = map.TerraMap2D.GetCreate(p);
		}
		return lastChunk2D;
	}
		
}
