// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using TerraVol;
using System.Collections.Generic;

/// <summary>
/// This is just a set of block types.</summary>
[ExecuteInEditMode]
[AddComponentMenu("TerraVol/BlockSet")]
public class BlockSet : MonoBehaviour
{
		
	[SerializeField]
	public List<Block> blocks = new List<Block> ();
	[SerializeField]
	public Material[] materials;
		
		
	/// <summary>
	/// Use it to get a type of block by its name.</summary>
	/// <param name="name"> The name of type of block.</param>
	/// <returns> The type of block. Null is nothing was found.</returns>
	public Block GetBlock (string name)
	{
		foreach (Block block in blocks) {
			if (block.Name == name)
				return block;
		}
		return null;
	}
		
	/// <summary>
	/// Use it to get a type of block by its index.</summary>
	/// <param name="index"> The index of type of block.</param>
	/// <returns> The type of block. Null is nothing was found.</returns>
	public Block GetBlock (int index)
	{
		if (index >= 0 && index < blocks.Count) {
			return blocks [index];
		}
		return null;
	}
		
	/// <summary>
	/// Use it to get the array of materials of this block set.</summary>
	/// <returns> Array of materials.</returns>
	public Material[] GetMaterials ()
	{
		return materials;
	}
	
	/// <summary>
	/// Use it to get an array of types of blocks names.</summary>
	/// <returns> Array of names.</returns>
	public string[] GetBlocksNameArray ()
	{
		string[] result = new string[blocks.Count];
		for (int i=0; i < blocks.Count; i++) {
			result [i] = blocks [i].Name;
		}
		return result;
	}
		
}
