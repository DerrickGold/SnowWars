// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;

namespace TerraVol
{
	/// <summary>
	/// Handles generation of a column of voxels using Perlin noise.</summary>
	/// <remarks>
	/// It usually can be used in threads.</remarks>
	internal class TerrainGenerator
	{
		
		public static readonly int GROUND_LEVEL = Chunk.SIZE_Y * 1;
		public static readonly int WATER_LEVEL = 0;
		public static readonly int DISTANCE_BORDER_REDUCE = 2 * Chunk.SIZE_X;
		private PerlinNoise2D noise1;
		private PerlinNoise2D noise2;
		private PerlinNoise3D noise3d;
		private TerraMap map;
		private TerraMapGenerator mapGenerator;
		private Block defaultBlock;
		private float roughness;
		public bool useHeightmap;
		
		// Random
		System.Random random = new System.Random();
		
		/// <summary>
		/// Create a new terrain generator. Initialize its Perlin noise.</summary>
		/// <param name="map"> The map.</param>
		/// <param name="mapGenerator"> The map generator.</param>
		public TerrainGenerator (TerraMap map, TerraMapGenerator mapGenerator)
		{
			this.map = map;
			this.mapGenerator = mapGenerator;
			BlockSet blockSet = map.GetBlockSet ();
			this.roughness = mapGenerator.roughness / 100f;
			this.useHeightmap = map.heightmap != null;
			
			defaultBlock = blockSet.GetBlock ("Default");
			
			if (defaultBlock == null) {
				Debug.LogError ("[TerraVol] A 'Default' block must be defined in the BlockSet.");
				throw new UnityException ();
			}
			
			noise1 = new PerlinNoise2D (1 / (5f * mapGenerator.granularity), mapGenerator.randomize, WorldRecorder.Instance.Noise2dRandomValues[0]).SetOctaves (5);
			noise2 = new PerlinNoise2D (1 / (5f * mapGenerator.granularity), mapGenerator.randomize, WorldRecorder.Instance.Noise2dRandomValues[1]).SetOctaves (2);
			noise3d = new PerlinNoise3D (1 / mapGenerator.granularity, mapGenerator.randomize, WorldRecorder.Instance.Noise3dRandomValues);
			WorldRecorder.Instance.Noise2dRandomValues[0] = noise1.Offset;
			WorldRecorder.Instance.Noise2dRandomValues[1] = noise2.Offset;
			WorldRecorder.Instance.Noise3dRandomValues = noise3d.RandVals;
		}
		
		/// <summary>
		/// Generate a column of voxels.</summary>
		/// <param name="chunk2D"> The column to generate.</param>
		public void Generate (Chunk2D chunk2D)
		{
			if (useHeightmap) {
				GenerateFromHeightMap(chunk2D, map.heightmap);
			} else {
				GenerateProcedurally (chunk2D);
			}
		}
		
		/// <summary>
		/// Generate a column of voxels using Perlin Noise.</summary>
		/// <param name="chunk2D"> The column to generate.</param>
		public void GenerateProcedurally (Chunk2D chunk2D)
		{
			int cx = chunk2D.position.x;
			int cz = chunk2D.position.y;
			bool atLimit = cx <= map.minGX || cz <= map.minGZ || cx >= map.maxGX || cz >= map.maxGZ;
			float ground = WATER_LEVEL - 2;
			float underground = map.minY * Chunk.SIZE_Y;
			
			for (int z=0; z<Chunk.SIZE_Z; z++) {
				for (int x=0; x<Chunk.SIZE_X; x++) {
					int worldX = cx * Chunk.SIZE_X + x;
					int worldZ = cz * Chunk.SIZE_Z + z;
					
					if (!map.limitSize || !atLimit)
					{
						float h1 = noise1.Noise (worldX, worldZ) * mapGenerator.HeightCoefOfHills;
						h1 = Mathf.Clamp (Mathf.Abs (h1), mapGenerator.MinHeightOfGround, mapGenerator.MaxHeightOfHills);
						
						float h2 = noise2.Noise (worldX, worldZ) * mapGenerator.HeightCoefOfCliffs;
						h2 = Mathf.Clamp (h2, 0f, mapGenerator.MaxHeightOfCliffsAboveHills);
						h2 += h1;
						
						int deep = 0;
						int worldY = map.Chunks.MaxY * Chunk.SIZE_Y;
						int worldYStart = (int)h2 + Chunk.SIZE_Y * 4;
						
						// Reset top blocks
						if (worldY > worldYStart) {
							for(; worldY > worldYStart; worldY--) {
								NullifyBlock (worldX, worldY, worldZ);
							}
						} else {
							worldY = worldYStart;
						}
						
						// Collines
						for (; worldY > h1; worldY--) {
							float isovalue = noise3d.Noise (worldX, worldY, worldZ);
							if (worldY > h2) {
								isovalue += Mathf.Pow (worldY - h2, 1.2f) * 0.05f;
							}
							
							if (roughness != 0 && Rand(-1f, 1f) < 0) {
								isovalue += Rand(Mathf.Clamp(Mathf.Sin(x+z), -roughness, 0f), roughness/4f);
							}
							
							if (isovalue < 0f)
								deep++;
							else
								deep = 0;

							if (isovalue < 1f) {
								isovalue = Mathf.Clamp (isovalue, -1.0f, 1.0f);
								GenerateBlock (worldX, worldY, worldZ, deep, isovalue);
							} else {
								NullifyBlock (worldX, worldY, worldZ);
							}
						}
						
						// Sol
						for (; worldY >= ground; worldY--) {
							float isovalue = noise3d.Noise (worldX, worldY, worldZ);
		
							isovalue -= Mathf.Pow (h1 - worldY, 1.5f) * 0.01f;
							
							if (roughness != 0 && Rand(-1f, 1f) < 0) {
								isovalue += Rand(Mathf.Clamp(Mathf.Sin(x+z), -roughness, 0f), roughness/4f);
							}
							
							if (isovalue < 0f)
								deep++;
							else
								deep = 0;

							if (isovalue < 1f) {
								isovalue = Mathf.Clamp (isovalue, -1.0f, 1.0f);
								GenerateBlock (worldX, worldY, worldZ, deep, isovalue);
							} else {
								NullifyBlock (worldX, worldY, worldZ);
							}
						}
						
						// Sous-sol
						for (; worldY >= underground; worldY--) {
							deep++;
							GenerateBlock (worldX, worldY, worldZ, deep, -1.0f);
						}
					}
				}
			}
			
			// Restore player actions
			if (!map.limitSize || !atLimit)
				WorldRecorder.Instance.RestoreColumn(cx, cz);
		}
		
