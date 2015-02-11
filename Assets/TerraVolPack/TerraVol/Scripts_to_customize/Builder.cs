// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using TerraVol;
using System.Collections;
using System.Collections.Generic;

[AddComponentMenu("TerraVol/In-Game Builder Tool")]
public class Builder : MonoBehaviour
{		
	// Affect brush and actions
	private Vector3 size = new Vector3(5f, 5f, 5f);
	private Vector3i isize = new Vector3i(4, 4, 4);
	public float strength = 0.3f;
	public float maxModifyDistance = 1000f;
	public float flattenHeight = 0f;
	public ActionDataType currentAction = ActionDataType.Dig;
	private ActionDataType lastAction = ActionDataType.Dig;
	public BrushType brushType = BrushType.Sphere;
	private BrushType lastBrushType = BrushType.Sphere;
		
	// Misc
	private TerraMap map;
	private int currentBlockIndex = 0;
	private Block currentBlock = null;
	private Transform retAdd = null;
	private Transform retDel = null;
	private Transform currentReticle = null;
	public bool deltaEdit = true;
	public bool lockCursor = true;
	public bool displayReticle = false;
	public bool acting = false;
	public bool oneActionPerClick = false;
	public bool affectUndestructibleBlocks = false;
	
	// GUI
	private int VertStart = 20;
	private int LeftStart = 20;
	private bool displayOptions = true;
	private bool displayInstructions = false;
		
	public TerraMap TerraMap {
		get {
			return map;
		}
	}
	
	public bool LockCursor {
		get {
			return lockCursor;
		}
	}
		
	void Awake ()
	{
		map = (TerraMap)GameObject.FindObjectOfType (typeof(TerraMap));
		
		if (this.TerraMap == null) {
			enabled = false;
			Debug.LogError ("[TerraVol] No object with TerraMap component has been found.");
			return;
		}
	}
		
	void Start ()
	{
		currentBlockIndex = 0;
		SetSelectedBlock (currentBlockIndex);
	}
	
	// Update is called once per frame
	void Update ()
	{
		// Make sure the GUI isn't being clicked
		if (GUIUtility.hotControl == 0) {
			Vector3? hit = GetFireTarget();
			
			// Show reticle
			if (displayReticle)
				Show3DBrush( hit );
			
			// Perform action when player clicks
			if (Input.GetMouseButtonDown (0) && (!oneActionPerClick || !acting)) {
				acting = true;
			} else if (Input.GetMouseButtonUp (0)) {
				acting = false;
			}
			
			if (acting) {
				DoAction( hit );
				if (oneActionPerClick)
					acting = false;
			}
			
			// Throw a ball
			if (lockCursor && Input.GetMouseButtonDown (1)){
				GameObject ball = GameObject.CreatePrimitive(PrimitiveType.Sphere);
				ball.transform.localScale = new Vector3(2,2,2);
				ball.transform.position = Camera.main.transform.position;
				ball.transform.rotation = Camera.main.transform.rotation;
				ball.transform.position += ball.transform.forward * 6f;
				ball.AddComponent<Rigidbody>();
				ball.rigidbody.velocity = ball.transform.forward * 25f;
				ball.renderer.material.color = new Color(Random.Range(0f, 1f), Random.Range(0f, 1f), Random.Range(0f, 1f), 1f);
			}
		}
	}
	
