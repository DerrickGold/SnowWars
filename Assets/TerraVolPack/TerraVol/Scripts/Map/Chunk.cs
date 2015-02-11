// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com

// Uncomment '#define TERRAVOL_RTP3' if you use RTP3.
// IMPORTANT: remember to comment the line '#define LOCAL_SPACE_UV' in ReliefTerrainVertexBlendTriplanar.shader
//#define TERRAVOL_RTP3

using UnityEngine;
using TerraVol;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Chunk component.</summary>
/// <remarks>
/// This is in charge of updating chunk's mesh and collider from lastly computed mesh data.
/// It also calls some TerraVolEnhance methods to create vegetation and contains a grass generator to 
/// generate grass on the chunk. Voxels data is managed in ChunkData class.</remarks>
public class Chunk : MonoBehaviour
{
		
	internal const int SIZE_X_BITS = 3;
	internal const int SIZE_Y_BITS = 3;
	internal const int SIZE_Z_BITS = 3;
	// Number of blocks in a chunk
	public const int SIZE_X = 1 << SIZE_X_BITS;
	public const int SIZE_Y = 1 << SIZE_Y_BITS;
	public const int SIZE_Z = 1 << SIZE_Z_BITS;
	// Size of each block
	public static int SIZE_X_BLOCK = 3;
	public static int SIZE_Y_BLOCK = 3;
	public static int SIZE_Z_BLOCK = 3;
	public static float SIZE_AVERAGE_BLOCK = 3;
	// Total size (in Unity's units) of a chunk
	public static int SIZE_X_TOTAL = SIZE_X * SIZE_X_BLOCK;
	public static int SIZE_Y_TOTAL = SIZE_Y * SIZE_Y_BLOCK;
	public static int SIZE_Z_TOTAL = SIZE_Z * SIZE_Z_BLOCK;
	// Size of a block
	public static Vector3i SIZE_BLOCK = new Vector3i(SIZE_X_BLOCK, SIZE_Y_BLOCK, SIZE_Z_BLOCK);
	
	public static Bounds chunkBounds = new Bounds(
		new Vector3(SIZE_X_TOTAL/2, SIZE_Y_TOTAL/2, SIZE_Z_TOTAL/2),
		new Vector3(SIZE_X_TOTAL, SIZE_Y_TOTAL, SIZE_Z_TOTAL));
	
	[SerializeField]
	private BlockSet blockSet;
	private ChunkData chunkData;
	private ThreadManager threadManager;
	private int buildCount = 0;
	private GrassGenerator grassGenerator = null; 
		
	// Cache mesh filter and collider
	private TerraMap map;
	private MeshFilter filter = null;
	private MeshCollider meshCollider = null;
	private MeshRenderer meshRenderer = null;
	[HideInInspector]
	[SerializeField]
	private bool dirty = false;
	[HideInInspector]
	[SerializeField]
	private bool built = false;
	[HideInInspector]
	[SerializeField]
	private bool createVegetation = true;
	[HideInInspector]
	[SerializeField]
	private int buildId = 0;
	
	internal int BuildCount {
		get {
			return buildCount;
		}
	}
	
	internal GrassGenerator GrassGenerator {
		get {
			return grassGenerator;
		}
	}
	
	public MeshFilter Filter {
		get {
			return filter;
		}
	}
	
	public MeshRenderer MeshRenderer {
		get {
			return meshRenderer;
		}
	}

	public MeshCollider CMeshCollider {
		get {
			return meshCollider;
		}
	}

	public ChunkData ChunkData {
		get {
			return chunkData;
		}
		set {
			chunkData = value;
		}
	}
	
	public bool IsDirty {
		get {
			return dirty;
		}
		set {
			dirty = value;
		}
	}
	
	public bool Built {
		get {
			return built;
		}
		set {
			built = value;
		}
	}
	internal int BuildId {
		get {
			return buildId;
		}
	}
	
