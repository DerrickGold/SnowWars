// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using UnityEditor;
using TerraVol;
using System.Collections;
using System.Collections.Generic;


[CustomEditor(typeof(TerraBuilder))]
public class TerraEditor : Editor
{
	private static TerraEditor singleton = null;
	
	private TerraBuilder builder;
	private int blockIndex = 0;
	private bool enableBuilderInEditor = false;
	private static bool started = false;
	private bool acting = false;
	private bool oneActionPerClick = true;
	private Vector3? point = null;
	private bool needSave = false;
	private bool askedSave = false;
	private bool undoing = false;
	private List<int> lastUndoActionIndex = new List<int>();
	
	private GUIStyle style;
	private GUIStyle styleImportant;
	private GUIStyle styleNote;
	
	public static TerraEditor Instance
	{
		get {
			return singleton;
		}
	}
	
	private void CallbackFunction()
	{
		if (!enableBuilderInEditor || builder.TerraMap == null)
			return;
		
		if (builder.TerraMap.TerraMap2DIsNull() || builder.TerraMap.ChunksGridIsNull() || !started) {
			started = true;
			askedSave = false;
			undoing = false;
			needSave = builder.Init();
		}
		
		builder.Show3DBrush(point);
		
		if (acting) {
			builder.DoAction(point);
			if (oneActionPerClick)
				acting = false;
		}
		
		// Update all
		builder.TerraMap.UpdateAll();
	}
	
	public void OnEnable()
	{
		singleton = this;
		this.builder = (TerraBuilder)target;
		EditorApplication.update += CallbackFunction;
	}
 
	public void OnDisable()
	{
		EditorApplication.update -= CallbackFunction;
		CheckAndSave();
	}
	
	public void CheckAndSave()
	{
		if (builder != null) {
			builder.DestroyBrush ();
			
			if (!undoing && needSave && !askedSave) {
				askedSave = true;
				if (EditorUtility.DisplayDialog("Save TerraVol Map data?",
						"Map data has been modified since last save.\n\n"+
						"Caution:\n"+
						"- If you do not save TerraVol map, all changes will be lost.\n"+
						"- If you do not save TerraVol map and 'path' property of TerraMap is empty, terrain will be randomly (re)generated.", "Save", "Don't Save"))
				{
					if (builder.SaveTerraMap()) {
						needSave = false;
						EditorUtility.DisplayDialog("Map saved.",
							"TerraVol Map data has been saved.\n\nThe path of the file has been automatically added to the 'Load Path' property of the Map component.", "Ok");
					}
				}
			}
		}
		undoing = false;
	}
	
