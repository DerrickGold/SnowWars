using UnityEngine;
using System.Collections;

public class SpikeFall : MonoBehaviour {

	public float FALL_SPEED = 1f;
	private Vector3 originalPosition;
	private bool fallen;
	private Transform spikes;

	// Use this for initialization
	void Start () {
		//originalPosition = transform.position;
		spikes = transform.Find ("Trap");
		originalPosition = spikes.position;
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnTriggerEnter(Collider col){
		if (col.gameObject.tag.Contains ("Team")) StartCoroutine ("fall");
	}

	public IEnumerator fall(){
		while (spikes.position.y > 65f) {
			spikes.position = new Vector3(originalPosition.x, spikes.position.y-FALL_SPEED, originalPosition.z );
			yield return null;
		}
		spikes.position = originalPosition;
	}
}