	/// <summary>
	/// Create a new Chunk object with its chunk component and its grass generator.</summary>
	/// <param name="pos"> The position of this chunk (in TerraVol coordinates) in the map.</param>
	/// <param name="map"> The TerraVol map.</param>
	/// <param name="chunkData"> The voxels data of this chunk.</param>
	/// <returns> Chunk component.</returns>
	internal static Chunk CreateChunk (Vector3i pos, TerraMap map, ChunkData chunkData)
	{
		GameObject go = new GameObject ("Chunk");
		go.transform.parent = map.transform;
		go.transform.localPosition = new Vector3 (pos.x * Chunk.SIZE_X_TOTAL, pos.y * Chunk.SIZE_Y_TOTAL, pos.z * Chunk.SIZE_Z_TOTAL);
		go.transform.localRotation = Quaternion.identity;
		go.transform.localScale = Vector3.one;
			
		Chunk chunk = go.AddComponent<Chunk> ();
		chunk.map = map;
		chunk.enabled = false;
		chunk.blockSet = map.GetBlockSet ();
		chunk.chunkData = chunkData;
		chunk.threadManager = ThreadManager.GetInstance(map);
		if (map.generateGrass) {
			chunk.grassGenerator = GrassGenerator.CreateGrassGenerator( map, chunkData, chunk.transform );
			chunk.grassGenerator.PositionBase = chunk.transform.position;
		}
		chunk.meshRenderer = go.AddComponent<MeshRenderer> ();
		chunk.meshRenderer.sharedMaterials = chunk.blockSet.GetMaterials ();
		go.renderer.castShadows = true;
		go.renderer.receiveShadows = true;
		chunk.filter = go.AddComponent<MeshFilter> ();
		chunk.meshCollider = go.AddComponent<MeshCollider> ();
		chunk.meshRenderer.enabled = false;
		chunk.meshCollider.enabled = false;
		#if TERRAVOL_RTP3
		chunkData.useRTP3 = true;
		go.AddComponent<ReliefTerrainVertexBlendTriplanar> ();
		#endif

		return chunk;
	}
		
	/// <summary>
	/// Called once per frame. Checks if post build should be executed.</summary>
	public void Update ()
	{
		if (!built) {
			PostBuild ();
			enabled = false;
		}
	}
	
	/// <summary>
	/// Enqueue this chunk for building in another thread. This will ensure that the chunk will be built with almost no
	/// impact on frame rate.
	/// </summary>
	private void Build ()
	{
		// Call TerraVolEnhance method
		if (map.terraVolEnhance != null)
			map.terraVolEnhance.OnChunkBuildBefore (this);
		
		this.built = true;
		this.enabled = true;
		buildId++;
		threadManager.EnqueueForBuilding (this, this.buildId);
	}
	
	/// <summary>
	/// Build this chunk immediately (on the main thread). This will ensure the chunk is built on this frame.
	/// </summary>
	private void BuildImmediate ()
	{
		// Call TerraVolEnhance method
		if (map.terraVolEnhance != null)
			map.terraVolEnhance.OnChunkBuildBefore (this);
		
		buildId++;
		chunkData.IsHarmonizable = false;
		chunkData.BuildStarted = true;
		
		ChunkBuilder chunkBuilder = ChunkBuilder.getMainThreadInstance ();		
		MeshData meshData = chunkBuilder.BuildChunk(chunkData);
		
		if (meshData.vertices.Count != 0) {
			BuildHelper.ComputeNormals(meshData, chunkData);
			BuildHelper.ComputeUVs(meshData, chunkData);
			BuildHelper.SolveTangents(meshData);
			if (chunkData.useRTP3)
				BuildHelper.ComputeColorsAfterBuild(meshData, chunkData, chunkData.Position.y == 0, chunkData.Position.y < 0);
			chunkData.MeshDataTmp = meshData;
			chunkData.IsHarmonizable = true;
			BuildHelper.HarmonizeTwinVertices(meshData, chunkData, false);
		}
		
		// Precompute arrays from lists and post-build
		meshData.PrepareArrays();
		chunkData.MeshData = meshData;
		PostBuild ();
		
	}
	
	/// <summary>
	/// Perform tasks that must be executed once the new mesh data has been computed (eventually in a thread).
	/// </summary>
	private void PostBuild ()
	{
		chunkData.BuildStarted = false;
		
		if (chunkData == null || chunkData.MeshData == null)
			return;

		transform.localPosition = new Vector3 (chunkData.Position.x * Chunk.SIZE_X_TOTAL, chunkData.Position.y * Chunk.SIZE_Y_TOTAL, chunkData.Position.z * Chunk.SIZE_Z_TOTAL);
		
		if (chunkData.MeshData.vertices.Count != 0) {
			// Update mesh filter and mesh collider
			meshCollider.sharedMesh = null;
			Mesh filterMesh = chunkData.MeshData.ToMesh (filter.sharedMesh);
			if (filterMesh != null)
				filterMesh.bounds = chunkBounds;
			filter.sharedMesh = filterMesh;
			meshCollider.sharedMesh = filter.sharedMesh;
				
			if (createVegetation) {
				// Clear existing vegetation
				ClearVegetation ();
				
				// Call TerraVolEnhance method to create vegetation
				if (map.terraVolEnhance != null) {
					map.terraVolEnhance.CreateVegetation(this);
				}
				// Ask the grass generator to generate grass
				GenerateGrass ();
			}
			
			meshRenderer.enabled = true;
			meshCollider.enabled = true;
		}
		
		// Inc build count and mark this chunk as buit
		buildCount++;
		built = true;		
		
		// Call TerraVolEnhance method
		if (map.terraVolEnhance != null)
			map.terraVolEnhance.OnChunkBuildAfter (this);
	}
	
