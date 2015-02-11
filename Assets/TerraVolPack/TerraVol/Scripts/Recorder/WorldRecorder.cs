using UnityEngine;
using ProtoBuf;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	
	/// <summary>
	/// This is the core of the new actions-driven system of TerraVol.</summary>
	/// <remarks>
	/// This class handles actions performing, recording, and restoring. It also handle persistance and loading.</remarks>
	[ProtoContract(SkipConstructor=true)]
	public class WorldRecorder
	{
		public const string LOAD_UNDO_PATH = "Assets/undo.terra";
		
		// singleton instance
		private static WorldRecorder singleton;
		
		// List of actions performed on the map
		[ProtoMember(1, IsRequired=true)]
		private Dictionary<Vector3i, List<ActionData>> actions;
		
		// Used for handling 'Undo'
		[ProtoMember(2, IsRequired=true)]
		private List<ActionData> actionsOrdered;
		
		// Seed for perlin noise 2D
		[ProtoMember(3, IsRequired=true)]
		private ProtoVector2[] noise2dRandomValues;
		
		// Seed for perlin noise 3D
		[ProtoMember(4, IsRequired=true)]
		private ProtoVector2[] noise3dRandomValues;
		
		public ProtoVector2[] Noise2dRandomValues {
			get {
				return noise2dRandomValues;
			}
			set {
				noise2dRandomValues = value;
			}
		}
		
		public ProtoVector2[] Noise3dRandomValues {
			get {
				return noise3dRandomValues;
			}
			set {
				noise3dRandomValues = value;
			}
		}
		
		[ProtoMember(5, IsRequired=true)]
		public int worldMinY = 0;
		
		[ProtoMember(6, IsRequired=true)]
		public int worldMaxY = 0;
		
		public int ActionCount
		{
			get {
				if (actionsOrdered != null)
					return actionsOrdered.Count;
				return 0;
			}
		}
		
		/// <summary>
		/// Create a world recorder.</summary>
		/// <remarks>
		/// This constructor must be skiped by Protobuf-Net.</remarks>
		private WorldRecorder ()
		{
			actions = new Dictionary<Vector3i, List<ActionData>>(new Vector3iComparer());
			actionsOrdered = new List<ActionData>();
			noise2dRandomValues = new ProtoVector2[ 2 ];
			noise3dRandomValues = new ProtoVector2[ 256 ];
		}
		
		/// <summary>
		/// Use it to get the world recorder instance (singleton).</summary>
		/// <returns>
		/// World recorder instance.</returns>
		public static WorldRecorder Instance
		{
			get {
				if (singleton == null)
					singleton = new WorldRecorder();
				return singleton;
			}
		}
		
		/// <summary>
		/// Reset singleton and returns new instance.</summary>
		/// <returns>
		/// World recorder instance.</returns>
		/// <remarks>
		/// Internal use only.</remarks>
		public static WorldRecorder NewInstance()
		{
			singleton = new WorldRecorder();
			return singleton;
		}
		
		/// <summary>
		/// Persist WorldRecorder's actions in a file thanks to Protobuf-Net serialization.</summary>
		/// <param name="path"> The path of the file where you want to save the actions.</param>
		public static void Persist(TerraMap map, string path)
		{
			if (singleton == null) {
				Debug.LogError("[TerraVol] WorldRecorder's singleton is null");
				return;
			}
			
			string fullpath = path;
			if (System.IO.File.Exists (fullpath)) {
				System.IO.File.Delete (fullpath);
			}
			
			singleton.worldMinY = map.Chunks.MinY;
			singleton.worldMaxY = map.Chunks.MaxY;
			
			System.IO.FileStream stream = System.IO.File.Create (fullpath);
			ProtoBuf.Serializer.Serialize<WorldRecorder> (stream, singleton);
			stream.Close ();
		}
		
		/// <summary>
		/// Load WorldRecorder's actions from a file thanks to Protobuf-Net deserialization.</summary>
		/// <param name="path"> The path of the file from which you want to load the actions.</param>
		/// <returns> True if loading was successful. False otherwise</returns>
		public static bool Load(TerraMap map, string path)
		{
			string fullpath = path;
			if (!System.IO.File.Exists (fullpath)) {
				Debug.LogError("[TerraVol] File doesn't exist: "+fullpath);
				return false;
			}
			
			System.IO.FileStream stream = System.IO.File.OpenRead (fullpath);
			singleton = ProtoBuf.Serializer.Deserialize<WorldRecorder> (stream);
			stream.Close ();
			
			map.Chunks.MinY = singleton.worldMinY;
			map.Chunks.MaxY = singleton.worldMaxY;
			
			return true;
		}
		
		/// <summary>
		/// Restore the effect of all actions on a column.</summary>
		/// <param name="cx"> X coordinate of column</param>
		/// <param name="cz"> Z coordinate of column</param>
		public void RestoreColumn (int cx, int cz)
		{
			if (actions == null)
				return;
			
			for (int y=worldMinY; y < worldMaxY; y++) {
				Vector3i key = new Vector3i(cx, y, cz);
				List<ActionData> actionList;
				if (actions.TryGetValue(key, out actionList) && actionList != null) {
					foreach (ActionData action in actionList) {
						action.Do(true, cx, cz);
					}
				}
			}
		}
		
		/// <summary>
		/// Perform an action. See ActionData documentation for more information.</summary>
		/// <param name="action"> Action to perform.</param>
		public void PerformAction (ActionData action)
		{
			action.Do(false, 0, 0);
			ReportBackAction(action);
		}
		
		/// <summary>
		/// Store the list of chunks affected by the action.</summary>
		/// <param name="action"> Action to report.</param>
		private void ReportBackAction (ActionData action)
		{
			if (actions == null)
				actions = new Dictionary<Vector3i, List<ActionData>>(new Vector3iComparer());
			
			foreach (Vector3i chunkWorldPos in action.AffectedVirtualChunks) {
				List<ActionData> actionList;
				if (!actions.TryGetValue(chunkWorldPos, out actionList)) {
					actionList = new List<ActionData>();
					actions.Add(chunkWorldPos, actionList);
				} else if (actionList == null) {
					actions.Remove(chunkWorldPos);
					actionList = new List<ActionData>();
					actions.Add(chunkWorldPos, actionList);
				}
				actionList.Add(action);
			}
			
			if (actionsOrdered == null)
				actionsOrdered = new List<ActionData>();
			actionsOrdered.Add(action);
		}
		
		/// <summary>
		/// Undo last actions.</summary>
		/// <param name="lastIndex"> Index of action to undo. All actions which have a higher index will be undone too.</param>
		public void UndoLastAction(TerraMap map, int lastIndex)
		{
			if (actionsOrdered == null || actionsOrdered.Count == 0 || actions == null)
				return;
			
			while (actionsOrdered.Count > lastIndex && actionsOrdered.Count != 0) {
				ActionData action = actionsOrdered[actionsOrdered.Count-1];
				actionsOrdered.RemoveAt(actionsOrdered.Count-1);
				
				foreach (Vector3i chunkWorldPos in action.AffectedVirtualChunks) {
					List<ActionData> actionList;
					if (actions.TryGetValue(chunkWorldPos, out actionList) && actionList != null) {
						actionList.Remove(action);
					}
				}
			}
			
			Persist(map, LOAD_UNDO_PATH);
			TerraMap.Instance.Reload(true);
		}
		
	}
	
}