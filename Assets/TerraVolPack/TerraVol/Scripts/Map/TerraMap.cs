// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using TerraVol;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// TerraMap component. This is the core component of TerraVol.</summary>
/// <remarks>
/// Requires TerraMapGenerator component.</remarks>
[AddComponentMenu("TerraVol/Map")]
public class TerraMap : MonoBehaviour
{

	/// <summary>Block Set is needed to generate voxelss.</summary>
	[SerializeField]
	public BlockSet blockSet;
	
	/// <summary>Should the terrain be built at runtime?</summary>
	[SerializeField]
	public bool buildDynamically = true;
	
	/// <summary>If true, map size will be limited</summary>
	[SerializeField]
	public bool limitSize = false;
	/// <summary>Max Map X (only if limitSize is true)</summary>
	[SerializeField]
	public int maxX = 20;
	/// <summary>Min Map X (only if limitSize is true)</summary>
	[SerializeField]
	public int minX = -20;
	/// <summary>Max Map Z (only if limitSize is true)</summary>
	[SerializeField]
	public int maxZ = 20;
	/// <summary>Min Map Z (only if limitSize is true)</summary>
	[SerializeField]
	public int minZ = -20;
	
	[HideInInspector]
	public int maxGX = 0;
	[HideInInspector]
	public int minGX = 0;
	[HideInInspector]
	public int maxGZ = 0;
	[HideInInspector]
	public int minGZ = 0;
	
	/// <summary>Map X size built before start</summary>
	[SerializeField]
	public int sizeXAtStart = 6;
	/// <summary>Map Z size built before start</summary>
	[SerializeField]
	public int sizeZAtStart = 6;
	
	/// <summary>Defines the bottom of the map, in chunks coordinates.</summary>
	/// <remarks>For example, a value of -2 means that the bottom of the map is at y = -2 * Chunk.SIZE_Y_TOTAL</remarks>
	[SerializeField]
	public int minY = -2;
	
	/// <summary>Distance (in chunks unit) from camera where chunks must be built.</summary>
	/// <remarks>For example, a value of 6 means that the draw distance of the terrain is 6 * Chunk.SIZE_X_TOTAL
	/// on X axis and 6 * Chunk.SIZE_Z_TOTAL on Z axis.</remarks>
	[SerializeField]
	public int buildDistance = 6;
	
	/// <summary>Do the chunks which are far away from the camera should be hidden?</summary>
	[SerializeField]
	public bool hideFarAwayChunks = true;
	
	/// <summary>Distance (in chunks unit) from camera where chunks shouldn't be rendered anymore.</summary>
	[SerializeField]
	public int hideDistance = 7;
	
	/// <summary>X size of a block</summary>
	[SerializeField]
	public int blockSizeX = 3;
	/// <summary>Y size of a block</summary>
	[SerializeField]
	public int blockSizeY = 3;
	/// <summary>Z size of a block</summary>
	[SerializeField]
	public int blockSizeZ = 3;
	
	/// <summary>Path of terra file to load. Can be "Assets/somepath/somefile.terra".</summary>
	[SerializeField]
	public string loadPath;
	
	// Internal use only. Used to undo actions in editor tool.
	private bool loadUndo = false;
	
	/// <summary>Heightmap to import.</summary>
	[SerializeField]
	public Texture2D heightmap;
	
	/// <summary>Define terrain height when using a heightmap.</summary>
	[SerializeField]
	public int maxYForheightmap;
		
