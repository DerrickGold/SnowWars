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
	/// Contains all data of a chunk (ie. voxels). It also provides some methods to find chunk's neighbours.</summary>
	public class ChunkData
	{
		
		private static int lastId = 0;
		private BlockData[][][] blocks;
		private BlockData[][] blocksPlanZ0;
		private BlockData[] blocksLineZ0Y0;
		
		private MeshData meshData = null;
		
		private int id = -1;
		private Vector3i position;
		private TerraMap map;
		private Chunk chunk;
		public ChunkData[] neighbours = new ChunkData[ 3 * 3 * 3 ];
		public bool harmonizeTwins = true;
		private bool isHarmonizable = false;
		private bool buildStarted = false;
		private MeshData meshDataTmp;
		public bool isFree = true;
		
		public bool useRTP3 = false;
		
		internal bool IsHarmonizable {
			get {
				return isHarmonizable;
			}
			set {
				isHarmonizable = value;
			}
		}
		internal bool BuildStarted {
			get {
				return buildStarted;
			}
			set {
				buildStarted = value;
			}
		}
		internal MeshData MeshDataTmp {
			get {
				return meshDataTmp;
			}
			set {
				meshDataTmp = value;
			}
		}
		public TerraMap TerraMap
		{
			get {
				return map;
			}
			set {
				map = value;
			}
		}
		public Chunk Chunk
		{
			get {
				return chunk;
			}
			set {
				chunk = value;
			}
		}
		public Vector3i Position
		{
			get {
				return position;
			}
			set {
				position = value;
			}
		}
		internal MeshData MeshData {
			get {
				return meshData;
			}
			set {
				meshData = value;
			}
		}
		
		[Obsolete("use TerraMap property instead.")]
		public TerraMap GetTerraMap ()
		{
			return map;
		}
		
		[Obsolete("use Position property instead.")]
		public Vector3i GetPosition ()
		{
			return position;
		}
		
		/// <summary>
		/// Create a new chunk-data.</summary>
		/// <param name="map"> The map.</param>
		/// <param name="position"> Position of the chunk in chunk's unit.</param>
		public ChunkData (TerraMap map, Vector3i position)
		{
			this.map = map;
			this.position = position;
			this.id = lastId++;
			this.isFree = false;
			
			blocks = new BlockData[Chunk.SIZE_X][][];
			blocksPlanZ0 = new BlockData[Chunk.SIZE_X][];
			blocksLineZ0Y0 = new BlockData[Chunk.SIZE_X];
			for(int x=0; x<Chunk.SIZE_X; x++) {
				blocks[x] = new BlockData[Chunk.SIZE_Y][];
				blocksPlanZ0[x] = new BlockData[Chunk.SIZE_Y];
				for(int y=0; y<Chunk.SIZE_Y; y++) {
					blocks[x][y] = new BlockData[Chunk.SIZE_Z];
				}
			}

		}
		
		/// <summary>
		/// Find all neighbours of this chunk and store them in an array.</summary>
		public void FindNeighbours ()
		{
			// Find neighbours
			foreach (Vector3i dir in Vector3i.allDirections) {
				ChunkData n = map.GetChunkData (position + dir);
				neighbours [(dir.x + 1) + (dir.y + 1)*3 + (dir.z + 1)*9] = n;
				if (n != null) {
					n.neighbours [(-dir.x + 1) + (-dir.y + 1)*3 + (-dir.z + 1)*9] = this;
				}
			}
		}
		
		/// <summary>
		/// Clear neighbours array.</summary>
		public void ClearNeighbours ()
		{
			// Find neighbours
			for (int x=-1; x<=1; x++) {
				for (int y=-1; y<=1; y++) {
					for (int z=-1; z<=1; z++) {
						ChunkData neighbour = GetNeighbour (x, y, z);
						if (neighbour != null) {
							neighbour.UnsetNeighbour (-x, -y, -z);
							this.UnsetNeighbour (x, y, z);
						}
					}
				}
			}
		}
		
		/// <summary>
		/// Remove a neighbour from the chunk at the given direction.</summary>
		public void UnsetNeighbour (int x, int y, int z)
		{
			neighbours [(x + 1) + (y + 1)*3 + (z + 1)*9] = null;
		}

		/// <summary>
		/// Returns the neighbour of this chunk at the given direction.</summary>
		public ChunkData GetNeighbour (int x, int y, int z)
		{
			return neighbours [(x + 1) + (y + 1)*3 + (z + 1)*9];
		}
		
		/// <summary>
		/// Returns the neighbour of this chunk at the given direction.</summary>
		public ChunkData GetNeighbour (Vector3i dir)
		{
			return neighbours [(dir.x + 1) + (dir.y + 1)*3 + (dir.z + 1)*9];
		}
		
		/// <summary>
		/// Returns the neighbour of this chunk at the given direction. Create it if it doesn't exist.</summary>
		public ChunkData GetNeighbourInstance (Vector3i dir)
		{
			ChunkData n = neighbours [(dir.x + 1) + (dir.y + 1)*3 + (dir.z + 1)*9];
			if (n == null) {
				n = map.GetChunkDataInstance(this.position + dir);
			}
			return n;
		}
		
		public override bool Equals (object other)
		{
			if (!(other is ChunkData))
				return false;
			ChunkData c = (ChunkData)other;
			return id == c.id;
		}
		
		public override int GetHashCode ()
		{
			return id;
		}
		
		/// <summary>
		/// Get the chunk component. Create it if needed.</summary>
		public Chunk GetChunkInstance ()
		{
			if (chunk == null)
				chunk = Chunk.CreateChunk (position, map, this);
			return chunk;
		}
		
		/// <summary>
		/// Replace block at the given position.</summary>
		/// <param name="block"> The block to put at the given position.</param>
		/// <param name="pos"> Local position of the block in block's unit.</param>
		public void SetBlock (float isovalue, Block block, Vector3i pos)
		{
			this.SetBlock( isovalue, block, pos.x, pos.y, pos.z );
		}
		
		/// <summary>
		/// Replace block at the given position.</summary>
		/// <param name="block"> The block to put at the given position.</param>
		/// <param name="x"> X coordinate of local position of the block in block's unit.</param>
		/// <param name="y"> Y coordinate of local position of the block in block's unit.</param>
		/// <param name="z"> Z coordinate of local position of the block in block's unit.</param>
		public void SetBlock (float isovalue, Block block, int x, int y, int z)
		{
			BlockData blockData = blocks[x][y][z];
			if (blockData != null) {
				blockData.Isovalue = isovalue;
				blockData.Block = block;
			} else {
				blockData = BlockPool.Get(block, new Vector3i(x, y, z), isovalue);
				blocks[x][y][z] = blockData;
				if (z == 0) {
					blocksPlanZ0[x][y] = blockData;
					if (y == 0) {
						blocksLineZ0Y0[x] = blockData;
					}
				}
			}
		}

		/// <summary>
		/// Nullify block at the given position.</summary>
		/// <param name="x"> X coordinate of local position of the block in block's unit.</param>
		/// <param name="y"> Y coordinate of local position of the block in block's unit.</param>
		/// <param name="z"> Z coordinate of local position of the block in block's unit.</param>
		public void NullifyBlock (Vector3i p)
		{
			BlockData block = blocks[p.x][p.y][p.z];
			if (block != null) {
				BlockPool.Free(block);
				blocks[p.x][p.y][p.z] = null;
				if (p.z == 0) {
					blocksPlanZ0[p.x][p.y] = null;
					if (p.y == 0) {
						blocksLineZ0Y0[p.x] = null;
					}
				}
			}
		}

		/// <summary>
		/// Clears all blocks of this chunk.</summary>
		public void ClearBlocks()
		{
			for (int x=0; x < Chunk.SIZE_X; ++x) {
				for (int y=0; y < Chunk.SIZE_Y; ++y) {
					for (int z=0; z < Chunk.SIZE_Z; ++z) {
						NullifyBlock(new Vector3i(x, y, z));
					}
				}
			}
		}
		
		/// <summary>
		/// Returns block at the given position.</summary>
		/// <param name="pos"> Local position of the block in block's unit.</param>
		public BlockData GetBlock (Vector3i pos)
		{
			return blocks [pos.x] [pos.y] [pos.z];
		}
		
		/// <summary>
		/// Returns block at the given position.</summary>
		/// <param name="x"> X coordinate of local position of the block in block's unit.</param>
		/// <param name="y"> Y coordinate of local position of the block in block's unit.</param>
		/// <param name="z"> Z coordinate of local position of the block in block's unit.</param>
		public BlockData GetBlock (int x, int y, int z)
		{
			return blocks [x] [y] [z];
		}
		
		public BlockData[][] GetBlocksXPlan(int x) {
			return blocks[x];
		}
		public BlockData[] GetBlocksXYLine(int x, int y) {
			return blocks[x][y];
		}
		public BlockData[][] GetBlocksPlanZ0(int z) {
			return blocksPlanZ0;
		}
		public BlockData GetBlockInPlanZ0(int x, int y) {
			return blocksPlanZ0[x][y];
		}
		public BlockData[] GetBlocksXLineInPlanZ0(int x) {
			return blocksPlanZ0[x];
		}
		public BlockData GetBlockInLineZ0Y0(int x) {
			return blocksLineZ0Y0[x];
		}
		
		/// <summary>
		/// Returns block at the given position, safely handling blocks which are actually in a neighbour of this chunk.</summary>
		/// <param name="localPosition"> Local position of the block in block's unit. Can be lower than 0 or greater than Chunk.SIZE_X/Y/Z</param>
		internal BlockData GetBlockSafeNeighbours(Vector3i localPosition)
        {
			ChunkData chunk = this;
			Vector3i dir = Vector3i.zero;
			if (localPosition.x < 0) dir.x = -1;
			else if (localPosition.x >= Chunk.SIZE_X) dir.x = 1;
			if (localPosition.y < 0) dir.y = -1;
			else if (localPosition.y >= Chunk.SIZE_Y) dir.y = 1;
			if (localPosition.z < 0) dir.z = -1;
			else if (localPosition.z >= Chunk.SIZE_Z) dir.z = 1;
			if (dir != Vector3i.zero) {
				chunk = GetNeighbour( dir );
				localPosition = Chunk.ToLocalPosition( localPosition );
			}
			if (chunk != null) {
				return chunk.GetBlock( localPosition );
			}
			return null;
		}
		
		/// <summary>
		/// A* Checks if a position is free or marked (and legal). This method can search in neighbours if needed.</summary>
		/// <param name="localPosition"> Local position of the block in block's unit. Can be lower than 0 or greater than Chunk.SIZE_X/Y/Z</param>
		/// <param name="aboveGroundOnly"> Should the path be above the ground or can it be in the air?</param>
        internal bool PositionIsFree(Vector3i localPosition, bool aboveGroundOnly)
        {
			BlockData block = GetBlockSafeNeighbours(localPosition);
			
			if (block != null) {				
				if (!aboveGroundOnly) {
				
					return block != null && !block.IsInside && !block.IsPathBlocked;
					
				} else if (block != null && !block.IsInside && !block.IsPathBlocked) {
				
					for (int y=-1; y >= -1; y--) {
						Vector3i localPositionb = localPosition;
						localPositionb.y += y;
						BlockData blockb = GetBlockSafeNeighbours(localPositionb);
						if (blockb != null && blockb.IsInside)
							return true;
					}
					
				}
			}
			return false;
        }
	}
	
}