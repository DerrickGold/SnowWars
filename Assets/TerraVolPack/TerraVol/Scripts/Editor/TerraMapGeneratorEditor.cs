// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using UnityEditor;
using TerraVol;
using System.Collections;


[CustomEditor(typeof(TerraMapGenerator))]
public class TerraMapGeneratorEditor : Editor
{
	private TerraMapGenerator mapGenerator;
	
	public void OnEnable()
	{
		this.mapGenerator = (TerraMapGenerator)target;
	}
 
	public void OnDisable()
	{
	}
	
	public override void OnInspectorGUI () {
		if (mapGenerator == null)
			return;

		mapGenerator.roughness = EditorGUILayout.Slider ("Roughness", mapGenerator.roughness, 0f, 50f);
		mapGenerator.granularity = EditorGUILayout.Slider ("Granularity", mapGenerator.granularity, 1f, 300f);
		
		DrawDefaultInspector();
		
        if (GUI.changed) {
            EditorUtility.SetDirty (target);
		}
    }
	
}