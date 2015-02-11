using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[InitializeOnLoad]
public class OnRun
{

	static OnRun ()
	{

		EditorApplication.playmodeStateChanged = () =>
		{

			if (EditorApplication.isPlayingOrWillChangePlaymode && !EditorApplication.isPlaying) {
				if (TerraEditor.Instance != null) {
					TerraEditor.Instance.CheckAndSave();
				}
			}

		};

	}

}