	// Grass
	[SerializeField] 
	public bool generateGrass;
	[SerializeField] 
	public Material grassMaterial;
	[SerializeField] 
	public float grassSize = 0.4f;
	[SerializeField] 
	public float grassHeight = 3.5f;
	[SerializeField] 
	public float grassDirtyHeight = 1f;
	[SerializeField] 
	public float grassMinHeight = 0.5f;
	[SerializeField] 
	public float grassTextureTileX = 2f;
	[SerializeField] 
	public int grassDensity = 2;
	[SerializeField]
	public Color grassColor = new Color(0.6f, 0.6f, 0.6f, 0);
	[SerializeField]
	public Color grassDirtyColor = new Color(0.722f, 0.573f, 0.102f, 0);
	[SerializeField] 
	public float grassMaxSlopeAngle = 30f;
	[SerializeField] 
	public float windStrength;
	[SerializeField] 
	public float grassDrawDistance;
	private Vector4 grassWaving;
	private bool grassStandardShader = false;
	private bool grassWavingShader = false;
	private float grassDrawDistanceSquared;
	
	// Trees
	[SerializeField]
	public GameObject[] trees;
	[SerializeField]
	public float[] treesDeepInTheGround;
	[SerializeField]
	public float treesDensity = 0.211f;
	[HideInInspector]
	public PrefabPool[] treePools;
		
	// Data
	private Grid3 chunks;
	private Grid2 map2D;
		
	// Cache
	private static TerraMap instance;
	private TerrainGenerator terrainGenerator;
	public Block defaultBlock;
		
	// TerraVolEnhance
	public TerraVolEnhance terraVolEnhance = null;
	
	/// <summary>Get TerrainGenerator instance.</summary>
	internal TerrainGenerator TerrainGenerator {
		get {
			return terrainGenerator;
		}
		set {
			terrainGenerator = value;
		}
	}
	
	/// <summary>Get TerraMap instance. Do not use it in Awake methods: it may be null.</summary>
	public static TerraMap Instance {
		get {
			return instance;
		}
	}
	
	internal Grid2 TerraMap2D {
		get {
			return map2D;
		}
		set {
			map2D = value;
		}
	}

	internal Grid3 Chunks {
		get {
			return chunks;
		}
		set {
			chunks = value;
		}
	}
	
	public bool TerraMap2DIsNull()
	{
		return map2D == null;
	}
	
	public bool ChunksGridIsNull()
	{
		return chunks == null;
	}
		