		/// <summary>
		/// Generate a column of voxels using a hieghtmap.</summary>
		/// <param name="chunk2D"> The column to generate.</param>
		/// <param name="heightmap"> The heightmap.</param>
		public void GenerateFromHeightMap(Chunk2D chunk2D, Texture2D heightmap)
		{
			int cx = chunk2D.position.x;
			int cz = chunk2D.position.y;
			
			float height = (map.maxYForheightmap - map.minY) * Chunk.SIZE_Y;
			float fx = heightmap.width / ((map.maxX - map.minX) * Chunk.SIZE_X);
			float fz = heightmap.height / ((map.maxZ - map.minZ) * Chunk.SIZE_Z);
			for (int z=0; z<Chunk.SIZE_Z; z++) {
				for (int x=0; x<Chunk.SIZE_X; x++) {
					int worldX = cx * Chunk.SIZE_X + x;
					int worldZ = cz * Chunk.SIZE_Z + z;
					int deep = 0;
					
					float currentPixelColor = heightmap.GetPixel((int)((worldX-map.minX*Chunk.SIZE_X) * fx), (int)((worldZ-map.minZ*Chunk.SIZE_Z) * fz)).r;
					
					for (int y=map.minY * Chunk.SIZE_Y; y<=map.maxYForheightmap * Chunk.SIZE_Y; y++) {
						float isovalue = (float)y / height - currentPixelColor;
						if (isovalue < 0f)
							deep++;
						isovalue = Mathf.Clamp (isovalue, -1.0f, 1.0f);
						GenerateBlock (worldX, y, worldZ, deep, isovalue);
					}
				}
			}
		}
		
		/// <summary>
		/// Set voxel data at given position.</summary>
		/// <param name="worldX"> X coordinate of absolute position of the block in block's unit.</param>
		/// <param name="worldY"> Y coordinate of absolute position of the block in block's unit.</param>
		/// <param name="worldZ"> Z coordinate of absolute position of the block in block's unit.</param>
		/// <param name="deep"> Deepness of the block (how deep in the ground it is). Can be useful to determine which type of block to use.</param>
		/// <param name="isovalue"> Isovalue of the block.</param>
		private void GenerateBlock (int worldX, int worldY, int worldZ, int deep, float isovalue)
		{
			Block block = GetBlock (worldX, worldY, worldZ, deep);
			if (block != null) {
				map.SetBlock (isovalue, block, worldX, worldY, worldZ);
			}
		}

		/// <summary>
		/// Nullify voxel data at given position.</summary>
		/// <param name="worldX"> X coordinate of absolute position of the block in block's unit.</param>
		/// <param name="worldY"> Y coordinate of absolute position of the block in block's unit.</param>
		/// <param name="worldZ"> Z coordinate of absolute position of the block in block's unit.</param>
		private void NullifyBlock (int worldX, int worldY, int worldZ)
		{
			map.NullifyBlock (worldX, worldY, worldZ);
		}
		
		/// <summary>
		/// Get type of block depending on its position and deepness.</summary>
		/// <param name="worldX"> X coordinate of absolute position of the block in block's unit.</param>
		/// <param name="worldY"> Y coordinate of absolute position of the block in block's unit.</param>
		/// <param name="worldZ"> Z coordinate of absolute position of the block in block's unit.</param>
		/// <param name="deep"> Deepness of the block (how deep in the ground it is). Can be useful to determine which type of block to use.</param>
		/// <returns> Type of block.</returns>
		private Block GetBlock (int worldX, int worldY, int worldZ, int deep)
		{
			if (map.terraVolEnhance != null) {
				Block block = map.terraVolEnhance.OnBlockGenerateBeforeInThread (new Vector3i (worldX, worldY, worldZ));
				if (block != null)
					return block;
			}
			return defaultBlock;
		}
		
		private float Rand(float a, float b)
		{
			float r;
			lock (random)
				r = (float)random.NextDouble();
			return r * (b-a) - b;
		}
		
	}
	
}