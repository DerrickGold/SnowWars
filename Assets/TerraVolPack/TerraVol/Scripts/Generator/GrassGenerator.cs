using UnityEngine;
using TerraVol;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// GrassGenerator component. This is the core component of TerraVol grass system.</summary>
/// <remarks>
/// Must be added to a chunk.</remarks>
public class GrassGenerator : MonoBehaviour {
	
	const int CHILDREN_COUNT = 1;
	
	// Max is 65536 but we keep it smaller to avoid lag during instantiation. If you lower it, you may want to increase the CHILDREN_COUNT.
	const int MAX_VERTICES_PER_CHILD = 16384 * 2;
	const float FACTOR = 0.75f;
	const float MIN_DISTANCE_SQR_VERTICES = 0.75f;
	const float PERLIN_SCALE = 1f/10f;
	const float COS_30 = 0.86603f;
	const float SIN_30 = 0.5f;
	const float TAN_ACOS_08 = 0.75f;
	const float PERLIN_COEF = 0.7f;
	
	// Random
	System.Random random = new System.Random();
	
	// Source mesh (ground)
	private MeshData srcMesh;
	private ThreadManager threadManager;
	
	// Cache
	private ChunkData chunkData = null;
	private int buildId = 0;
	private Transform cTransform = null;
	private List<MeshFilter> grassChildrenFilter = new List<MeshFilter>();
	private List<MeshRenderer> grassChildrenRenderer = new List<MeshRenderer>();
	private List<MeshData> meshesData = null;
	
	// Properties
	private bool castShadows = false;
	private bool receiveShadows = true;
	private Material material = null;
	private float tileX;
	private float grassSize;
	private Color baseColor;
	private float baseHeight;
	private float minHeight;
	private Color dirtyColor = Color.white;
	private float dirtyHeight;
	private Vector3 positionBase = Vector3.zero;
	private int numberOfGrassPerTriangle = 2;
	private float minNormalY;
	
	// MeshesData lock
	private Object meshesDataLock = new Object();
	
	internal MeshData SrcMesh
	{
		set {
			srcMesh = value;
		}
	}
	internal int BuildId {
		get {
			return buildId;
		}
		set {
			buildId = value;
		}
	}
	internal Vector3 PositionBase {
		get {
			return positionBase;
		}
		set {
			positionBase = value;
		}
	}
	
	public void Update ()
	{
		if (meshesData != null) {
			lock (meshesDataLock)
			{
				for (int i=0; i < meshesData.Count && i < CHILDREN_COUNT; i++) {
					UpdateGrassObject (meshesData[i], i);
				}
				enabled = false;
			}
		}
	}
	
	/// <summary>
	/// Set new meshes to render grass.</summary>
	/// <param name="_meshesData"> Meshes to render.</param>
	public void ApplyGrass (List<MeshData> _meshesData)
	{
		lock (meshesDataLock)
		{
			meshesData = _meshesData;
		}
	}
	
	/// <summary>
	/// Generate grass on the chunk.</summary>
	/// <param name="threaded"> If true, grass generation will be done in a thread.</param>
	public void GenerateGrass (bool threaded = true)
	{
		if (srcMesh != null) {
			if (!threaded) {
				meshesData = GenerateGrassMesh();
				for (int i=0; i < meshesData.Count && i < CHILDREN_COUNT; i++) {
					UpdateGrassObject (meshesData[i], i);
				}
			} else {
				buildId++;
				threadManager.EnqueueForGeneratingGrass (this, this.buildId);
			}
		}
	}
	
	/// <summary>
	/// Clear grass on the chunk.</summary>
	/// <param name="disableGenerator"> If true, grass component will be disabled.</param>
	public void ClearGrass (bool disableGenerator = true)
	{
		for (int i=0; i < CHILDREN_COUNT; i++) {
			grassChildrenRenderer[i].enabled = false;
		}
		lock (meshesDataLock)
			meshesData = null;
		if (disableGenerator)
			enabled = false;
	}
	