	// GUI
	void OnGUI ()
	{
		if (GUI.Button(new Rect (LeftStart, VertStart, 100, 25), "Options"))
			displayOptions = !displayOptions;
		
		if (GUI.Button(new Rect (LeftStart + 120, VertStart, 100, 25), "Instructions"))
			displayInstructions = !displayInstructions;
		
		if (GUI.Button(new Rect (LeftStart + 240, VertStart, 150, 25), "Change type of block >")) {
			SetSelectedBlock (++currentBlockIndex);
			if (currentBlock == null) {
				currentBlockIndex = 0;
				SetSelectedBlock (currentBlockIndex);
			}
		}
			
		if (GUI.Button(new Rect (LeftStart + 410, VertStart, 100, 25), "Save Map"))
			SaveTerraMap ();
		
		if (displayOptions)
		{
			displayReticle = GUI.Toggle (new Rect (LeftStart, VertStart + 50, 200, 25), displayReticle, "Display reticles");
			if (!displayReticle)
				DestroyBrush ();
			
			oneActionPerClick = GUI.Toggle (new Rect (LeftStart, VertStart + 75, 200, 25), oneActionPerClick, "One action per click");
			lockCursor = !GUI.Toggle (new Rect (LeftStart, VertStart + 100, 200, 25), !lockCursor, "Use mouse pointer to target");
			affectUndestructibleBlocks = GUI.Toggle(new Rect (LeftStart, VertStart + 125, 200, 25), affectUndestructibleBlocks, "Affect undestructible blocks");
			deltaEdit = GUI.Toggle(new Rect (LeftStart, VertStart + 150, 200, 25), deltaEdit, "Delta-edit");
			
			if (deltaEdit) {
				GUI.Label (new Rect (LeftStart, VertStart + 175, 100, 25), "Strength ");
				strength = GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 175, 200, 25), strength, 0, 10f);
			}
			
