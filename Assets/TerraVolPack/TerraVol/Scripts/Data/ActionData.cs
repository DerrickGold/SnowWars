// == TERRAVOL ==
// Copyright(c) Olivier Fuxet, 2013. Do not redistribute.
// terravol.unity@gmail.com
using UnityEngine;
using ProtoBuf;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
	/// <summary>
	/// List of possible actions.</summary>
	public enum ActionDataType {
		Dig,
		Build,
		Flatten,
		Paint
	};
	
	/// <summary>
	/// List of brush formats.</summary>
	public enum BrushType {
		Sphere,
		Cube,
		SharpCube,
		Cylinder
	};
	
	/// <summary>
	/// Contains all data and logic to perform actions on the terrain.</summary>
	[ProtoContract]
	public class ActionData
	{
		private static int lastId = 0;
		
		/// <summary>Unique ID</summary>
		[ProtoMember(1, IsRequired=true)]
		private int id;
		
		/// <summary>Position (center) in block's units where the action is performed.</summary>
		[ProtoMember(2, IsRequired=true)]
		private Vector3i position;
		
		/// <summary>
		/// Size of action in world's unit.</summary>
		/// <remarks>
		/// Cube size: size.x, size.y, size.z<br/>
		/// Sphere size: size.x = range<br/>
		/// Cylinder size: size.x = range, size.y
		/// </remarks>
		[ProtoMember(3, IsRequired=true)]
		private ProtoVector3 size;
		
		/// <summary>Type of action</summary>
		[ProtoMember(4, IsRequired=true)]
		private ActionDataType type;
		
		/// <summary>Type of brush used for this action</summary>
		[ProtoMember(5, IsRequired=true)]
		private BrushType brush;
		
		/// <summary>List of chunks' position that are affected by this action</summary>
		[ProtoMember(6, IsRequired=true)]
		private List<Vector3i> affectedVirtualChunks;
		
		/// <summary>Type of block that will replace current types of blocks</summary>
		[ProtoMember(7, IsRequired=true)]
		private string blockName;
		
		/// <summary>True if isovalue should be added. False if it should be set</summary>
		[ProtoMember(8, IsRequired=true)]
		private bool addIso;
		
		/// <summary>If addIso is true, this is the value that will be added to isovalues</summary>
		[ProtoMember(9, IsRequired=true)]
		private float isovalueToAdd;
		
		/// <summary>If true, all blocks will be affected even if they are undestructible</summary>
		[ProtoMember(10, IsRequired=true)]
		private bool force;
		
		private Block blockType;
		private List<ChunkData> affectedChunks;
		private TerraMap map;
		private bool createVegetation;
		
		// Empty constructor needed by Protobuf-Net
		public ActionData()
		{
		}
		
		[ProtoAfterDeserialization]
		public void OnDeserialized()
		{
			lastId = Mathf.Max(lastId, this.id);
			this.map = TerraMap.Instance;
			this.affectedChunks = new List<ChunkData>();
			this.blockType = map.blockSet.GetBlock(blockName);
			createVegetation = true;
		}
		
		/// <summary>
		/// Create a new action ready to be performed.</summary>
		/// <param name="position"> Absolute block position of the 'center' of the action.</param>
		/// <param name="size"> Size of brush. If brush is a cube, this is the size of the cube along X, Y and Z axis. If
		/// brush if a sphere, only size.x is taken into account as the radius of the sphere. If brush is a cylinder, 
		/// size.x is the radius of the cylinder and size.y is its height.</param>
		/// <param name="blockType"> Type of block that will replace current types of blocks.</param>
		/// <param name="type"> Type of action (ie. Dig/Build/Flatten/Paint).</param>
		/// <param name="brush"> Type of brush (ie. Cube/Sharp-cube/Sphere/Cylinder).</param>
		/// <param name="createVegetation"> If true, vegetation will be (re)created after action has been performed.</param>
		/// <param name="force"> If true, all blocks will be affected even if they are indestructible.</param>
		public ActionData (Vector3i position, Vector3 size, Block blockType, ActionDataType type, BrushType brush, bool createVegetation, bool force = false)
		{
			this.id = ++lastId;
			this.position = position;
			this.size = new ProtoVector3(size);
			this.blockType = blockType;
			this.blockName = blockType.Name;
			this.type = type;
			this.brush = brush;
			this.affectedChunks = new List<ChunkData>();
			this.affectedVirtualChunks = new List<Vector3i>();
			this.map = TerraMap.Instance;
			this.addIso = false;
			this.createVegetation = createVegetation;
			this.force = force;
		}
		
		/// <summary>
		/// Create a new action ready to be performed. Isovalue will be added to current isovalue of blocks.</summary>
		/// <param name="position"> Absolute block position of the 'center' of the action.</param>
		/// <param name="size"> Size of brush. If brush is a cube, this is the size of the cube along X, Y and Z axis. If
		/// brush if a shpere, only size.x is taken into acount as the radius of the sphere. If brush is a cylinder, 
		/// size.x is the radius of the cylinder and size.y is its height.</param>
		/// <param name="blockType"> Type of block that will replace current types of blocks.</param>
		/// <param name="type"> Type of action (ie. Dig/Build/Flatten/Paint).</param>
		/// <param name="brush"> Type of brush (ie. Cube/Sharp-cube/Sphere/Cylinder).</param>
		/// <param name="isovalueToAdd"> Value that must be added to current isovalue of blocks.</param>
		/// <param name="createVegetation"> If true, vegetation will be (re)created after action has been performed.</param>
		/// <param name="force"> If true, all blocks will be affected even if they are undestructible.</param>
		public ActionData (Vector3i position, Vector3 size, Block blockType, ActionDataType type, BrushType brush, float isovalueToAdd, bool createVegetation, bool force = false)
		{
			this.id = ++lastId;
			this.position = position;
			this.size = new ProtoVector3(size);
			this.blockType = blockType;
			this.blockName = blockType.Name;
			this.type = type;
			this.brush = brush;
			this.affectedChunks = new List<ChunkData>();
			this.affectedVirtualChunks = new List<Vector3i>();
			this.map = TerraMap.Instance;
			this.addIso = true;
			this.isovalueToAdd = isovalueToAdd;
			this.createVegetation = createVegetation;
			this.force = force;
		}
		
		/// <summary>Position (center) in block's units where the action is performed.</summary>
		public Vector3i Position {
			get {
				return position;
			}
			set {
				position = value;
			}
		}
		
		/// <summary>List of chunks' position that are affected by this action</summary>
		internal List<Vector3i> AffectedVirtualChunks {
			get {
				return affectedVirtualChunks;
			}
		}
		
		/// <summary>Perform action.</summary>
		/// <param name="onlyItself"> If true, action will only affect chunks which are in the column (cx, cz).</param>
		/// <param name="cx"> X coordinate in chunk's unit of te column to affect. Used only if onlyItself is true.</param>
		/// <param name="cz"> Z coordinate in chunk's unit of te column to affect. Used only if onlyItself is true.</param>
		public void Do (bool onlyItself, int cx, int cz)
		{
			// Perform action
			switch (type)
			{
				case ActionDataType.Dig:
					DoDigBuild (true, false, true, onlyItself, cx, cz);
					break;
				case ActionDataType.Build:
					DoDigBuild (false, false, true, onlyItself, cx, cz);
					break;
				case ActionDataType.Flatten:
					DoDigBuild (false, true, true, onlyItself, cx, cz);
					break;
				case ActionDataType.Paint:
					DoDigBuild (false, false, false, onlyItself, cx, cz);
					break;
			}
		}
		
		private void DoDigBuild (bool dig, bool flatten, bool affectIsovalue, bool onlyItself, int cx, int cz)
		{
			// Cube size: size.x, size.y, size.z
			// Sphere size: size.x = range
			// Cylinder size: size.x = range, size.y
			float range = 0;
			Vector3i start = Vector3i.zero;
			Vector3i end = Vector3i.zero;
			int blockPathAboveMe = 10000;
			
			
			// Compute range of effect and size of impacted area
			if (brush == BrushType.Cube || brush == BrushType.SharpCube)
			{
				range = size.x;
				Vector3i isize = new Vector3i(0.5f * new Vector3(	size.x / (float)Chunk.SIZE_X_BLOCK,
														size.y / (float)Chunk.SIZE_Y_BLOCK,
														size.z / (float)Chunk.SIZE_Z_BLOCK));
				start = position - isize;
				end = position + isize;
				blockPathAboveMe = start.y + 2;
			}
			else if (brush == BrushType.Sphere)
			{
				range = size.x;
				int irange = Mathf.RoundToInt(size.x / Chunk.SIZE_AVERAGE_BLOCK) + 2;
				start = position - irange * Vector3i.one;
				end = position + irange * Vector3i.one;
				blockPathAboveMe = start.y + 2;
			}
			else if (brush == BrushType.Cylinder)
			{
				range = size.x;
				int irange = Mathf.RoundToInt(size.x / Chunk.SIZE_AVERAGE_BLOCK) + 1;
				int isizeY = Mathf.RoundToInt(0.5f * size.y / (float)Chunk.SIZE_Y_BLOCK);
				start = position - new Vector3i(irange, isizeY, irange);
				end = position + new Vector3i(irange, isizeY, irange);
				blockPathAboveMe = start.y + 2;
			}
			
			int yFlatten = Mathf.RoundToInt(size.y / (float)Chunk.SIZE_Y_BLOCK);
			float rangeSquared = range * range;
			float rangeSquaredPlusOne = (range + 1.5f * Chunk.SIZE_AVERAGE_BLOCK) * (range + 1.5f * Chunk.SIZE_AVERAGE_BLOCK);
			
			for (int x=start.x; x <= end.x; x++) {
				for (int y=start.y; y <= end.y; y++) {
					for (int z=start.z; z <= end.z; z++) {
						Vector3i current = new Vector3i(x, y, z);
						Vector3i cPos = Chunk.ToChunkPosition(current);
						Vector3i locPos = Chunk.ToLocalPosition( current );
						
						// Map Size limit
						if (map.limitSize && (cPos.x < map.minX || cPos.x > map.maxX || cPos.z < map.minZ || cPos.z > map.maxZ))
							continue;
						
						// Prevent digging under the terrain
						if (y < map.minY * Chunk.SIZE_Y + 2)
							continue;
						
						if (brush == BrushType.Cube || brush == BrushType.SharpCube)
						{
							// Get chunk
							ChunkData chunk = map.GetChunkDataInstance( cPos );
							
							if (chunk != null && (!onlyItself || (chunk.Position.x == cx && chunk.Position.z == cz))) {
								BlockData block = chunk.GetBlock(locPos);
								
								if (block != null) {
									if (block.IsDestructible || force) {
										if (affectIsovalue && x != start.x && x != end.x
												&& y != start.y && y != end.y
												&& z != start.z && z != end.z)
										{
											// Path should be blocked or not?
											bool isPathBlocked = false;
											if (block.IsInside && current.y > blockPathAboveMe && (x <= start.x + 1 || x >= end.x - 1 || z <= start.z + 1 || z >= end.z - 1))
											{
												isPathBlocked = true;
											}
											
											if (!addIso) {
												// Compute new isovalue
												float isovalue;
												if (!flatten) {
													if (brush == BrushType.Cube)
														isovalue = (dig ? 1f : -1f);
													else
														isovalue = (dig ? 0.0001f : -0.0001f);
												} else {
													if (brush == BrushType.Cube)
														isovalue = (current.y > yFlatten ? 1f : -1f);
													else
														isovalue = (current.y > yFlatten ? 0.0001f : -0.0001f);
												}
												
												// Apply to block data
												BlockData.SetIsovalue(block, chunk, isovalue, blockType, isPathBlocked);
											} else {
												// Apply to block data
												BlockData.AddIsovalue(block, chunk, (dig ? isovalueToAdd : -isovalueToAdd), blockType, isPathBlocked);
											}
										} else {
											block.Block = blockType;
										}
									}
								} else {
									// Create block
									chunk.SetBlock((dig || !affectIsovalue || flatten) ? 1f : -1f, blockType, locPos);
								}
								AddAffectedChunk(chunk, locPos, onlyItself);
							}
							
						}
						else if (brush == BrushType.Sphere)
						{
							
							float distanceSquared = Chunk.SIZE_AVERAGE_BLOCK * Chunk.SIZE_AVERAGE_BLOCK * position.DistanceSquared( current );
							if (distanceSquared < rangeSquaredPlusOne) {
								// Get chunk
								ChunkData chunk = map.GetChunkDataInstance( cPos );
								
								if (chunk != null && (!onlyItself || (chunk.Position.x == cx && chunk.Position.z == cz))) {
									BlockData block = chunk.GetBlock(locPos);
									
									if (block != null) {
										if (block.IsDestructible || force) {
											if (affectIsovalue && distanceSquared < rangeSquared) {
												float distance = Mathf.Sqrt(distanceSquared);
												
												// Path should be blocked or not?
												bool isPathBlocked = false;
												if (block.IsInside && current.y > blockPathAboveMe && Mathf.Abs(range - distance) < Chunk.SIZE_AVERAGE_BLOCK)
												{
													isPathBlocked = true;
												}
												
												if (!addIso) {
													// Compute new isovalue
													float isovalue;
													if (!flatten) {
														isovalue = (range - distance) / range;
														if (dig)
															isovalue = Mathf.Max(isovalue, block.Isovalue);
														else
															isovalue = Mathf.Min(isovalue, block.Isovalue);
													} else {
														isovalue = (current.y > yFlatten ? 1f : -1f);
													}
													
													// Apply to block data
													BlockData.SetIsovalue(block, chunk, isovalue, blockType, isPathBlocked);
												} else {
													// Apply to block data
													BlockData.AddIsovalue(block, chunk, (dig ? isovalueToAdd : -isovalueToAdd), blockType, isPathBlocked);
												}
											} else {
												block.Block = blockType;
											}
										}
									} else {
										// Create block
										chunk.SetBlock((dig || !affectIsovalue || flatten) ? 1f : -1f, blockType, locPos);
									}
									AddAffectedChunk(chunk, locPos, onlyItself);
								}
							}
							
						}
						else if (brush == BrushType.Cylinder)
						{
							
							float distanceSquared = Chunk.SIZE_AVERAGE_BLOCK * Chunk.SIZE_AVERAGE_BLOCK * position.FlatDistanceSquared( current );
							if (distanceSquared < rangeSquaredPlusOne) {
								// Get chunk
								ChunkData chunk = map.GetChunkDataInstance( cPos );
								
								if (chunk != null && (!onlyItself || (chunk.Position.x == cx && chunk.Position.z == cz))) {
									BlockData block = chunk.GetBlock(locPos);
									
									if (block != null) {
										if (block.IsDestructible || force) {
											if (affectIsovalue && distanceSquared < rangeSquared) {
												float distance = Mathf.Sqrt(distanceSquared);
												bool isPathBlocked = false;
												
												// Path should be blocked or not?
												if (block.IsInside && current.y > blockPathAboveMe && Mathf.Abs(range - distance) < Chunk.SIZE_AVERAGE_BLOCK)
												{
													isPathBlocked = true;
												}
												
												if (!addIso) {
													float isovalue;
													
													
													if (!flatten) {
														// Compute new isovalue
														isovalue = (range - distance) / range;
														
														// Check old isovalue
														if (dig)
															isovalue = Mathf.Max(isovalue, block.Isovalue);
														else
															isovalue = Mathf.Min(isovalue, block.Isovalue);
													} else {
														isovalue = (current.y > yFlatten ? 1f : -1f);
													}
													
													// Apply to block data
													BlockData.SetIsovalue(block, chunk, isovalue, blockType, isPathBlocked);
												} else {
													// Apply to block data
													BlockData.AddIsovalue(block, chunk, (dig ? isovalueToAdd : -isovalueToAdd), blockType, isPathBlocked);
												}
											} else {
												block.Block = blockType;
											}
										}
									} else {
										// Create block
										chunk.SetBlock((dig || !affectIsovalue || flatten) ? 1f : -1f, blockType, locPos);
									}
									AddAffectedChunk(chunk, locPos, onlyItself);
								}
							}
							
						}
						
					} // loop over Z
				} // loop over Y
			} // loop over X
			
			// Recompute chunk mesh
			if (!onlyItself) {
				foreach (ChunkData chunk in affectedChunks) {
					// Build chunk with Marching Cubes and add vegetation if needed
					chunk.GetChunkInstance().BuildImmediately (createVegetation);
					
					if (!createVegetation) {
						chunk.GetChunkInstance().ClearVegetationInRange(
							new Vector3i(position.x * Chunk.SIZE_X_BLOCK, position.y * Chunk.SIZE_Y_BLOCK, position.z * Chunk.SIZE_Z_BLOCK) , 
							range + Chunk.SIZE_AVERAGE_BLOCK * 3f );
					}
				}
			}
		}
		
		
		private void AddAffectedChunk(ChunkData chunk, Vector3i locPos, bool onlyItself)
		{
			if (!onlyItself && chunk != null) {
				if (!affectedChunks.Contains(chunk))
					affectedChunks.Add(chunk);
				if (!affectedVirtualChunks.Contains(chunk.Position))
					affectedVirtualChunks.Add(chunk.Position);
				
				if (locPos.x == 0) {
					AddAffectedNeighbour(chunk, new Vector3i(-1, 0, 0));
					if (locPos.y == 0) {
						AddAffectedNeighbour(chunk, new Vector3i(0, -1, 0));
						AddAffectedNeighbour(chunk, new Vector3i(-1, -1, 0));
						if (locPos.z == 0) {
							AddAffectedNeighbour(chunk, new Vector3i(0, 0, -1));
							AddAffectedNeighbour(chunk, new Vector3i(-1, 0, -1));
							AddAffectedNeighbour(chunk, new Vector3i(0, -1, -1));
							AddAffectedNeighbour(chunk, new Vector3i(-1, -1, -1));
						}
					} else {
						if (locPos.z == 0) {
							AddAffectedNeighbour(chunk, new Vector3i(0, 0, -1));
							AddAffectedNeighbour(chunk, new Vector3i(-1, 0, -1));
						}
					}
				} else {
					if (locPos.y == 0) {
						AddAffectedNeighbour(chunk, new Vector3i(0, -1, 0));
						if (locPos.z == 0) {
							AddAffectedNeighbour(chunk, new Vector3i(0, 0, -1));
							AddAffectedNeighbour(chunk, new Vector3i(0, -1, -1));
						}
					} else {
						if (locPos.z == 0) {
							AddAffectedNeighbour(chunk, new Vector3i(0, 0, -1));
						}
					}
				}
			}
		}
		
		
		private void AddAffectedNeighbour(ChunkData chunk, Vector3i dir)
		{
			ChunkData neighbour = chunk.GetNeighbourInstance(dir);
			if (neighbour != null && 
				(!map.limitSize || (neighbour.Position.x >= map.minX && neighbour.Position.x <= map.maxX &&
									neighbour.Position.z >= map.minZ && neighbour.Position.z <= map.maxZ)))
			{
				if (!affectedChunks.Contains(neighbour))
					affectedChunks.Add(neighbour);
				if (!affectedVirtualChunks.Contains(neighbour.Position))
					affectedVirtualChunks.Add(neighbour.Position);
			}
		}
		
		
		public override bool Equals (object other)
		{
			if (!(other is ActionData))
				return false;
			ActionData c = (ActionData)other;
			return id == c.id;
		}
		
		public override int GetHashCode ()
		{
			return id;
		}
		
	}
	
}