	/// <summary>
	/// Clear grass on the chunk in the given area.</summary>
	/// <param name="hitPoint"> Center of the area in which the grass must be removed.</param>
	/// <param name="range"> Radius of the area in which the grass must be removed.</param>
	public void ClearGrassInRange (Vector3 hitPoint, float range)
	{
		hitPoint -= this.positionBase;
		float squaredRange = range * range;
		float d;
		
		lock (meshesDataLock) {
			if (meshesData != null) {
				for (int m=0; m < meshesData.Count; m++) {
					MeshData newMesh = new MeshData(1);
					MeshData oldMesh = meshesData[m];
					
					for (int sub=0; sub < oldMesh.GetSubMeshCount(); sub++) {
						List<int> indices = oldMesh.GetIndices(sub);
						for (int i=0; i < indices.Count; i+=3) {
							int i1 = indices[i+0];
							Vector3 p1 = oldMesh.vertices[i1];
							d = Vector3Utils.DistanceSquared(p1, hitPoint);
							if (d > squaredRange) {
								int i2 = indices[i+1];
								Vector3 p2 = oldMesh.vertices[i2];
								d = Vector3Utils.DistanceSquared(p2, hitPoint);
								if (d > squaredRange) {
									int i3 = indices[i+2];
									Vector3 p3 = oldMesh.vertices[i3];
									d = Vector3Utils.DistanceSquared(p3, hitPoint);
									if (d > squaredRange) {
										CopyIndex(i1, newMesh, oldMesh);
										CopyIndex(i2, newMesh, oldMesh);
										CopyIndex(i3, newMesh, oldMesh);
									}
								}
							}
						}
					}
					
					newMesh.PrepareArrays();
					meshesData[m] = newMesh;
					UpdateGrassObject (meshesData[m], m);
				}
			}
		}
	}
	
	/// <summary>
	/// Creates and initializes a new Grass Generator.</summary>
	/// <param name="map"> The map.</param>
	/// <param name="chunkData"> Chunk's data on which grass must be generated.</param>
	/// <param name="chunkTransform"> Chunk's transform on which grass must be generated.</param>
	internal static GrassGenerator CreateGrassGenerator(TerraMap map, ChunkData chunkData, Transform chunkTransform)
	{
		// Create game object
		GameObject go = new GameObject("ChunkGrass");
		
		// Add GrassGenerator component
		GrassGenerator grassGen = go.AddComponent<GrassGenerator>();
		
		// Init transform
		grassGen.chunkData = chunkData;
		grassGen.threadManager = ThreadManager.GetInstance (map);
		grassGen.cTransform = go.transform;
		grassGen.cTransform.parent = chunkTransform;
		grassGen.positionBase = chunkTransform.position;
		grassGen.cTransform.localRotation = Quaternion.identity;
		grassGen.cTransform.localScale = Vector3.one;
		grassGen.cTransform.localPosition = Vector3.zero;
		grassGen.material = map.grassMaterial;
		grassGen.tileX = map.grassTextureTileX;
		grassGen.baseColor = map.grassColor;
		grassGen.dirtyColor = map.grassDirtyColor;
		grassGen.baseHeight = map.grassHeight;
		grassGen.dirtyHeight = map.grassDirtyHeight;
		grassGen.numberOfGrassPerTriangle = map.grassDensity;
		grassGen.grassSize = map.grassSize;
		grassGen.minHeight = map.grassMinHeight;
		grassGen.minNormalY = Mathf.Cos(map.grassMaxSlopeAngle * Mathf.Deg2Rad);
		
		// Init children
		for (int i=0; i < CHILDREN_COUNT; i++) {
			grassGen.CreateGrassObject(i);
		}
		
		grassGen.enabled = false;
		
		return grassGen;
	}
	
	internal void CreateGrassObject(int index)
	{
		// Create game object
		GameObject go = new GameObject("Grass" + index);
		
		// Init transform
		go.transform.parent = this.cTransform;
		go.transform.localRotation = Quaternion.identity;
		go.transform.localScale = Vector3.one;
		go.transform.localPosition = Vector3.zero;
		
		MeshRenderer _renderer = go.AddComponent<MeshRenderer>();
		_renderer.sharedMaterial = this.material;
		_renderer.castShadows = this.castShadows;
		_renderer.receiveShadows = this.receiveShadows;
		MeshFilter _filter = go.AddComponent<MeshFilter>();
		
		_renderer.enabled = false;
		
		grassChildrenFilter.Add(_filter);
		grassChildrenRenderer.Add(_renderer);
	}
	
