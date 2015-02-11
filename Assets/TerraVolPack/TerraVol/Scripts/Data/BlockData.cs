// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;
using System;

namespace TerraVol
{
	/// <summary>
	/// This class contains all data of a block (ie. voxel).</summary>
	public class BlockData
	{
		private Block block;
		public string blockName;
		private float isovalue;
		private bool isInside;
		private bool isDestructible;
		private Vector3i position;
		private bool isPathBlocked;
		
		/// <summary>
		/// Create a new block.</summary>
		/// <param name="block"> Type of block of this block.</param>
		/// <param name="position"> Local position of the block in its chunk (in block's unit).</param>
		/// <param name="isovalue"> Isovalue of the block. Isovalue must be in range [-1;1]. 
		/// Negative isovalue means block is inside the terrain while positive isovalue means it is outside.</param>
		public BlockData (Block block, Vector3i position, float isovalue)
		{
			this.block = block;
			this.blockName = null; // value will be set just before save
			this.isovalue = isovalue;
			this.isInside = isovalue < 0.0f;
			this.isDestructible = block.IsDestructible;
			this.position = position;
			this.isPathBlocked = false;
		}
		
		/// <summary>
		/// Isovalue of the block. Isovalue must be in range [-1;1]. 
		/// Negative isovalue means block is inside the terrain while positive isovalue means it is outside.</summary>
		internal float Isovalue
		{
			get {
				return isovalue;
			}
			set {
				isovalue = Mathf.Clamp (value, -1.0f, 1.0f);
				isInside = isovalue < 0.0f;
			}
		}
		
		/// <summary>
		/// Type of block of this block.</summary>
		internal Block Block
		{
			get {
				return block;
			}
			set {
				block = value;
				isDestructible = block.IsDestructible;
			}
		}
		
		/// <summary>
		/// Is path blocked on this block? Used by pathfinder.</summary>
		internal bool IsPathBlocked
		{
			get {
				return isPathBlocked;
			}
			set {
				isPathBlocked = value;
			}
		}
		
		/// <summary>
		/// Local position of the block in its chunk (in block's unit).</summary>
		internal Vector3i Position
		{
			get {
				return position;
			}
			set {
				position = value;
			}
		}
		
		/// <summary>
		/// Is this block inside or outside the terrain?</summary>
		internal bool IsInside
		{
			get {
				return isInside;
			}
		}
		
		/// <summary>
		/// Is this block destructible?</summary>
		internal bool IsDestructible
		{
			get {
				return isDestructible;
			}
		}
		
		/// <summary>
		/// Set type of block of this block using type name.</summary>
		/// <param name="blockSet"> Block set containing types of block.</param>
		internal void SetBlockFromName (BlockSet blockSet)
		{
			if (!System.String.IsNullOrEmpty(blockName)) {
				this.block = blockSet.GetBlock (blockName);
			} else {
				this.block = blockSet.GetBlock ("Default");
			}
			if (this.block != null)
				this.isDestructible = this.block.IsDestructible;
		}
		
		[Obsolete("use Block property instead.")]
		public void SetBlock (Block block)
		{
			this.block = block;
			this.isDestructible = block.IsDestructible;
		}
		
		[Obsolete("use Block property instead.")]
		public Block GetBlock ()
		{
			return block;
		}
		
		[Obsolete("use Isovalue property instead.")]
		internal float GetIsovalue ()
		{
			return isovalue;
		}
		
		/// <summary>
		/// Set isovalue of a block.</summary>
		/// <param name="blockData"> The block.</param>
		/// <param name="chunk"> Chunk of this block.</param>
		/// <param name="iso"> New isovalue of the block.</param>
		/// <param name="blockType"> Type of block.</param>
		/// <param name="isPathBlocked"> Should this block prevent pathfinder from passing here.</param>
		internal static void SetIsovalue(BlockData blockData, ChunkData chunk, float iso, Block blockType, bool isPathBlocked)
		{
			lock (blockData)
			{
				blockData.Block = blockType;
				blockData.Isovalue = iso;
				blockData.IsPathBlocked = isPathBlocked;
			}
		}
		
		/// <summary>
		/// Add isovalue to a block.</summary>
		/// <param name="blockData"> The block.</param>
		/// <param name="chunk"> Chunk of this block.</param>
		/// <param name="iso"> New isovalue of the block.</param>
		/// <param name="blockType"> Type of block.</param>
		/// <param name="isPathBlocked"> Should this block prevent pathfinder from passing here.</param>
		internal static void AddIsovalue(BlockData blockData, ChunkData chunk, float iso, Block blockType, bool isPathBlocked)
		{
			lock (blockData)
			{
				blockData.Block = blockType;
				blockData.Isovalue += iso;
				blockData.IsPathBlocked = isPathBlocked;
			}
		}
		
		[Obsolete("use BlockData.AddIsovalue instead.")]
		internal bool AddToIsovalue (float iso, bool force = false)
		{
			if (!force && !isDestructible && iso > 0)
				return false;
			
			this.isovalue += iso;
			this.isovalue = Mathf.Clamp (this.isovalue, -1.0f, 1.0f);
			this.isInside = this.isovalue < 0.0f;
			return true;
		}
		
		[Obsolete("use Position property instead.")]
		public Vector3i GetPosition ()
		{
			return position;
		}
	}
	
}