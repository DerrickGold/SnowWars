// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	/// <summary>
	/// Gives some useful methods for terrain building.</summary>
	internal static class BuildUtils
	{
		public static List<Vector3i> FindBlocks (Vector3i center, int size, BrushType type)
		{
			if (type == BrushType.Cube)
				return FindBlocksInCube (center, size);
			
			return FindBlocksInRange (center, size);
		}
		
		public static List<Vector3i> FindBlocksInRange (Vector3i center, int rad)
		{
			List<Vector3i> found = new List<Vector3i> ();
			if (rad == 0) {
				found.Add (center);
			} else {
				for (int z=center.z-rad; z<=center.z+rad; z++) {
					for (int y=center.y-rad; y<=center.y+rad; y++) {
						for (int x=center.x-rad; x<=center.x+rad; x++) {
							Vector3i current = new Vector3i (x, y, z);
							int dis = center.DistanceSquared (current);
							if (dis <= rad * rad) {
								found.Add (current);
							}
						}
					}
				}
			}
			return found;
		}
		
		public static List<Vector3i> FindBlocksInCube (Vector3i center, int size)
		{
			List<Vector3i> found = new List<Vector3i> ();
			if (size == 0) {
				found.Add (center);
			} else {
				int halfsive = size/2;
				for (int z=center.z-halfsive; z<=center.z+halfsive; z++) {
					for (int y=center.y-halfsive; y<=center.y+halfsive; y++) {
						for (int x=center.x-halfsive; x<=center.x+halfsive; x++) {
							Vector3i current = new Vector3i (x, y, z);
							found.Add (current);
						}
					}
				}
			}
			return found;
		}
		
		public static List<Vector3i> FindBlocksAbove (Vector3i center, int size, int maxY)
		{
			List<Vector3i> found = new List<Vector3i> ();
			if (size == 0) {
				found.Add (center);
			} else {
				int halfsive = size/2;
				for (int z=center.z-halfsive; z<=center.z+halfsive; z++) {
					for (int x=center.x-halfsive; x<=center.x+halfsive; x++) {
						for (int y=center.y; y<=maxY; y++) {
							Vector3i current = new Vector3i (x, y, z);
							found.Add (current);
						}
					}
				}
			}
			return found;
		}
		
		public static List<Vector3i> FindBlocksBelow (Vector3i center, int size)
		{
			List<Vector3i> found = new List<Vector3i> ();
			if (size == 0) {
				found.Add (center);
			} else {
				int halfsive = size/2;
				for (int z=center.z-halfsive; z<=center.z+halfsive; z++) {
					for (int x=center.x-halfsive; x<=center.x+halfsive; x++) {
						for (int y=0; y<center.y; y++) {
							Vector3i current = new Vector3i (x, y, z);
							found.Add (current);
						}
					}
				}
			}
			return found;
		}
		
		public static bool AreClose (Vector3 a, Vector3 b)
		{
			return (Mathf.Abs (a.x - b.x) < 0.001f &&
					Mathf.Abs (a.y - b.y) < 0.001f &&
					Mathf.Abs (a.z - b.z) < 0.001f);
		}
	}
	
}