	private void UpdateGrassObject(MeshData meshData, int index)
	{
		MeshFilter _filter = grassChildrenFilter[index];
		_filter.sharedMesh = meshData.ToMesh (_filter.sharedMesh);
		grassChildrenRenderer[index].enabled = true;
	}
	
	public List<MeshData> GenerateGrassMesh()
	{
		if (srcMesh == null)
			return null;
		List<MeshData> meshes = new List<MeshData>();
		MeshData mesh = new MeshData (1);
		meshes.Add(mesh);
		
		for (int sub=0; sub < srcMesh.GetSubMeshCount(); sub++) {
			List<int> indices = srcMesh.GetIndices(sub);
			for (int i=0; i < indices.Count; i+=3) {
				// get the three vertices that make the faces
				int i1 = indices[i+0];
				int i2 = indices[i+1];
				int i3 = indices[i+2];
				Vector3 p1 = srcMesh.vertices[i1];
				Vector3 p2 = srcMesh.vertices[i2];
				Vector3 p3 = srcMesh.vertices[i3];
				
				Vector3 v1 = p2 - p1;
				Vector3 v2 = p3 - p1;
				Vector3 normal = Vector3.Cross( v1, v2 );
				normal.Normalize();
				
				if (normal.y > minNormalY && DistanceXZSquared(p1, p2) > MIN_DISTANCE_SQR_VERTICES
						&& DistanceXZSquared(p1, p3) > MIN_DISTANCE_SQR_VERTICES
						&& DistanceXZSquared(p2, p3) > MIN_DISTANCE_SQR_VERTICES)
				{
					// get block info
					Vector3i blockPos = Chunk.ToLocalPosition( new Vector3i(p1) );
					BlockData block = chunkData.GetBlock (blockPos);
					if (block == null || block.Block == null || !block.Block.IsVegetationEnabled)
						continue;
					
					// get normals
					Vector3 n1 = srcMesh.normals[i1];
					Vector3 n2 = srcMesh.normals[i2];
					Vector3 n3 = srcMesh.normals[i3];
					
					// world coordinates
					Vector3 pos1 = p1 + positionBase;
					
					// Height perlin noise
					float noise1 = Mathf.PerlinNoise(pos1.x * PERLIN_SCALE, pos1.z * PERLIN_SCALE) * PERLIN_COEF;
					
					// Compute height
					float minNY = normal.y;
					if (n1.y < minNY)
						minNY = n1.y;
					if (n2.y < minNY)
						minNY = n2.y;
					if (n3.y < minNY)
						minNY = n3.y;
					Vector3 vHeight = new Vector3( 0, minNY * baseHeight * noise1, 0 );
					if (vHeight.y < minHeight)
						continue;
					
					// Create new mesh if needed
					if (mesh.vertices.Count > MAX_VERTICES_PER_CHILD) {
						mesh = new MeshData (1);
						meshes.Add(mesh);
					}
					
					// Finally, create grass mesh
					
					if (numberOfGrassPerTriangle == 1) {
						// One grass per triangle
						Generate3BladesInPoly(mesh, i, p1, p2, p3, vHeight);
						
					} else if (numberOfGrassPerTriangle == 2) {
						// Two grass per triangle
						Vector3 mid;
						float d12 = (p1 - p2).magnitude;
						float d23 = (p2 - p3).magnitude;
						float d31 = (p3 - p1).magnitude;
						if (d12 > d23 && d12 > d31) {
							mid = (p1 + p2) * 0.5f;
							Generate3BladesInPoly(mesh, i, p1, mid, p3, vHeight);
							Generate3BladesInPoly(mesh, i, p2, mid, p3, vHeight);
						} else if (d23 > d12 && d23 > d31) {
							mid = (p2 + p3) * 0.5f;
							Generate3BladesInPoly(mesh, i, p2, mid, p1, vHeight);
							Generate3BladesInPoly(mesh, i, p3, mid, p1, vHeight);
						} else if (d31 > d23 && d31 > d12) {
							mid = (p3 + p1) * 0.5f;
							Generate3BladesInPoly(mesh, i, p3, mid, p2, vHeight);
							Generate3BladesInPoly(mesh, i, p1, mid, p2, vHeight);
						}
						
					} else {
						// Three grass per triangle
						Vector3 m12 = (p1 + p2) * 0.5f;
						Vector3 m23 = (p2 + p3) * 0.5f;
						Vector3 m31 = (p3 + p1) * 0.5f;
						Generate3BladesInPoly(mesh, i, p1, m12, m31, vHeight);
						Generate3BladesInPoly(mesh, i, p2, m23, m12, vHeight);
						Generate3BladesInPoly(mesh, i, p3, m31, m23, vHeight);
						Generate3BladesInPoly(mesh, i, m12, m23, m31, vHeight);
					}
					
				}
			}
		}
		
		// Precompute arrays from lists
		for (int i=0; i < meshes.Count; i++) {
			meshes[i].PrepareArrays();
		}
		
		if (meshes.Count > CHILDREN_COUNT) {
			Debug.LogWarning("[TerraVol] Grass generator generated too much meshes ("+meshes.Count+" instead of max "+CHILDREN_COUNT+")");
		}
		
		return meshes;
	}
	