	/// <summary>
	/// Display or hide chunk.</summary>
	/// <param name="display"> If true, chunk will be rendered, otherwise it won't</param>
	public void Display(bool display)
	{
		if (meshRenderer != null) {
			meshRenderer.enabled = display;
			meshCollider.enabled = display;
			foreach (Transform child in transform) {
				Renderer r = child.renderer;
				if (r != null)
					r.enabled = display;
			}
		}
		if (!display && grassGenerator != null) {
			grassGenerator.ClearGrass();
		}
	}
	
	/// <summary>
	/// Convert block position to chunk position.
	/// </summary>
	internal static Vector3i ToChunkPosition (int pointX, int pointY, int pointZ)
	{
		int chunkX = pointX >> SIZE_X_BITS;
		int chunkY = pointY >> SIZE_Y_BITS;
		int chunkZ = pointZ >> SIZE_Z_BITS;
		return new Vector3i (chunkX, chunkY, chunkZ);
	}
	
	/// <summary>
	/// Convert block position to chunk position.
	/// </summary>
	internal static Vector3i ToChunkPosition (Vector3i p)
	{
		int chunkX = p.x >> SIZE_X_BITS;
		int chunkY = p.y >> SIZE_Y_BITS;
		int chunkZ = p.z >> SIZE_Z_BITS;
		return new Vector3i (chunkX, chunkY, chunkZ);
	}
	
	/// <summary>
	/// Convert absolute block position to local block position (ie. position of block in its chunk).
	/// </summary>
	internal static Vector3i ToLocalPosition (int pointX, int pointY, int pointZ)
	{
		int localX = pointX & (SIZE_X - 1);
		int localY = pointY & (SIZE_Y - 1);
		int localZ = pointZ & (SIZE_Z - 1);
		return new Vector3i (localX, localY, localZ);
	}
	
	/// <summary>
	/// Convert absolute block position to local block position (ie. position of block in its chunk).
	/// </summary>
	internal static Vector3i ToLocalPosition (Vector3i p)
	{
		int localX = p.x & (SIZE_X - 1);
		int localY = p.y & (SIZE_Y - 1);
		int localZ = p.z & (SIZE_Z - 1);
		return new Vector3i (localX, localY, localZ);
	}

	/// <summary>
	/// Convert chunk + block position to world position in world units.
	/// </summary>
	internal static Vector3i ToWorldPosition (Vector3i chunkPosition, Vector3i localPosition)
	{
		int worldX = chunkPosition.x * SIZE_X_TOTAL + localPosition.x * SIZE_X_BLOCK;
		int worldY = chunkPosition.y * SIZE_Y_TOTAL + localPosition.y * SIZE_Y_BLOCK;
		int worldZ = chunkPosition.z * SIZE_Z_TOTAL + localPosition.z * SIZE_Z_BLOCK;
		return new Vector3i (worldX, worldY, worldZ);
	}
	
	/// <summary>
	/// Convert absolute block position to world position in world units.
	/// </summary>
	internal static Vector3 ToWorldPosition (Vector3i absoluteBlockPosition)
	{
		int worldX = absoluteBlockPosition.x * SIZE_X_BLOCK;
		int worldY = absoluteBlockPosition.y * SIZE_Y_BLOCK;
		int worldZ = absoluteBlockPosition.z * SIZE_Z_BLOCK;
		return new Vector3 (worldX, worldY, worldZ);
	}
	
	/// <summary>
	/// Convert chunk + local position to world position in world units.
	/// </summary>
	internal static Vector3 ToWorldPosition (Vector3i chunkPosition, Vector3 localPosition)
	{
		float worldX = chunkPosition.x * SIZE_X_TOTAL + localPosition.x;
		float worldY = chunkPosition.y * SIZE_Y_TOTAL + localPosition.y;
		float worldZ = chunkPosition.z * SIZE_Z_TOTAL + localPosition.z;
		return new Vector3 (worldX, worldY, worldZ);
	}
	
	/// <summary>
	/// Convert world position (in world units) to absolute block position by rounding value.
	/// </summary>
	public static Vector3i ToTerraVolPosition (Vector3 position)
	{
		int posX = Mathf.RoundToInt (position.x / Chunk.SIZE_X_BLOCK);
		int posY = Mathf.RoundToInt (position.y / Chunk.SIZE_Y_BLOCK);
		int posZ = Mathf.RoundToInt (position.z / Chunk.SIZE_Z_BLOCK);
		return new Vector3i (posX, posY, posZ);
	}
	
