// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using TerraVol;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
[AddComponentMenu("TerraVol/In-Editor Builder Tool")]
[RequireComponent (typeof (TerraMap), typeof (TerraMapGenerator))]
public class TerraBuilder : MonoBehaviour
{		
	// Affect digging & building radius, distance, and speed
	public bool deltaEdit = false;
	public Vector3 size = new Vector3(10f, 10f, 10f);
	public Vector3i isize = new Vector3i(5, 5, 5);
	public float strength = 0.1f;
	public int maxModifyDistance = 1000;
	public float flattenHeight = 0f;
	public ActionDataType currentAction = ActionDataType.Dig;
	public ActionDataType lastAction = ActionDataType.Dig;
	public BrushType brushType = BrushType.Sphere;
	public BrushType lastBrushType = BrushType.Sphere;
		
	// Misc
	private Block currentBlock = null;
	private Transform retAdd = null;
	private Transform retDel = null;
	private Transform currentReticle = null;
		
	public TerraMap TerraMap {
		get {
			return GetComponent<TerraMap> ();
		}
	}
		
	public TerraMapGenerator TerraMapGenerator {
		get {
			return GetComponent<TerraMapGenerator> ();
		}
	}
		
	void Awake ()
	{
		if (!Application.isEditor) {
			enabled = false;
		}
		if (this.TerraMap == null) {
			enabled = false;
			Debug.LogError ("[TerraVol] TerraBuilder needs a TerraMap component");
			return;
		}
	}
		
	void Start ()
	{
		if (Application.isEditor && currentBlock == null) {
			currentBlock = this.TerraMap.GetBlockSet ().GetBlock ("Default");
		}
	}
	
	public void LoadReticle()
	{
		GameObject retAddPrefab = Resources.Load("RetAdd") as GameObject;
		GameObject retAddObj = (GameObject) Instantiate(retAddPrefab, new Vector3(0, -1, 0), Quaternion.identity);
		retAdd = retAddObj.transform;
		
		GameObject retDelPrefab = Resources.Load("RetDel") as GameObject;
		GameObject retDelObj = (GameObject) Instantiate(retDelPrefab, new Vector3(0, -1, 2), Quaternion.identity);
		retDel = retDelObj.transform;
	}
		