	public void Awake ()
	{
		instance = this;
		System.DateTime start = System.DateTime.Now;
		maxGX = maxX + 1;
		minGX = minX - 1;
		maxGZ = maxZ + 1;
		minGZ = minZ - 1;
		TerraMapGenerator tmg = GetComponent<TerraMapGenerator>();
		// Checks
		if (tmg == null) {
			enabled = false;
			throw new UnityException ("TerraMapGenerator component is required");
		}
		if (blockSet == null) {
			enabled = false;
			throw new UnityException ("BlockSet must be defined in TerraMap component");
		}
		if (grassDensity < 1 || grassDensity > 3) {
			grassDensity = 3;
			Debug.LogError ("[TerraVol] Grass Density must be equal to 1, 2 or 3.");
		}
		foreach (GameObject tree in trees) {
			if (tree.tag != "Tree") {
				enabled = false;
				throw new UnityException ("All trees must be tagged with 'Tree' tag.");
			}
		}
		if (!buildDynamically) {
			hideFarAwayChunks = false;
			Debug.LogWarning ("[TerraVol] 'Hide Far Away Chunks' has been disabled because 'Build Dynamically' is disabled.");
		}
		if (hideFarAwayChunks && hideDistance <= buildDistance+1) {
			hideDistance = buildDistance + 2;
			Debug.LogWarning ("[TerraVol] 'Hide Distance' must be greater than 'Build Distance' + 1. 'Hide Distance' has been set to " + hideDistance);
		}
		if (treesDeepInTheGround.Length < trees.Length) {
			enabled = false;
			throw new UnityException ("'treesDeepInTheGround' array must have the same number of element than 'trees' array.");
		}
		if (heightmap != null && (!limitSize || minX >= maxX || minZ >= maxZ || minY >= maxYForheightmap)) {
			enabled = false;
			if (!limitSize)
				throw new UnityException ("'Limit Size' must be enabled when using heightmap.");
			if (minX >= maxX || minZ >= maxZ)
				throw new UnityException ("minX, maxX, minZ and maxZ must be defined when using heightmap.");
			if (minY >= maxYForheightmap)
				throw new UnityException ("'Max Y For Heightmap' must be defined when using heightmap.");
		}
			
		// Init block size
		Chunk.SetBlockSize (blockSizeX, blockSizeY, blockSizeZ);
		
		// Init recorder
		WorldRecorder.NewInstance();
			
		// Init builder
		ChunkBuilder.Init (blockSet.GetMaterials ().Length);
		
		// 3D grid init
		chunks = new Grid3 (minY);
			
		// 2D grid init
		map2D = new Grid2 (this);

		// tree pools
		treePools = new PrefabPool[trees.Length];
		for (int i=0; i < trees.Length; ++i) {
			treePools[i] = new PrefabPool(trees[i]);
		}
			
		// Load map data from file
		if (!loadUndo && loadPath != null && loadPath.Length != 0) {
			Debug.Log ("[TerraVol] Loading map...");
			if (Load (loadPath)) {
				Debug.Log ("[TerraVol] TerraMap loaded.");
				tmg.randomize = false;
			} else {
				Debug.LogError ("[TerraVol] File doesn't exist. TerraMap could not be loaded.");
				tmg.randomize = true;
			}
		} else if (loadUndo) {
			// Load map after undoing action
			tmg.randomize = !Load (WorldRecorder.LOAD_UNDO_PATH);
		} else {
			// Generate map randomly
			tmg.randomize = true;
		}
		loadUndo = false;
		
		// Remove all existing chunks
		List<GameObject> children = new List<GameObject> ();
		foreach (Transform child in transform) {
			children.Add (child.gameObject);
		}
		for (int i=0; i < children.Count; i++) {
			UnityEngine.Object.DestroyImmediate (children [i]);
		}
			
		// Securize entries
		if (treesDensity < 0.01f)
			treesDensity = 0.01f;
			
		// Init TerraVolEnhance
		terraVolEnhance = new TerraVolEnhance(this);
		
		// Init terrain generator
		terrainGenerator = new TerrainGenerator (this, tmg);
		tmg.TerrainGenerator = terrainGenerator;
		
		// Init threading
		ThreadManager.ResetInstance();
		
		// Cache default block
		defaultBlock = blockSet.GetBlock ("Default");
			
		// Finally, call a GC Collect to free some memory
		System.GC.Collect ();
		Debug.Log ("[TerraVol] Total loading time : " + (System.DateTime.Now - start));
	}
		
		
	// Called once at start
	public void Start ()
	{		
		// Shaders
		if (grassMaterial != null) {
			grassDrawDistanceSquared = grassDrawDistance * grassDrawDistance;
			
			if (grassMaterial.HasProperty("_WaveAndDistance")) {
				grassWaving = grassMaterial.GetVector("_WaveAndDistance");
				grassWaving.w = grassDrawDistanceSquared;
				grassMaterial.SetVector("_WaveAndDistance", grassWaving);
			}
			
			grassWavingShader = grassMaterial.HasProperty("_WaveAndDistance");
			grassStandardShader = grassMaterial.HasProperty("_CameraPosition");
		}
		
		// Prepare WorldRecorder
		//WorldRecorder.Instance.worldMinY = chunks.MinY;
		//WorldRecorder.Instance.worldMaxY = chunks.MaxY;
		
		// Start all threads
		ThreadManager.GetInstance(this).StartAll();
	}
	
	public void Update()
	{
		// Update grass shader to handle wind animation
		UpdateGrassShader ();
	}
		
	
	public void UpdateAll ()
	{
		// Force all chunks to update
		foreach (Transform child in transform) {
			Chunk childChunk = child.GetComponent<Chunk> ();
			if (childChunk != null && childChunk.enabled) {
				childChunk.Update ();
			}
		}
	}
	
