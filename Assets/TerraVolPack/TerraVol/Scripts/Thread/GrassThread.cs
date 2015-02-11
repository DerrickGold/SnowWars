using UnityEngine;
using System.Collections.Generic;
using System.Threading;

namespace TerraVol {

	/// <summary>
	/// The thread that handles grass generation.</summary>
	/// <remarks>
	/// You should always interact with threads through the Thread Manager only.</remarks>
    internal class GrassThread
    {
		// Number of milliseconds to wait between two thread "dequeue"
		private const int SLEEP_TIME = 40;
		
		// System thread
		private Thread thread;
		
		// Entries to perform task on
		private Queue<GrassEntry> entries;
		
		/// <summary>
		/// Create the grass thread.</summary>
		/// <remarks>
		/// Thread priority is set to 'Lowest' to let the main thread use more CPU.</remarks>
		/// <param name="manager"> The Thread Manager instance.</param>
		internal GrassThread(ThreadManager manager)
		{
			entries = new Queue<GrassEntry>();
			
			thread = new Thread(new ThreadStart(DoWork));
			thread.Priority = System.Threading.ThreadPriority.Lowest;
		}
		
		/// <summary>
		/// Enqueue grass-generator for generation in a separate thread.</summary>
		/// <param name="gg"> Grass generator that must be used to generate grass.</param>
		/// <param name="buildId"> Internal grass-generator build-id.</param>
		internal void EnqueueGrassGenerator(GrassGenerator gg, int buildId)
		{
			lock (entries)
				entries.Enqueue(new GrassEntry(gg, buildId));
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
				GrassEntry entry = null;
				bool doNext = false;
				while (!doNext) {
					if (entries.Count != 0) {
						lock (entries)
							entry = entries.Dequeue();
						
						if (entry != null) {
							// Check build Id and start async operation. If build Id is different, do nothing.
							if (entry.buildId == entry.gg.BuildId) {
								// Start the asynchronous operation.
								doNext = true;
							}
						}
					}
					if (!doNext)
						Thread.Sleep(SLEEP_TIME);
				}
				
				// Extract the argument.
				GrassGenerator gg = entry.gg;
				
				// Build grass
				List<MeshData> meshesData = gg.GenerateGrassMesh ();
				gg.ApplyGrass (meshesData);
			}
		}
		
		/// <summary>
		/// Entry for grass thread.</summary>
		private class GrassEntry
		{
			public GrassGenerator gg;
			public int buildId;
			
			public GrassEntry (GrassGenerator gg, int buildId)
			{
				this.gg = gg;
				this.buildId = buildId;
			}
		}
		
	}
	
}