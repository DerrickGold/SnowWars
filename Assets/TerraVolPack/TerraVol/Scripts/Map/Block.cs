// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using System;
using System.Collections;

namespace TerraVol
{
	/// <summary>
	/// This defines a block type.</summary>
	[Serializable]
	public class Block
	{
		
		[SerializeField]
		private string name;
		[SerializeField]
		private int materialIndex;
		[SerializeField]
		private Color vertexColor;
		[SerializeField]
		private bool isDestructible;
		[SerializeField]
		private int priority;
		[SerializeField]
		private bool isVegetationEnabled;
		
		[Obsolete("use Name property instead.")]
		public void SetName (string name)
		{
			this.name = name;
		}
		
		[Obsolete("use Name property instead.")]
		public string GetName ()
		{
			return name;
		}
		
		[Obsolete("use MaterialIndex property instead.")]
		public void SetMaterialIndex (int materialIndex)
		{
			this.materialIndex = materialIndex;
		}
		
		[Obsolete("use MaterialIndex property instead.")]
		public int GetMaterialIndex ()
		{
			return materialIndex;
		}
		
		[Obsolete("use VertexColor property instead.")]
		public void SetVertexColor (Color vertexColor)
		{
			this.vertexColor = vertexColor;
		}
		
		[Obsolete("use VertexColor property instead.")]
		public Color GetVertexColor ()
		{
			return vertexColor;
		}
		
		[Obsolete("use VertexColor property instead.")]
		public void SetIsDestructible (bool isDestructible)
		{
			this.isDestructible = isDestructible;
		}
		
		public string Name
		{
			get {
				return name;
			}
			set {
				name = value;
			}
		}
		
		public int Priority
		{
			get {
				return priority;
			}
			set {
				priority = value;
			}
		}
		
		public int MaterialIndex
		{
			get {
				return materialIndex;
			}
			set {
				materialIndex = value;
			}
		}
		
		public Color VertexColor
		{
			get {
				return vertexColor;
			}
			set {
				vertexColor = value;
			}
		}
		
		public bool IsVegetationEnabled
		{
			get {
				return isVegetationEnabled;
			}
			set {
				isVegetationEnabled = value;
			}
		}
		
		public bool IsDestructible
		{
			get {
				return isDestructible;
			}
			set {
				isDestructible = value;
			}
		}
		
	}

}