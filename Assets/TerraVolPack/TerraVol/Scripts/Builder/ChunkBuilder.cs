// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	/// <summary>
	/// This class handles building logic of chunks.</summary>
	internal class ChunkBuilder
	{
		private MarchingCubes marchingCubes;
		public static int subMeshCount;
		
		private BlockData[] lineX0Y0;
		private BlockData[] lineX0Y1;
		
		private BlockData[] lineX1Y0;
		private BlockData[] lineX1Y1;
		
		private BlockData[] lineX0ZP;
		private BlockData[] lineX1ZP;
		
		private ChunkData neighbourXP;
		private ChunkData neighbourYP;
		private ChunkData neighbourZP;
		private ChunkData neighbourXPZP;
		private ChunkData neighbourXPYP;
		private ChunkData neighbourYPZP;
		private ChunkData neighbourXPYPZP;
		
		private Vector3i[] gridPos = null;
		
		// Instance to be used on the main thread only
		private static ChunkBuilder mainThreadInstance = null;
		
		public static ChunkBuilder getMainThreadInstance() {
			if (mainThreadInstance == null)
				mainThreadInstance = new ChunkBuilder();
			return mainThreadInstance;
		}
		
		/// <summary>
		/// Must be called at map initialization.</summary>
		public static void Init (int _subMeshCount)
		{
			subMeshCount = _subMeshCount;
		}
		
		/// <summary>
		/// Create a new chunk builder.</summary>
		public ChunkBuilder ()
		{
			marchingCubes = new MarchingCubes();
		}
		
		/// <summary>
		/// Build the chunk (ie. polygonize it).</summary>
		/// <param name="chunk"> The chunk to build.</param>
		/// <returns> Result of polygonization as mesh data.</returns>
		public MeshData BuildChunk (ChunkData chunk)
		{
			MeshData meshData = new MeshData (subMeshCount);
			Build (chunk, meshData);
			return meshData;
		}
		
		
		private void Build(ChunkData chunk, MeshData meshData)
		{
			
			// Get neighbours
			neighbourXP = chunk.GetNeighbour( 1, 0, 0 );
			neighbourYP = chunk.GetNeighbour( 0, 1, 0 );
			neighbourZP = chunk.GetNeighbour( 0, 0, 1 );
			neighbourXPZP = chunk.GetNeighbour( 1, 0, 1 );
			neighbourYPZP = chunk.GetNeighbour( 0, 1, 1 );
			neighbourXPYP = chunk.GetNeighbour( 1, 1, 0 );
			neighbourXPYPZP = chunk.GetNeighbour( 1, 1, 1 );
			
			gridPos = MarchingCubesTables.gridPos;	
			
			
			// Iterate through X XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			for(int x=0; x<Chunk.SIZE_X; x++) {
				bool positiveBorderX = x == Chunk.SIZE_X-1;
				bool negativeBorderX = x == 0;
				
				// Get X plans (x and x+1) handling neighbours
				BlockData[][] planX0 = chunk.GetBlocksXPlan( x );
				BlockData[][] planX1 = null;
				lineX0ZP = null;
				lineX1ZP = null;
				
				// lineX0ZP & lineXHZP
				if (neighbourZP != null) {
					lineX0ZP = neighbourZP.GetBlocksXLineInPlanZ0( x );
				}
				
				// planX1 & lineX1ZP
				if (!positiveBorderX) {
					planX1 = chunk.GetBlocksXPlan( x+1 );
					if (neighbourZP != null)
						lineX1ZP = neighbourZP.GetBlocksXLineInPlanZ0( x+1 );
				} else {
					if (neighbourXP != null)
						planX1 = neighbourXP.GetBlocksXPlan( 0 );
					if (neighbourXPZP != null)
						lineX1ZP = neighbourXPZP.GetBlocksXLineInPlanZ0( 0 );
				}
				
					
				// Iterate through Y YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
				for(int y=0; y<Chunk.SIZE_Y; y++) {
					bool positiveBorderY = y == Chunk.SIZE_Y-1;
					bool negativeBorderY = y == 0;
					
					// Get Y lines (x/y, x/y+1, x+1/y and x+1/y+1) handling neighbours
					lineX0Y0 = null;
					lineX0Y1 = null;
					lineX1Y0 = null;
					lineX1Y1 = null;
					
					if (planX0 != null)
						lineX0Y0 = planX0[ y ];
					if (planX1 != null)
						lineX1Y0 = planX1[ y ];
					
					// X0					
					if (!positiveBorderY && planX0 != null) {
						lineX0Y1 = planX0[ y+1 ];
					} else {
						if (neighbourYP != null)
							lineX0Y1 = neighbourYP.GetBlocksXYLine( x, 0 );
					}
					
					if (!positiveBorderY && planX1 != null) {
						lineX1Y1 = planX1[ y+1 ];
					} else {
						if (positiveBorderX) {
							if (neighbourXPYP != null)
								lineX1Y1 = neighbourXPYP.GetBlocksXYLine(0, 0);
						} else {
							if (neighbourYP != null)
								lineX1Y1 = neighbourYP.GetBlocksXYLine(x+1, 0);
						}
					}
					
					
					// Iterate through Z ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
					for(int z=0; z<Chunk.SIZE_Z; z++) {
						bool positiveBorderZ = z == Chunk.SIZE_Z-1;
						bool negativeBorderZ = z == 0;
						
						// Get ready for new voxel
						marchingCubes.Reset();
						Vector3i localPos = new Vector3i(x, y, z);
						
						// Polygonize
						FastSetBlocksRegularCell(positiveBorderX, positiveBorderY, positiveBorderZ, x, y, z);
						marchingCubes.Polygonize(chunk, localPos, meshData, gridPos, gridPos,
													positiveBorderX, positiveBorderY, positiveBorderZ,
													negativeBorderX, negativeBorderY, negativeBorderZ);
						
					} // Z
				} // Y
			} // X
			
		}
		
		// Assign Marching Cubes blocks for polygonization of cell
		private void FastSetBlocksRegularCell(
							bool positiveBorderX,
							bool positiveBorderY,
							bool positiveBorderZ,
							int x, int y, int z)
		{
			marchingCubes.SetBlock(0, lineX0Y0 != null ? lineX0Y0[ z ] : null);
			marchingCubes.SetBlock(1, lineX1Y0 != null ? lineX1Y0[ z ] : null);
			marchingCubes.SetBlock(4, lineX0Y1 != null ? lineX0Y1[ z ] : null);
			marchingCubes.SetBlock(5, lineX1Y1 != null ? lineX1Y1[ z ] : null);
			if (!positiveBorderZ) {
				marchingCubes.SetBlock(3, lineX0Y0 != null ? lineX0Y0[ z+1 ] : null);
				marchingCubes.SetBlock(2, lineX1Y0 != null ? lineX1Y0[ z+1 ] : null);
				marchingCubes.SetBlock(7, lineX0Y1 != null ? lineX0Y1[ z+1 ] : null);
				marchingCubes.SetBlock(6, lineX1Y1 != null ? lineX1Y1[ z+1 ] : null);
			} else {
				
				marchingCubes.SetBlock(2, lineX1ZP != null ? lineX1ZP[ y ] : null);
				marchingCubes.SetBlock(3, lineX0ZP != null ? lineX0ZP[ y ] : null);
				
				if (!positiveBorderY) {
					marchingCubes.SetBlock(6, lineX1ZP != null ? lineX1ZP[ y+1 ] : null);
					marchingCubes.SetBlock(7, lineX0ZP != null ? lineX0ZP[ y+1 ] : null);
				} else {
					if (neighbourYPZP != null)
						marchingCubes.SetBlock(7, neighbourYPZP.GetBlockInLineZ0Y0( x ) );
						
					if (!positiveBorderX) {
						if (neighbourYPZP != null)
							marchingCubes.SetBlock(6, neighbourYPZP.GetBlockInLineZ0Y0( x+1 ) );
					} else {
						if (neighbourXPYPZP != null)
							marchingCubes.SetBlock(6, neighbourXPYPZP.GetBlockInLineZ0Y0( 0 ) );
					}
				}
			}
		}
		
	}

}