	// Update grass shader to handle wind animation
	private void UpdateGrassShader ()
	{
		// Update camera position
		if (grassStandardShader) {
			Vector3 cpos = Camera.main.transform.position;
			Vector4 _CameraPosition = new Vector4 ( cpos.x,
											cpos.y,
											cpos.z, 1f / grassDrawDistanceSquared);
											
			grassMaterial.SetVector ("_CameraPosition", _CameraPosition);
		}
		// Update waving shader
		if (grassWavingShader) {
			grassWaving.x += 0.01f * windStrength * Time.deltaTime;
			grassMaterial.SetVector("_WaveAndDistance", grassWaving);
		}
	}
	
	/// <summary>
	/// Enqueue all chunks of a column for building in threads.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units</param>
	public void BuildColumn (int cx, int cz)
	{
		ChunkData chunk = null;
		for (int cy=chunks.MinY; cy<=chunks.MaxY; cy++) {
			Vector3i pos = new Vector3i (cx, cy, cz);
			chunk = GetChunkDataInstance (pos);
			if (chunk != null) {
				chunk.GetChunkInstance ().EnqueueForBuilding(true);
			}
		}
	}
	
	/// <summary>
	/// Force all chunks of a column to build immediately.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units</param>
	public void BuildColumnImmediately (int cx, int cz)
	{
		ChunkData chunk = null;
		for (int cy=chunks.MinY; cy<=chunks.MaxY; cy++) {
			Vector3i pos = new Vector3i (cx, cy, cz);
			chunk = GetChunkDataInstance (pos);
			if (chunk != null) {
				chunk.GetChunkInstance ().BuildImmediately(true);
			}
		}
	}
	
	/// <summary>
	/// Enable all grass generators of a column to make them update grass mesh.</summary>
	/// <param name="cx"> X coordinate of the column in chunks' units</param>
	/// <param name="cz"> Z coordinate of the column in chunks' units</param>
	public void BuildGrassColumnImmediately (int cx, int cz)
	{
		if (!generateGrass)
			return;
		
		ChunkData chunk = null;
		for (int cy=chunks.MinY; cy<=chunks.MaxY; cy++) {
			Vector3i pos = new Vector3i (cx, cy, cz);
			chunk = GetChunkDataInstance (pos);
			if (chunk != null) {
				chunk.GetChunkInstance ().GrassGenerator.enabled = true;
			}
		}
	}
	
	/// <summary>
	/// Display or hide all chunks of a column.</summary>
	/// <param name="chunk2D"> Column to display</param>
	/// <param name="display"> If true, chunks will be rendered, otherwise they won't</param>
	public void DisplayColumn (Chunk2D chunk2D, bool display)
	{
		if (chunk2D.display != display) {
			for (int cy=chunks.MinY; cy<=chunks.MaxY; cy++) {
				Vector3i pos = new Vector3i (chunk2D.position.x, cy, chunk2D.position.y);
				ChunkData chunk = GetChunkData (pos);
				if (chunk != null && chunk.Chunk != null) {
					chunk.Chunk.Display(display);
				}
			}
			chunk2D.display = display;
		}
	}
	
	/// <summary>
	/// Free all columns of chunks that are far enough.</summary>
	/// <param name="cx"> Chunk X coordinate of the player</param>
	/// <param name="cZ"> Chunk Z coordinate of the player</param>
	public void FreeColumns (int cx, int cz)
	{
		map2D.FreeChunks2D(cx, cz, hideDistance, chunks);
	}
	
	/// <summary>
	/// Build chunk at given position.</summary>
	/// <param name="pos"> Position of the chunk in chunks' units</param>
	private void Build (Vector3i pos)
	{
		ChunkData chunk = GetChunkData (pos);
		if (chunk != null) {
			chunk.GetChunkInstance ().EnqueueForBuilding (true);
		}
	}
	