	public void DoAction (Vector3? point)
	{
		if (currentReticle != null && point.HasValue) {
			Vector3 s;
			if (brushType == BrushType.Cube || brushType == BrushType.SharpCube) {
				s = new Vector3((isize.x + 2) * Chunk.SIZE_X_BLOCK, 
								(isize.y + 2) * Chunk.SIZE_Y_BLOCK, 
								(isize.z + 2) * Chunk.SIZE_Z_BLOCK);
			} else if (brushType == BrushType.Cylinder) {
				s = new Vector3( size.x, (isize.y + 2) * Chunk.SIZE_Y_BLOCK, 0);
			} else {
				s = size;
			}
			
			if (!deltaEdit) {
				// Perform action
				WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(currentReticle.position), s, currentBlock,
						currentAction, brushType, true, true));
			} else {
				// Perform action
				WorldRecorder.Instance.PerformAction(new ActionData(Chunk.ToTerraVolPosition(currentReticle.position), s, currentBlock,
						currentAction, brushType, strength, true, true));
			}
		}
	}
		
	public void SetSelectedBlock (int index)
	{
		currentBlock = this.TerraMap.GetBlockSet ().GetBlock (index);
	}
		
	public bool SaveTerraMap ()
	{
		#if UNITY_EDITOR
		string path = EditorUtility.SaveFilePanelInProject(
                "Save TerraVol TerraMap",
                "myMap.terra",
                "terra",
				"Please enter a file name to save the map to");
        if (path.Length != 0) {
            this.TerraMap.Save( path );
			Debug.Log ("[TerraVol] TerraMap saved. The path of the file has been automatically added to the 'Load Path' property of TerraMap component.");
			return true;
		}
		#endif
		return false;
	}
	
	public bool Init ()
	{
		if (TerraMap.loadPath != null && TerraMap.loadPath.Length != 0) {
			TerraMap.Reload();
			return false;
		} else {
			Reset();
			return true;
		}
	}
		
	public void Reset ()
	{
		List<GameObject> children = new List<GameObject> ();
		foreach (Transform child in transform) {
			children.Add (child.gameObject);
		}
		for (int i=0; i < children.Count; i++) {
			Object.DestroyImmediate (children [i]);
		}
		TerraMap.TerraMap2D = null;
		TerraMap.Chunks = null;
		TerraMap.loadPath = null;		
		TerraMap.Awake ();
		TerraMapGenerator.Awake ();
		TerraMap.Start ();
		TerraMapGenerator.Start ();
		System.GC.Collect ();
		TerraMap.UpdateAll();
	}
	
	public void Reload ()
	{
		TerraMap.Reload ();
	}
		
	public void DestroyBrush ()
	{
		if (currentReticle != null) {
			currentReticle = null;
		}
		if (retAdd != null) {
			Object.DestroyImmediate (retAdd.gameObject);
			retAdd = null;
		}
		if (retDel != null) {
			Object.DestroyImmediate (retDel.gameObject);
			retDel = null;
		}
	}
		
	public void Show3DBrush (Vector3? point)
	{
		if (this.TerraMap == null || this.TerraMapGenerator == null ||
			this.TerraMap.TerraMap2D == null || this.TerraMap.Chunks == null)
			return;
		
		// Switch brush
		if (brushType != lastBrushType || currentAction != lastAction) {
			lastBrushType = brushType;
			lastAction = currentAction;
		}
		if (retAdd == null || retDel == null)
			LoadReticle();
		
		retAdd.GetChild(0).gameObject.renderer.enabled = false;
		retDel.GetChild(0).gameObject.renderer.enabled = false;
		retAdd.GetChild(1).gameObject.renderer.enabled = false;
		retDel.GetChild(1).gameObject.renderer.enabled = false;
		
		if (currentAction == ActionDataType.Dig) {
			if (brushType == BrushType.Cube || brushType == BrushType.SharpCube) {
				currentReticle = retDel.Find("RetDelCube");
			} else if (brushType == BrushType.Cylinder) {
				currentReticle = retDel.Find("RetDelCylinder");
			} else {
				currentReticle = retDel.Find("RetDelSphere");
			}
		} else {
			if (brushType == BrushType.Cube || brushType == BrushType.SharpCube) {
				currentReticle = retAdd.Find("RetAddCube");
			} else if (brushType == BrushType.Cylinder) {
				currentReticle = retAdd.Find("RetAddCylinder");
			} else {
				currentReticle = retAdd.Find("RetAddSphere");
			}
		}
		
		currentReticle.gameObject.renderer.enabled = true;
			
		if (point.HasValue && currentReticle != null) {
			int posX = Mathf.RoundToInt (point.Value.x / Chunk.SIZE_X_BLOCK);
			int posY = Mathf.RoundToInt (point.Value.y / Chunk.SIZE_Y_BLOCK);
			int posZ = Mathf.RoundToInt (point.Value.z / Chunk.SIZE_Z_BLOCK);
			
			// Position of brush
			if (brushType == BrushType.Cube || brushType == BrushType.SharpCube) {
				currentReticle.position = new Vector3(posX * Chunk.SIZE_X_BLOCK, 
													posY * Chunk.SIZE_Y_BLOCK, 
													posZ * Chunk.SIZE_Z_BLOCK);
			} else {
				currentReticle.position = point.Value;
			}
			
			// Size of brush
			Vector3 s;
			if (brushType == BrushType.Cube || brushType == BrushType.SharpCube) {
				s = new Vector3(isize.x * Chunk.SIZE_X_BLOCK, isize.y * Chunk.SIZE_Y_BLOCK, isize.z * Chunk.SIZE_Z_BLOCK);
			} else if (brushType == BrushType.Cylinder) {
				s = new Vector3(2f * size.x, isize.y * Chunk.SIZE_Y_BLOCK, 2f * size.x);
			} else {
				s = 2f * new Vector3(size.x, size.x, size.x);
			}
			currentReticle.localScale = s;
		}
	}
		
}
