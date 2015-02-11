// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Threading;

namespace TerraVol
{

	/// <summary>
	/// The thread that handles terrain building (ie. polygonization of voxels). This doesn't include terrain generation.</summary>
	/// <remarks>
	/// You should always interact with threads through the Thread Manager only.</remarks>
    internal class BuilderThread
    {
		// Number of milliseconds to wait between two thread "dequeue"
		private const int SLEEP_TIME = 32;
		
		// System thread
		private Thread thread;
		
		// Entries to perform task on
		private Queue<BuilderEntry> entries;
		
		// Chunk builder instance
		private ChunkBuilder chunkBuilder;
		
		/// <summary>
		/// Create the chunk builder thread.</summary>
		/// <remarks>
		/// Thread priority is set to 'BelowNormal' to let the main thread use more CPU.</remarks>
		/// <param name="manager"> The Thread Manager instance.</param>
		internal BuilderThread(ThreadManager manager)
		{
			entries = new Queue<BuilderEntry>();
			chunkBuilder = new ChunkBuilder();
			
			thread = new Thread(new ThreadStart(DoWork));
			thread.Priority = System.Threading.ThreadPriority.BelowNormal;
		}
		
		/// <summary>
		/// Enqueue chunk for building.</summary>
		/// <param name="chunk"> Chunk to build.</param>
		/// <param name="buildId"> Internal chunk build-id.</param>
		internal void EnqueueChunk(Chunk chunk, int buildId)
		{
			lock (entries)
				entries.Enqueue( new BuilderEntry(chunk, buildId) );
		}
		
		/// <summary>
		/// Start this thread.</summary>
		internal void Start()
		{
			thread.Start();
		}
		
		/// <summary>
		/// Background work done by this thread.</summary>
		private void DoWork()
		{
			while (true)
			{
				// Extract next entry and perform task immediatly
				BuilderEntry entry = null;
				bool doNext = false;
				while (!doNext) {
					if (entries.Count != 0) {
						lock (entries)
							entry = entries.Dequeue();
						if (entry != null) {
							// Check build Id and start async operation. If build Id is different, do nothing.
							if (entry.buildId == entry.chunk.BuildId) {
								// Start the asynchronous operation.
								doNext = true;
							}
						}
					}
					if (!doNext)
						Thread.Sleep(SLEEP_TIME);
				}
				
				// Extract the argument.
				ChunkData chunkData = entry.chunk.ChunkData;
				chunkData.BuildStarted = true;
				
				// Build chunk (compute new mesh data)
				// MeshData will be affected to the ChunkData on the main thread
				MeshData meshData = chunkBuilder.BuildChunk(chunkData);
				
				// Ground
				if (entry.buildId == chunkData.Chunk.BuildId) {
					if (meshData.vertices.Count != 0) {
						BuildHelper.ComputeNormals(meshData, chunkData);
						BuildHelper.ComputeUVs(meshData, chunkData);
						BuildHelper.SolveTangents(meshData);
						if (chunkData.useRTP3)
							BuildHelper.ComputeColorsAfterBuild(meshData, chunkData, chunkData.Position.y == 0, chunkData.Position.y < 0);
						chunkData.MeshDataTmp = meshData;
						chunkData.IsHarmonizable = true;
						BuildHelper.HarmonizeTwinVertices(meshData, chunkData, true);
					}
					// Precompute arrays from lists
					meshData.PrepareArrays();
				}
				
				// Post build (affect new mesh data). Check buildId again because it has may changed since last check.
				if (entry.buildId == chunkData.Chunk.BuildId) {
					chunkData.MeshData = meshData;
					chunkData.Chunk.Built = false;
				}
				
				chunkData.BuildStarted = false;
			}
		}
		
		/// <summary>
		/// Entry for builder thread.</summary>
		public class BuilderEntry
		{
			public Chunk chunk;
			public int buildId;
			
			public BuilderEntry (Chunk chunk, int buildId)
			{
				this.chunk = chunk;
				this.buildId = buildId;
			}
		}
		
	}
	
}