	public override void OnInspectorGUI () {
		
		style = new GUIStyle("Label");
		style.alignment = TextAnchor.LowerLeft;
		style.wordWrap = true;
		style.fontSize = 11;
		style.margin.left = 20;
		style.margin.right = 20;
		style.margin.top = 10;
		style.padding = new RectOffset(0, 4, 0, 2);
		
		styleImportant = new GUIStyle("Label");
		styleImportant.alignment = TextAnchor.LowerLeft;
		styleImportant.wordWrap = true;
		styleImportant.fontSize = 11;
		styleImportant.fontStyle = FontStyle.Bold;
		styleImportant.margin.left = 20;
		styleImportant.margin.right = 20;
		styleImportant.margin.top = 10;
		styleImportant.padding = new RectOffset(0, 4, 0, 2);
		
		styleNote = new GUIStyle("Label");
		styleNote.alignment = TextAnchor.LowerLeft;
		styleNote.wordWrap = true;
		styleNote.fontSize = 11;
		styleNote.margin.left = 4;
		styleNote.margin.right = 0;
		styleNote.margin.top = 10;
		
		EditorGUILayout.LabelField("In-editor Builder is a tool that allows to sculpt and paint the terrain within the editor.", style);
		
		EditorGUILayout.LabelField("IMPORTANT: to build terrain around the reticle, press 'B'. Scene view must be focused and in-editor builder must be started.", styleImportant);
		EditorGUILayout.LabelField("Press 'Z' key to undo your last actions.", styleImportant);
		
		this.builder = (TerraBuilder)target;
		if (builder == null)
			return;
		
		if (builder.TerraMap == null)
			return;
		
		EditorGUILayout.LabelField("Use the checkbox below to choose the editing mode. One action per click is more accurate but slower.", styleNote);
		oneActionPerClick = EditorGUILayout.Toggle("One action per click only", oneActionPerClick);
		
		EditorGUILayout.LabelField("Toggle delta-edit mode to edit terrain with smaller/smoother changes.", styleNote);
		builder.deltaEdit = EditorGUILayout.Toggle("Delta-edit", builder.deltaEdit);
		
		if (builder.brushType == BrushType.Cube || builder.brushType == BrushType.SharpCube) {
			builder.isize.x = EditorGUILayout.IntSlider ("Cube size X", builder.isize.x * Chunk.SIZE_X_BLOCK, 2*Chunk.SIZE_X_BLOCK, 10*Chunk.SIZE_X_BLOCK) / Chunk.SIZE_X_BLOCK;
			builder.isize.y = EditorGUILayout.IntSlider ("Cube size Y", builder.isize.y * Chunk.SIZE_Y_BLOCK, 2*Chunk.SIZE_Y_BLOCK, 10*Chunk.SIZE_Y_BLOCK) / Chunk.SIZE_Y_BLOCK;
			builder.isize.z = EditorGUILayout.IntSlider ("Cube size Z", builder.isize.z * Chunk.SIZE_Z_BLOCK, 2*Chunk.SIZE_Z_BLOCK, 10*Chunk.SIZE_Z_BLOCK) / Chunk.SIZE_Z_BLOCK;
		} else if (builder.brushType == BrushType.Cylinder) {
			builder.size.x = EditorGUILayout.Slider ("Cylinder radius", builder.size.x, 0, 100f);
			builder.isize.y = EditorGUILayout.IntSlider ("Cylinder height", builder.isize.y * Chunk.SIZE_Y_BLOCK, 2*Chunk.SIZE_Y_BLOCK, 10*Chunk.SIZE_Y_BLOCK) / Chunk.SIZE_Y_BLOCK;
		} else {
			builder.size.x = EditorGUILayout.Slider ("Sphere radius", builder.size.x, Chunk.SIZE_X_BLOCK, 100f);
		}
		
		if (builder.deltaEdit) {
			builder.strength = EditorGUILayout.Slider ("Brush strength", builder.strength, 0f, 10f);
		}
		
		builder.maxModifyDistance = EditorGUILayout.IntSlider ("Distance of effect", builder.maxModifyDistance, 10, 2000);
		
		if (builder.currentAction == ActionDataType.Flatten) {
			builder.flattenHeight = EditorGUILayout.FloatField("Flatten Height", builder.flattenHeight);
		}
		
		builder.currentAction = (ActionDataType)EditorGUILayout.EnumPopup( "Action", builder.currentAction );
		
		builder.brushType = (BrushType)EditorGUILayout.EnumPopup( "Brush", builder.brushType );
		
		
		EditorGUILayout.LabelField("If you want to place/remove grass and trees, you have to create a new type of block in the Block-Set "
			+"with 'vegetation enabled' property set to whatever you want. Then, simply select it in the 'Current type of block' select-box and choose "
			+"the 'Paint' action to affect the ground without modifying terrain shape. This may look a bit unintuitive, but this is mandatory because terrain creation is driven by blocks data only (ie. voxels).", style);
		
		string[] options = builder.TerraMap.GetBlockSet().GetBlocksNameArray();
		
		EditorGUILayout.BeginHorizontal();
        blockIndex = EditorGUILayout.Popup("Current type of block: ",
             blockIndex, options, EditorStyles.popup);
        EditorGUILayout.EndHorizontal();
		
		string btnText = "Start In-editor Builder";
		if (enableBuilderInEditor)
			btnText = "Stop In-editor Builder";
		if (GUILayout.Button(btnText)) {
			//add everthing the button would do.
			enableBuilderInEditor = !enableBuilderInEditor;
			if (!enableBuilderInEditor)
				builder.DestroyBrush();
		}
		
		if (GUILayout.Button("Save map")) {
			//add everthing the button would do.
			if (builder.SaveTerraMap())
				needSave = false;
		}
		
		if (GUILayout.Button("Reload from file")) {
			//add everthing the button would do.
			enableBuilderInEditor = false;
			builder.Reload();
			needSave = false;
			started = true;
		}
		
		if (GUILayout.Button("Reset and re-create terrain randomly")) {
			//add everthing the button would do.
			enableBuilderInEditor = false;
			builder.Reset();
			needSave = true;
			started = true;
		}		
		
        if (GUI.changed) {
			builder.SetSelectedBlock(blockIndex);
            EditorUtility.SetDirty (target);
		}
    }
 
	void OnSceneGUI()
	{
		int controlID = GUIUtility.GetControlID (FocusType.Passive);
		if (!enableBuilderInEditor)
			return;
			
		point = GetFireTarget();
		
		bool used = false; 
 	   
		Event e = Event.current;
 
		if (e.type == EventType.MouseDown && e.button == 0 && (!oneActionPerClick || !acting))
		{
			if (!acting)
				lastUndoActionIndex.Add( WorldRecorder.Instance.ActionCount );
			used = true;
			acting = true;
			needSave = true;
			askedSave = false;
		}
		else if (e.type == EventType.MouseUp && e.button == 0)
		{
			used = true;
			acting = false;
		}
		else if (e.type == EventType.KeyDown && e.keyCode == KeyCode.B)
		{
			if (point.HasValue) {
				Debug.Log("[TerraVol] Building around reticle...");
				builder.TerraMapGenerator.GenerateForEditor(point.Value);
			} else if (Camera.current != null) {
				Debug.Log("[TerraVol] Building around camera...");
				builder.TerraMapGenerator.GenerateForEditor(Camera.current.transform.position);
			}
		}
		else if (e.type == EventType.KeyDown && e.keyCode == KeyCode.Z && lastUndoActionIndex.Count != 0) 
		{
			// CTRL + Z
			Debug.Log("[TerraVol] Undo...");
			undoing = true;
			WorldRecorder.Instance.UndoLastAction(builder.TerraMap, lastUndoActionIndex[lastUndoActionIndex.Count-1]);
			lastUndoActionIndex.RemoveAt(lastUndoActionIndex.Count-1);
			used = true;
		}
 
		if (used) {
			e.Use();
		}
		
		if (e.type == EventType.layout)
			HandleUtility.AddDefaultControl(controlID);
	}
	
	private Vector3? GetFireTarget()
	{
		if (Camera.current != null) {
			Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
	
			RaycastHit hit = new RaycastHit ();
			if (Physics.Raycast (ray.origin, ray.direction, out hit, builder.maxModifyDistance)) {
				Vector3 dif = (hit.point - Camera.current.transform.position).normalized;
				dif.x *= Chunk.SIZE_X_BLOCK;
				dif.y *= Chunk.SIZE_Y_BLOCK;
				dif.z *= Chunk.SIZE_Z_BLOCK;
				return hit.point - dif;
			}
		}
		return null;
	}
	
}