	private void Generate12BladesInPoly(MeshData mesh, int index, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 vHeight)
	{
		int rand = random.Next(50);
		float irand = ((index % 2) * 2 - 1) * rand * 0.01f;
		bool rand1 = index % 2 == 0;
		bool rand2 = rand % 2 == 0;
		
		Vector3 m12 = (p1 + p2) * 0.5f;
		Vector3 m23 = (p2 + p3) * 0.5f;
		Vector3 m31 = (p3 + p1) * 0.5f;
		
		m12.x += 1.6f * irand;
		m12.z += 2.4f * irand;
		m23.x -= 1.8f * irand;
		m23.z -= 2.6f * irand;
		m31.x += 2.2f * irand;
		m31.z -= 1.3f * irand;
		
		Color wavingTint = Color.Lerp( dirtyColor, baseColor, vHeight.y - dirtyHeight );
		Color wavingTintAlpha = wavingTint;
		wavingTintAlpha.a = 1f;
		
		GenerateBladesAround (mesh, m12, vHeight, !rand1 && rand2, wavingTint, wavingTintAlpha);
		GenerateBladesAround (mesh, m23, vHeight, rand1 && rand2, wavingTint, wavingTintAlpha);
		GenerateBladesAround (mesh, m31, vHeight, !rand1 || rand2, wavingTint, wavingTintAlpha);
	}
	
	private void Generate3BladesInPoly(MeshData mesh, int index, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 vHeight)
	{
		float rand1 = (float)random.Next(1000) / 1000f;
		float rand2 = (float)random.Next(1000) / 1000f;
		float rand3 = 3f - rand1 - rand2;
		
		Vector3 m = (p1 * rand1 + p2 * rand2 + p3 * rand3) * 0.333333f;
		
		Color wavingTint = Color.Lerp( dirtyColor, baseColor, vHeight.y - dirtyHeight );
		Color wavingTintAlpha = wavingTint;
		wavingTintAlpha.a = 1f;
		
		GenerateBladesAround (mesh, m, vHeight, random.Next(100) < 50, wavingTint, wavingTintAlpha );
	}
	
