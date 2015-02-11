// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	/// <summary>
	/// Pool of chunks.</summary>
	public static class ChunkPool
	{
		const int INITIAL_SIZE = 4096;
		private static Queue<ChunkData> chunks;
		private static object sync = new object();

		public static void Init(TerraMap map)
		{
			chunks = new Queue<ChunkData>(INITIAL_SIZE);
			for (int i=0; i < INITIAL_SIZE; ++i) {
				ChunkData chunkData = new ChunkData(map, Vector3i.zero);
				// As Init is called from the main thread, we can initiate the chunk components 
				chunkData.GetChunkInstance();
				chunks.Enqueue(chunkData);
			}
		}
		
		public static ChunkData Get(TerraMap map, Vector3i pos)
		{
			lock (sync)
			{
				if (chunks.Count != 0) {
					ChunkData chunk = chunks.Dequeue();
					chunk.isFree = false;
					chunk.Position = pos;
					chunk.ClearBlocks();
					return chunk;
				} else {
					return new ChunkData(map, pos);
				}
			}
		}
		
		public static void Free(ChunkData chunk)
		{
			chunk.isFree = true;
			chunk.MeshData = null;
			chunk.MeshDataTmp = null;
			chunk.ClearNeighbours();
			if (chunk.Chunk != null) {
				chunk.Chunk.Display(false);
			}
			lock (sync)
			{
				chunks.Enqueue(chunk);
			}
		}
	}
	
}