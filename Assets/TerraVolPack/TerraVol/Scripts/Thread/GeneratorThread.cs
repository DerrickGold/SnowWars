using UnityEngine;
using System.Collections.Generic;
using System.Threading;

namespace TerraVol {

	/// <summary>
	/// The thread that handles terrain generation (ie. creation of voxels). This doesn't include terrain building.</summary>
	/// <remarks>
	/// You should always interact with threads through the Thread Manager only.</remarks>
    internal class GeneratorThread
    {
		// Number of milliseconds to wait between two thread "dequeue"
		private const int SLEEP_TIME = 35;
		
		// System thread
		private Thread thread;
		
		// Entries to perform task on
		private Queue<Chunk2D> columns;
		
		// Reference to the terrain generator
		private TerrainGenerator generator;
		
		/// <summary>
		/// Create the voxel generation thread.</summary>
		/// <remarks>
		/// Thread priority is set to 'BelowNormal' to let the main thread use more CPU.</remarks>
		/// <param name="manager"> The Thread Manager instance.</param>
		internal GeneratorThread(ThreadManager manager)
		{
			columns = new Queue<Chunk2D>();
			generator = manager.Map.TerrainGenerator;
			
			thread = new Thread(new ThreadStart(DoWork));
			thread.Priority = System.Threading.ThreadPriority.BelowNormal;
		}
		
		/// <summary>
		/// Enqueue column for generation in a separate thread.</summary>
		/// <param name="column"> Column to generate.</param>
		internal void EnqueueColumn(Chunk2D column)
		{
			lock (columns)
				columns.Enqueue(column);
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
				Chunk2D column = null;
				bool doNext = false;
				while (!doNext) {
					lock (columns)
					{
						if (columns.Count != 0) {
							column = columns.Dequeue();
							
							// Start the asynchronous operation.
							if (column != null) {
								doNext = true;
							}
						}
					}
					if (!doNext)
						Thread.Sleep(SLEEP_TIME);
				}
				
				// Generate voxels of column
				generator.Generate(column);
				column.generated = true;
				column.generating = false;
				column.built = false;
			}
		}
		
	}
	
}