			if (brushType == BrushType.Cube || brushType == BrushType.SharpCube) {
				GUI.Label (new Rect (LeftStart, VertStart + 200, 100, 25), "Cube size X ");
				isize.x = (int)GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 200, 200, 25), isize.x * Chunk.SIZE_X_BLOCK, 2*Chunk.SIZE_X_BLOCK, 10*Chunk.SIZE_X_BLOCK) / Chunk.SIZE_X_BLOCK;
				GUI.Label (new Rect (LeftStart, VertStart + 225, 100, 25), "Cube size Y ");
				isize.y = (int)GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 225, 200, 25), isize.y * Chunk.SIZE_Y_BLOCK, 2*Chunk.SIZE_Y_BLOCK, 10*Chunk.SIZE_Y_BLOCK) / Chunk.SIZE_Y_BLOCK;
				GUI.Label (new Rect (LeftStart, VertStart + 250, 100, 25), "Cube size Z ");
				isize.z = (int)GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 250, 200, 25), isize.z * Chunk.SIZE_Z_BLOCK, 2*Chunk.SIZE_Z_BLOCK, 10*Chunk.SIZE_Z_BLOCK) / Chunk.SIZE_Z_BLOCK;
			} else if (brushType == BrushType.Cylinder) {
				GUI.Label (new Rect (LeftStart, VertStart + 200, 100, 25), "Cylinder radius ");
				size.x = GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 200, 200, 25), size.x, 0, 20f);
				GUI.Label (new Rect (LeftStart, VertStart + 225, 100, 25), "Cylinder height ");
				isize.y = (int)GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 225, 200, 25), isize.y * Chunk.SIZE_Y_BLOCK, 2*Chunk.SIZE_Y_BLOCK, 10*Chunk.SIZE_Y_BLOCK) / Chunk.SIZE_Y_BLOCK;
			} else {
				GUI.Label (new Rect (LeftStart, VertStart + 200, 100, 25), "Sphere radius ");
				size.x = GUI.HorizontalSlider (new Rect (LeftStart + 100, VertStart + 200, 200, 25), size.x, Chunk.SIZE_X_BLOCK, 20f);
			}
			
			brushType = (BrushType)GUI.SelectionGrid(new Rect (LeftStart, VertStart+300, 150, 150), 
											(int)brushType, BrushType.GetNames(typeof(BrushType)), 1);
			
			currentAction = (ActionDataType)GUI.SelectionGrid(new Rect (LeftStart+170, VertStart+300, 150, 150), 
											(int)currentAction, ActionDataType.GetNames(typeof(ActionDataType)), 1);
		}
		
		if (displayInstructions)
		{
			string windowText = "<b>Instructions:</b>\n" +
				"W A S D: movement keys\n" +
				"\n" +
				"<b>If 'Use mouse pointer to target' is enabled:</b>\n" +
				"Left Click: perform action\n" +
				"Right Click: mouse look\n" +
				"\n" +
				"<b>If 'Use mouse pointer to target' is disabled:</b>\n" +
				"Left Click: perform action at the center of the screen\n" +
				"Right Click: throw a ball\n" +
				"\n" +
				"<b>Options:</b>\n" +
				"Display reticles: toggles Reticles on/off\n" +
				"One action per click: allow continuous editing if disabled\n" +
				"Use mouse pointer to target: toggles terraforming from mouse pointer\n" +
				"Delta-edit: edit terrain with smaller/smoother changes if enabled\n";
			
			GUI.Box (new Rect(Screen.width - 400, VertStart, 400, VertStart + 400), windowText);
		}
			
	}
	
	/**
	 * Perform a raycast and returns the point where the player is targeting
	 */
	private Vector3? GetFireTarget()
	{
		Vector3 s = GetActualSizeForCurrentBrush();
		float offset = Mathf.Max( s.x, Mathf.Max( s.y, s.z ) ) - Chunk.SIZE_X_BLOCK;
		
		Ray ray;
		if (!lockCursor) {
			ray = Camera.main.ScreenPointToRay (Input.mousePosition);
		} else {
			ray = new Ray (Camera.main.transform.position + Camera.main.transform.forward, Camera.main.transform.forward);
		}

		RaycastHit hit = new RaycastHit ();
		if (Physics.Raycast (ray.origin, ray.direction, out hit, maxModifyDistance)) {
			if (currentAction == ActionDataType.Dig || currentAction == ActionDataType.Paint || hit.distance > offset) {
				return hit.point + ray.direction;
			}
		}
		return null;
	}
	
	/**
	 * Load recticles from prefabs
	 */
	private void LoadReticle()
	{
		GameObject retAddPrefab = Resources.Load("RetAdd") as GameObject;
		GameObject retAddObj = (GameObject) Instantiate(retAddPrefab, new Vector3(0, -1, 0), Quaternion.identity);
		retAdd = retAddObj.transform;
		
		GameObject retDelPrefab = Resources.Load("RetDel") as GameObject;
		GameObject retDelObj = (GameObject) Instantiate(retDelPrefab, new Vector3(0, -1, 2), Quaternion.identity);
		retDel = retDelObj.transform;
	}
	
	/**
	 * Perform current action with current brush
	 */
	public void DoAction (Vector3? point)
	{
		if (point.HasValue) {
			Vector3 s = GetActualSizeForCurrentBrush();
			Vector3i actionPos;
			if (displayReticle && currentReticle != null)
				actionPos = Chunk.ToTerraVolPositionFloor(currentReticle.position);
			else
				actionPos = Chunk.ToTerraVolPositionFloor(point.Value);
			
			if (!deltaEdit) {
				// Perform action
				WorldRecorder.Instance.PerformAction(new ActionData(actionPos, s, currentBlock,
						currentAction, brushType, false, affectUndestructibleBlocks));
			} else {
				// Perform action
				WorldRecorder.Instance.PerformAction(new ActionData(actionPos, s, currentBlock,
						currentAction, brushType, strength * Time.deltaTime, false, affectUndestructibleBlocks));
			}
		}
	}
	
	
	private Vector3 GetActualSizeForCurrentBrush ()
	{
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
		return s;
	}
		
	private void SetSelectedBlock (int index)
	{
		currentBlock = this.TerraMap.GetBlockSet ().GetBlock (index);
	}
	
	/**
	 * Saves map to a dummy location
	 */
	public bool SaveTerraMap ()
	{
			string path = "Assets/TerraVolPack/defaultSaveLocation/myAwesomeMap.terra";
			this.TerraMap.Save( path );
			Debug.Log ("[TerraVol] TerraMap saved to: "+path);
			return true;
	}
	
	/**
	 * Destroy reticles
	 */
	private void DestroyBrush ()
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
	
	/**
	 * Display reticle at the given position
	 */
	private void Show3DBrush (Vector3? point)
	{
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
				currentReticle.position = new Vector3((posX-1) * Chunk.SIZE_X_BLOCK, 
													(posY-1) * Chunk.SIZE_Y_BLOCK, 
													(posZ-1) * Chunk.SIZE_Z_BLOCK);
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
