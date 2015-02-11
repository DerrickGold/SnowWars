// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using TerraVol;
using System.Collections;

public interface ITerraVolEnhance
{	
	// Use it to choose terrain's blocks depending on block's position
	Block OnBlockGenerateBeforeInThread (Vector3i position);
	
	// Called right before chunk build
	void OnChunkBuildBefore (Chunk chunk);
	
	// Called right after chunk build
	void OnChunkBuildAfter (Chunk chunk);
	
	// Called after chunk build to create vegetation (except grass)
	void CreateVegetation (Chunk chunk);
	
}
