using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace TerraVol
{
		
	public class PrefabPool
	{
		private readonly Stack<GameObject> items = new Stack<GameObject>();
		private readonly object sync = new object();
		private readonly GameObject prefab;
		private int totalInstanciatedCount = 0;
		
		public int Count {
			get { return items.Count; }
		}
		public int TotalInstanciatedCount {
			get { return totalInstanciatedCount; }
		}

		public PrefabPool(GameObject prefab) {
			this.prefab = prefab;
		}
		
		public GameObject Get()
		{
			lock (sync)
			{
				if (items.Count == 0) {
					totalInstanciatedCount++;
					return (GameObject) GameObject.Instantiate(prefab);
				} else {
					GameObject item = items.Pop();
					return item;
				}
			}
		}
		
		public void Free(GameObject item)
		{
			if (item != null) {
				item.transform.position = Vector3.zero;
				item.transform.parent = null;
				if (item.renderer)
					item.renderer.enabled = false;
				lock (sync)
				{
					items.Push(item);
				}
			}
		}
		
	}
	
}