	private void GenerateBladesAround(MeshData mesh, Vector3 c, Vector3 vHeight, bool type, Color wavingTint, Color wavingTintAlpha)
	{
		Vector3 v1,v2;
		c.y -= grassSize * TAN_ACOS_08 * 0.7f;
		
		if (type) {
			v1 = c;
			v1.z += 1f * grassSize;
			v2 = c;
			v2.x += COS_30 * grassSize;
			v2.z -= SIN_30 * grassSize;
			GenerateBlade (mesh, v1 + (v1-v2)*FACTOR, v2 + (v2-v1)*FACTOR, vHeight, wavingTint, wavingTintAlpha);
			
			v1 = c;
			v1.z += 1f * grassSize;
			v2 = c;
			v2.x -= COS_30 * grassSize;
			v2.z -= SIN_30 * grassSize;
			GenerateBlade (mesh, v1 + (v1-v2)*FACTOR, v2 + (v2-v1)*FACTOR, vHeight, wavingTint, wavingTintAlpha);
			
			v1 = c;
			v1.x += COS_30 * grassSize;
			v1.z -= SIN_30 * grassSize;
			v2 = c;
			v2.x -= COS_30 * grassSize;
			v2.z -= SIN_30 * grassSize;
			GenerateBlade (mesh, v1 + (v1-v2)*FACTOR, v2 + (v2-v1)*FACTOR, vHeight, wavingTint, wavingTintAlpha);
		} else {
			v1 = c;
			v1.z -= 1f * grassSize;
			v2 = c;
			v2.x += COS_30 * grassSize;
			v2.z += SIN_30 * grassSize;
			GenerateBlade (mesh, v1 + (v1-v2)*FACTOR, v2 + (v2-v1)*FACTOR, vHeight, wavingTint, wavingTintAlpha);
			
			v1 = c;
			v1.z -= 1f * grassSize;
			v2 = c;
			v2.x -= COS_30 * grassSize;
			v2.z += SIN_30 * grassSize;
			GenerateBlade (mesh, v1 + (v1-v2)*FACTOR, v2 + (v2-v1)*FACTOR, vHeight, wavingTint, wavingTintAlpha);
			
			v1 = c;
			v1.x += COS_30 * grassSize;
			v1.z += SIN_30 * grassSize;
			v2 = c;
			v2.x -= COS_30 * grassSize;
			v2.z += SIN_30 * grassSize;
			GenerateBlade (mesh, v1 + (v1-v2)*FACTOR, v2 + (v2-v1)*FACTOR, vHeight, wavingTint, wavingTintAlpha);
		}
	}
	
	private void GenerateBlade(MeshData mesh, Vector3 v1, Vector3 v2, Vector3 vHeight, Color wavingTint, Color wavingTintAlpha)
	{
		int indexBase = mesh.vertices.Count;
		Vector3 normal = Vector3.Cross( vHeight, v2 - v1 );
		normal.Normalize();
		mesh.vertices.Add( v1 );
		mesh.vertices.Add( v1 + vHeight + normal * 0.4f );
		mesh.vertices.Add( v2 + vHeight + normal * 0.4f );
		mesh.vertices.Add( v2 );
		mesh.normals.Add( Vector3.up );
		mesh.normals.Add( Vector3.up );
		mesh.normals.Add( Vector3.up );
		mesh.normals.Add( Vector3.up );
		mesh.uv.Add( new Vector2(0, 0) );
		mesh.uv.Add( new Vector2(0, 0.99f) );
		mesh.uv.Add( new Vector2(tileX, 0.99f) );
		mesh.uv.Add( new Vector2(tileX, 0) );
		List<int> indices = mesh.GetIndices(0);
		indices.Add(indexBase + 0);
		indices.Add(indexBase + 2);
		indices.Add(indexBase + 1);
		indices.Add(indexBase + 2);
		indices.Add(indexBase + 0);
		indices.Add(indexBase + 3);
		mesh.colors.Add( wavingTint );
		mesh.colors.Add( wavingTintAlpha );
		mesh.colors.Add( wavingTintAlpha );
		mesh.colors.Add( wavingTint );
		mesh.tangents.Add( new Vector4 (-1f, 0f, 0, 0) );
		mesh.tangents.Add( new Vector4 (-1f, 1f, 0, 0) );
		mesh.tangents.Add( new Vector4 ( 1f, 1f, 0, 0) );
		mesh.tangents.Add( new Vector4 ( 1f, 0f, 0, 0) );
	}
	
	private void CopyIndex(int index, MeshData newMesh, MeshData oldMesh)
	{
		int nIndex;
		if (!newMesh.edgeVertexCacheX.TryGetValue(index, out nIndex)) {
			nIndex = newMesh.vertices.Count;
			newMesh.edgeVertexCacheX.Add(index, nIndex);
			newMesh.vertices.Add( oldMesh.vertices[index] );
			newMesh.normals.Add( oldMesh.normals[index] );
			newMesh.uv.Add( oldMesh.uv[index] );
			newMesh.colors.Add( oldMesh.colors[index] );
			newMesh.tangents.Add( oldMesh.tangents[index] );
		}
		newMesh.GetIndices(0).Add( nIndex );
	}
	
	private static float DistanceXZSquared (Vector3 a, Vector3 b)
	{
		float dx = b.x - a.x;
		float dz = b.z - a.z;
		return dx * dx + dz * dz;
	}
	
}