	/// <summary>
	/// Get chunk at given position.</summary>
	/// <param name="pos"> Position of the chunk in chunks' units</param>
	/// <returns> Chunk data. Can be null.</returns>
	/// <seealso cref="GetChunkDataInstance(Vector3i)"></seealso>
	/// <seealso cref="GetChunkDataInstanceNoCache(Vector3i)"></seealso>
	/// <seealso cref="GetChunkDataNoCache(Vector3i)"></seealso>
	public ChunkData GetChunkData (Vector3i pos)
	{
		return chunks.SafeGet (pos);
	}
	
	/// <summary>
	/// Get chunk at given position and create it if needed.</summary>
	/// <param name="pos"> Position of the chunk in chunks' units</param>
	/// <returns> Chunk data. Can't be null.</returns>
	/// <seealso cref="GetChunkData(Vector3i)"></seealso>
	/// <seealso cref="GetChunkDataInstanceNoCache(Vector3i)"></seealso>
	/// <seealso cref="GetChunkDataNoCache(Vector3i)"></seealso>
	public ChunkData GetChunkDataInstance (Vector3i pos)
	{
		return chunks.GetCreate (this, pos);
	}
	
	/// <summary>
	/// Set block data (voxel) at given position.</summary>
	/// <param name="block"> Block data to set</param>
	/// <param name="x"> X position of the block in block's units</param>
	/// <param name="y"> Y position of the block in block's units</param>
	/// <param name="z"> Z position of the block in block's units</param>
	public void SetBlock (float isovalue, Block block, int x, int y, int z)
	{
		ChunkData chunk = GetChunkDataInstance (Chunk.ToChunkPosition (x, y, z));
		if (chunk != null) {
			chunk.SetBlock (isovalue, block, Chunk.ToLocalPosition (x, y, z));
		}
	}

	/// <summary>
	/// Nullify block data (voxel) at given position.</summary>
	/// <param name="block"> Block data to set</param>
	/// <param name="x"> X position of the block in block's units</param>
	/// <param name="y"> Y position of the block in block's units</param>
	/// <param name="z"> Z position of the block in block's units</param>
	public void NullifyBlock (int x, int y, int z)
	{
		ChunkData chunk = GetChunkData (Chunk.ToChunkPosition (x, y, z));
		if (chunk != null) {
			chunk.NullifyBlock (Chunk.ToLocalPosition (x, y, z));
		}
	}
		
	/// <summary>
	/// Convert world position (in world units) to absolute block position by rounding value.
	/// </summary>
	[Obsolete("use Chunk.ToTerraVolPosition instead.")]
	public static Vector3i ToTerraVolPosition (Vector3 position)
	{
		return Chunk.ToTerraVolPosition(position);
	}
		
	/// <summary>
	/// Get the Block Set</summary>
	/// <returns> Block Set</returns>
	public BlockSet GetBlockSet ()
	{
		return blockSet;
	}
		
	/// <summary>
	/// Save map in a file. You may want to save the scene after this.</summary>
	/// <param name="path"> The path of the file where you want to save the map. Ex: "Assets/somepath/somefile.terra"</param>
	public void Save (string path)
	{
		WorldRecorder.Persist(this, path);
		// Set 'load path' property
		if (path.Contains( Application.dataPath )) {
			string[] stringSeparators = new string[] {Application.dataPath};
      		string[] result = path.Split(stringSeparators, 
                            System.StringSplitOptions.RemoveEmptyEntries);
			
			string subresult = result[0];
			if (result.Length > 1)
				subresult = result[1];
			loadPath = "R:" + subresult;
		} else {
			loadPath = path;
		}
	}
		
	/// <summary>
	/// Loads map from a file.</summary>
	/// <param name="path"> The path of the file from which you want to load the map.</param>
	/// <returns> True if loading was successful. False otherwise</returns>
	public bool Load (string path)
	{
		string _path = path;
		// Read 'load path' property
		if (path.Contains("R:")) {
			_path = Application.dataPath + path.Substring(2);
		}
		return WorldRecorder.Load(this, _path);
	}
	
