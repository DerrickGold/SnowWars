// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using ProtoBuf;
using System.Collections;

namespace TerraVol
{
	/// <summary>
	/// This class represents a column of chunks.</summary>
	public class Chunk2D
	{
		public Vector2i position = Vector2i.zero;
		public bool display = true;
		public bool generated = false;
		public bool built = false;
		public bool generating = false;
		public bool building = false;
		public bool grassBuilt = false;
		
		public Chunk2D (Vector2i position)
		{
			this.position = position;
		}
		
	}
	
}