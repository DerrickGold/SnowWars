// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using ProtoBuf;
using System.Collections;


namespace TerraVol {
	
	/// <summary>
	/// Simple Vector2 serializable with Protobuf-net.</summary>
	[ProtoContract]
	public struct ProtoVector2 {
		
		[ProtoMember(1, IsRequired=true)]
		public float x;
		
		[ProtoMember(2, IsRequired=true)]
		public float y;
		
		public ProtoVector2(float x, float y)
		{
			this.x = x;
			this.y = y;
		}
		
		public ProtoVector2(Vector2 v)
		{
			this.x = v.x;
			this.y = v.y;
		}
	}
	
}