	/// <summary>
	/// Internal use only. Reload map from file and rebuild the terrain from scratch.</summary>
	public void Reload (bool undo = false)
	{
		// Load map data from file instead of generating it with Perlin Noise
		if (undo || (loadPath != null && loadPath.Length != 0)) {
			if (undo || System.IO.File.Exists (loadPath)) {
				Debug.Log ("[TerraVol] Reload map...");
				
				// Rebuild map.
				List<GameObject> children = new List<GameObject> ();
				foreach (Transform child in transform) {
					children.Add (child.gameObject);
				}
				for (int i=0; i < children.Count; i++) {
					UnityEngine.Object.DestroyImmediate (children [i]);
				}
				TerraMap2D = null;
				Chunks = null;
				loadUndo = undo;
				Awake ();
				GetComponent<TerraMapGenerator>().Awake ();
				Start ();
				GetComponent<TerraMapGenerator>().Start ();
				System.GC.Collect ();
				UpdateAll();
				Debug.Log ("[TerraVol] Rebuild done.");
			
			} else {
				Debug.LogError ("[TerraVol] File doesn't exist. TerraMap could not be loaded.");
			}
		} else {
			Debug.LogWarning ("[TerraVol] Map won't be loaded from file because the file path is empty.");
		}
	}
	
	/// <summary>
	/// Dig the terrain. This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.</summary>
	/// <remarks>
	/// See documentation for more information.
	/// ex: WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(position), radius * Vector3.one, block,
	/// ActionDataType.Dig, brush));</remarks>
	[Obsolete("use WorldRecorder.Instance.PerformAction instead.")]
	public void Dig (Block block, Vector3 position, float radius, float digSpeed, BrushType brush = BrushType.Sphere, bool force = false, bool clearVegetation = true, bool harmonizeChunks = true)
	{
		WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(position), radius * Vector3.one, block,
					ActionDataType.Dig, brush, false));
	}
		
	/// <summary>
	/// This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.</summary>
	/// <remarks>
	/// See documentation for more information.
	/// ex: WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(position), radius * Vector3.one, block,
	/// ActionDataType.Dig, brush));</remarks>
	[Obsolete("use WorldRecorder.Instance.PerformAction instead.")]
	public void SetBlocksAndRecompute (Block block, Vector3 position, float radius, float valueToAdd, BrushType brush = BrushType.Sphere, bool force = false, bool clearVegetation = true, bool harmonizeChunks = true)
	{
		Debug.LogError("This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.");
	}
	
	/// <summary>
	/// This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.</summary>
	/// <remarks>
	/// See documentation for more information.
	/// ex: WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(position), radius * Vector3.one, block,
	/// ActionDataType.Dig, brush));</remarks>
	[Obsolete("use WorldRecorder.Instance.PerformAction instead.")]
	public void SetBlocksAndRecomputeSetIso (Block block, Vector3 position, float radius, float valueToSet, BrushType brush = BrushType.Sphere, bool force = false, bool clearVegetation = true, bool harmonizeChunks = true)
	{
		Debug.LogError("This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.");
	}
		
		
	/// <summary>
	/// This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.</summary>
	/// <remarks>
	/// See documentation for more information.
	/// ex: WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(position), radius * Vector3.one, block,
	/// ActionDataType.Dig, brush));</remarks>
	[Obsolete("use WorldRecorder.Instance.PerformAction instead.")]
	public void SetBlockAndRecompute (Block block, Vector3 position, float valueToAdd, bool force = false)
	{
		Debug.LogError("This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.");
	}
	
	
	/// <summary>
	/// This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.</summary>
	/// <remarks>
	/// See documentation for more information.
	/// ex: WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(position), radius * Vector3.one, block,
	/// ActionDataType.Dig, brush));</remarks>
	[Obsolete("use WorldRecorder.Instance.PerformAction instead.")]
	public void FlattenAndRecompute (Block block, Vector3 position, float radius, bool force = false, bool clearVegetation = true, bool harmonizeChunks = true)
	{
		Debug.LogError("This method isn't supported anymore. Please use WorldRecorder.Instance.PerformAction instead.");
	}
		
}