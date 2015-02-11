// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using UnityEditor;
using TerraVol;
using System.Collections;


[CustomEditor(typeof(Chunk))]
public class ChunkEditor : Editor
{
	private Chunk chunk;
	
	public void OnEnable()
	{
		this.chunk = (Chunk)target;
	}
 
	public void OnDisable()
	{
	}
	
	public override void OnInspectorGUI () {
		if (chunk == null)
			return;

		if (GUILayout.Button("Build immediately with vegetation")) {
			//add everthing the button would do.
			chunk.BuildImmediately(true);
		}
		if (GUILayout.Button("Build immediately without vegetation")) {
			//add everthing the button would do.
			chunk.BuildImmediately(false);
		}
		if (GUILayout.Button("Debug Path info")) {
			//add everthing the button would do.
			PathDebuger.DebugPath(chunk.ChunkData);
		}
		if (GUILayout.Button("Clear Path info")) {
			//add everthing the button would do.
			PathDebuger.Clear(chunk.ChunkData);
		}
		
		DrawDefaultInspector();
		
        if (GUI.changed) {
            EditorUtility.SetDirty (target);
		}
    }
	
}