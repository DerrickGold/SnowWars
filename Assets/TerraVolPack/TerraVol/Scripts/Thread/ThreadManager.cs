// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Threading;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	
	/// <summary>
	/// The thread manager handles all threads for TerraVol.</summary>
	/// <remarks>
	/// This is the core of multithreading in TerraVol, allowing to enqueue tasks in separate threads.</remarks>
    internal class ThreadManager
    {
		// Number of threads
		internal const int BUILDER_THREADS_COUNT = 4;
		internal const int GENERATOR_THREADS_COUNT = 1;
		internal const int GRASS_THREADS_COUNT = 1;
		
		private TerraMap map;
		private static ThreadManager singleton = null;
		
		// Threads
		private BuilderThread[] backgroundBuilders;
		private GeneratorThread[] backgroundGenerators;
		private GrassThread[] backgroundGrass;
		
		private int indexBuilder = 0;
		private int indexGen = 0;
		private int indexGrass = 0;
		
		private bool started = false;
		
		internal TerraMap Map {
			get {
				return map;
			}
		}
		
		/// <summary>
		/// Use it to get the thread manager instance (singleton).</summary>
		/// <param name="map"> The TerraVol map.</param>
		/// <returns> Thread manager instance.</returns>
		internal static ThreadManager GetInstance(TerraMap map)
		{
			if (singleton == null)
				singleton = new ThreadManager(map);
			return singleton;
		}
		
		/// <summary>
		/// Set ThreadManager instance to NULL.</summary>
		internal static void ResetInstance()
		{
			singleton = null;
		}
		
		/// <summary>
		/// Create the thread manager and all its threads without starting them.</summary>
		/// <param name="map"> The TerraVol map.</param>
		private ThreadManager(TerraMap map) {
			this.map = map;
			started = false;
			
			backgroundBuilders = new BuilderThread[ BUILDER_THREADS_COUNT ];
			for (int i=0; i < BUILDER_THREADS_COUNT; i++) {
				backgroundBuilders[i] = new BuilderThread( this );
			}
			backgroundGenerators = new GeneratorThread[ GENERATOR_THREADS_COUNT ];
			for (int i=0; i < GENERATOR_THREADS_COUNT; i++) {
				backgroundGenerators[i] = new GeneratorThread( this );
			}
			backgroundGrass = new GrassThread[ GRASS_THREADS_COUNT ];
			for (int i=0; i < GRASS_THREADS_COUNT; i++) {
				backgroundGrass[i] = new GrassThread( this );
			}
		}
		
		/// <summary>
		/// Enqueue chunk for building in a separate thread.</summary>
		/// <param name="chunk"> Chunk to build.</param>
		/// <param name="buildId"> Internal chunk build-id.</param>
		internal void EnqueueForBuilding(Chunk chunk, int buildId)
		{
			backgroundBuilders[indexBuilder].EnqueueChunk( chunk, buildId );
			indexBuilder++;
			if (indexBuilder == BUILDER_THREADS_COUNT)
				indexBuilder = 0;
		}
		
		/// <summary>
		/// Enqueue column for voxel generation in a separate thread.</summary>
		/// <param name="column"> Column to generate.</param>
		internal void EnqueueForGeneration(Chunk2D column)
		{
			backgroundGenerators[indexGen].EnqueueColumn( column );
			indexGen++;
			if (indexGen == GENERATOR_THREADS_COUNT)
				indexGen = 0;
		}
		
		/// <summary>
		/// Enqueue grass-generator for generation in a separate thread.</summary>
		/// <param name="gg"> Grass generator that must be used to generate grass.</param>
		/// <param name="buildId"> Internal grass-generator build-id.</param>
		internal void EnqueueForGeneratingGrass(GrassGenerator gg, int buildId)
		{
			backgroundGrass[indexGrass].EnqueueGrassGenerator( gg, buildId );
			indexGrass++;
			if (indexGrass == GRASS_THREADS_COUNT)
				indexGrass = 0;
		}
		
		/// <summary>
		/// Start all threads.</summary>
		/// <remarks>
		/// Threads must be started only once.</remarks>
		internal void StartAll()
		{
			if (!started) {
				Debug.Log("[TerraVol] Start all threads");
				for (int i=0; i < BUILDER_THREADS_COUNT; i++) {
					backgroundBuilders[i].Start();
				}
				for (int i=0; i < GENERATOR_THREADS_COUNT; i++) {
					backgroundGenerators[i].Start();
				}
				for (int i=0; i < GRASS_THREADS_COUNT; i++) {
					backgroundGrass[i].Start();
				}
				started = true;
			}
		}
		
	}
	
}
