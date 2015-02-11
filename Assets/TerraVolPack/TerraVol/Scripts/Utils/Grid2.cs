// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	/// <summary>
	/// Store data in a dictionary representing a virtual 2D grid.</summary>
	internal class Grid2
	{
		
		private Dictionary<Vector2i, Chunk2D> grid;
		private TerraMap map;
		
		private int minX;
		public int MinX {
			get { return minX; }
		}
		
		private int minZ;
		public int MinZ {
			get { return minZ; }
		}
		
		private int maxX;
		public int MaxX {
			get { return maxX; }
		}
		
		private int maxZ;
		public int MaxZ {
			get { return maxZ; }
		}
		
		
		public Grid2 (TerraMap map)
		{
			this.map = map;
			this.minX = 0;
			this.minZ = 0;
			
			this.maxX = 0;
			this.maxZ = 0;
			
			grid = new Dictionary<Vector2i, Chunk2D>(new Vector2iComparer());
		}
		
		public Chunk2D GetCreate (Vector2i pos)
		{
			lock (grid)
			{
				Chunk2D obj;
				if (!grid.TryGetValue(pos, out obj)) {
					obj = new Chunk2D(pos);
					grid.Add(pos, obj);
					updateMinMax(pos.x, pos.y);
				}
				return obj;
			}
		}
		
		public Chunk2D SafeGet (Vector2i pos)
		{
			return SafeGet(pos.x, pos.y);
		}

		public Chunk2D SafeGet (int x, int z)
		{
			lock (grid)
			{
				Chunk2D obj;
				if (grid.TryGetValue(new Vector2i(x, z), out obj))
					return obj;
			}
			return null;
		}
		
		public Vector2i GetMin ()
		{
			return new Vector2i (minX, minZ);
		}
		
		public Vector2i GetMax ()
		{
			return new Vector2i (maxX, maxZ);
		}
		
		private void updateMinMax(int x, int z)
		{
			if (x < minX)
				minX = x;
			else if (x > maxX)
				maxX = x;
				
			if (z < minZ)
				minZ = z;
			else if (z > maxZ)
				maxZ = z;
		}

		public void FreeChunks2D(int cx, int cz, int distance, Grid3 grid3)
		{
			List<Vector2i> keysToRemove = new List<Vector2i>();
			lock (grid)
			{
				foreach (Chunk2D chunk2D in grid.Values) {
					int px = chunk2D.position.x - cx;
					int py = chunk2D.position.y - cz;
					if ((px^(px>>31))-(px>>31) > distance ||
					    (py^(py>>31))-(py>>31) > distance)
					{
						keysToRemove.Add(chunk2D.position);
						if (keysToRemove.Count == 8)
							break;
					}
				}
				for (int i=0; i<keysToRemove.Count; ++i) {
					grid.Remove(keysToRemove[i]);
				}
			}
			for (int i=0; i<keysToRemove.Count; ++i) {
				grid3.FreeColumn(keysToRemove[i]);
			}
		}

		public void BuildChunks2D(int cx, int cz, int distance, Grid3 grid3, TerrainGenerator terrainGenerator, ThreadManager threadManager, bool threaded)
		{
			lock (grid)
			{
				foreach (Chunk2D chunk2D in grid.Values) {
					if (!chunk2D.built && !chunk2D.building &&
					    (!map.limitSize || (chunk2D.position.x >= map.minGX || chunk2D.position.x <= map.maxGX || chunk2D.position.y >= map.minGZ || chunk2D.position.y <= map.maxGZ)) &&
						(Mathf.Abs(chunk2D.position.x - cx) > distance ||
					     Mathf.Abs(chunk2D.position.y - cz) > distance))
					{
						if (threaded) {
							chunk2D.built = true;
							chunk2D.building = true;
							map.BuildColumn (chunk2D.position.x, chunk2D.position.y);
						} else {
							chunk2D.built = true;
							chunk2D.building = false;
							map.BuildColumnImmediately (chunk2D.position.x, chunk2D.position.y);
						}
					}
				}
			}
		}
		
	}
	
}