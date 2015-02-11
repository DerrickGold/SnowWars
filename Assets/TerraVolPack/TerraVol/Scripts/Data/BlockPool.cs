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
	/// Pool of blocks data.</summary>
	public static class BlockPool
	{
		const int INITIAL_SIZE = 1000000;
		private static Queue<BlockData> blocks;
		private static object sync = new object();

		public static void Init(Block block)
		{
			blocks = new Queue<BlockData>(INITIAL_SIZE);
			for (int i=0; i < INITIAL_SIZE; ++i) {
				blocks.Enqueue(new BlockData(block, Vector3i.zero, 1f));
			}
		}
		
		public static BlockData Get(Block block, Vector3i position, float isovalue)
		{
			lock (sync)
			{
				if (blocks.Count != 0) {
					BlockData blockData = blocks.Dequeue();
					blockData.Block = block;
					blockData.Isovalue = isovalue;
					blockData.Position = position;
					return blockData;
				} else {
					return new BlockData(block, position, isovalue);
				}
			}
		}
		
		public static void Free(BlockData block)
		{
			block.Isovalue = 1f;
			lock (sync)
			{
				blocks.Enqueue(block);
			}
		}
	}
	
}