	/// <summary>
	/// Convert world position (in world units) to absolute block position.
	/// </summary>
	public static Vector3i ToTerraVolPositionFloor (Vector3 position)
	{
		int posX = Mathf.FloorToInt (position.x / Chunk.SIZE_X_BLOCK);
		int posY = Mathf.FloorToInt (position.y / Chunk.SIZE_Y_BLOCK);
		int posZ = Mathf.FloorToInt (position.z / Chunk.SIZE_Z_BLOCK);
		return new Vector3i (posX, posY, posZ);
	}
	
	
	internal static void SetBlockSize (int x, int y, int z)
	{
		SIZE_X_BLOCK = x;
		SIZE_Y_BLOCK = y;
		SIZE_Z_BLOCK = z;
		SIZE_AVERAGE_BLOCK = (float)(SIZE_X_BLOCK + SIZE_Y_BLOCK + SIZE_Z_BLOCK)/3f;
		SIZE_X_TOTAL = SIZE_X * SIZE_X_BLOCK;
		SIZE_Y_TOTAL = SIZE_Y * SIZE_Y_BLOCK;
		SIZE_Z_TOTAL = SIZE_Z * SIZE_Z_BLOCK;
		chunkBounds = new Bounds(
			new Vector3(SIZE_X_TOTAL/2, SIZE_Y_TOTAL/2, SIZE_Z_TOTAL/2),
			new Vector3(SIZE_X_TOTAL, SIZE_Y_TOTAL, SIZE_Z_TOTAL));
	}
		
		
	// PUBLIC
		
	/// <summary>
	/// Clear vegetation and grass at a given point in a given range.
	/// </summary>
	/// <param name="hitPoint"> World position of the given point.</param>
	/// <param name="range"> Range in which vegetation must be removed.</param>
	public void ClearVegetationInRange (Vector3 hitPoint, float range)
	{
		List<GameObject> children = new List<GameObject> ();
		foreach (Transform child in transform) {
			if (child.tag == "Tree" && Vector3.Distance (hitPoint, child.position) < range)
				children.Add (child.gameObject);
		}
		for (int i=0; i < children.Count; i++) {
			if (!Application.isEditor)
				Object.Destroy (children[i]);
			else
				Object.DestroyImmediate (children[i]);
		}
		if (grassGenerator != null)
			grassGenerator.ClearGrassInRange(hitPoint, range);
	}
	
	/// <summary>
	/// Clear vegetation and grass of the chunk.
	/// </summary>
	public void ClearVegetation ()
	{
		List<GameObject> children = new List<GameObject> ();
		foreach (Transform child in transform) {
			if (child.tag == "Tree")
				children.Add (child.gameObject);
		}
		for (int i=0; i < children.Count; i++) {
			if (!Application.isEditor)
				Object.Destroy (children[i]);
			else
				Object.DestroyImmediate (children[i]);
		}
		if (grassGenerator != null)
			grassGenerator.ClearGrass(false);
	}
	
	public void GenerateGrass ()
	{
		// Ask the grass generator to generate grass
		if (map.generateGrass && grassGenerator != null) {
			grassGenerator.PositionBase = transform.position;
			grassGenerator.SrcMesh = chunkData.MeshData;
			grassGenerator.GenerateGrass();
		}
	}
		
	/// <summary>
	/// Useful to know if this chunk is built or not.
	/// </summary>
	/// <returns> True if this Chunk has been built since it was set as dirty.</returns>
	public bool IsBuilt {
		get {
			return built;
		}
	}
		
	/// <summary>
	/// Enqueue this chunk for building, on another thread. No impact on frame rate.
	/// </summary>
	/// <param name="createVegetation"> If true, vegetation will be generated.</param>
	public void EnqueueForBuilding (bool createVegetation)
	{
		this.IsDirty = true;
		this.createVegetation = createVegetation;
		Build ();
	}
	
	/// <summary>
	/// Build and post-build this chunk immediately. Possible impact on frame rate.
	/// </summary>
	/// <param name="createVegetation"> If true, vegetation will be generated.</param>
	public void BuildImmediately (bool createVegetation)
	{
		this.IsDirty = true;
		this.createVegetation = createVegetation;
		BuildImmediate ();
	}
		
	/// <summary>
	/// Useful to get mesh of this chunk.
	/// </summary>
	/// <returns> Mesh of this chunk.</returns>
	public Mesh GetMesh ()
	{
		if (filter != null)
			return filter.sharedMesh;
		return null;
	}
		
}
