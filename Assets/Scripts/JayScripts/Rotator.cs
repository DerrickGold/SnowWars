using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Rotator : MonoBehaviour {

	public Text buffText;
	public Text buffIcon;
	private Vector3 originalPos;
	public float buffBounceSpeed;
	public float buffBounceHeight;
	void Start()
	{
		buffBounceSpeed = 2f;
		buffBounceHeight = 2f;
		originalPos = transform.position;
		buffText = (Text)(transform.parent.transform.FindChild ("Canvas").FindChild("STEALTH").GetComponent<Text>());
		buffText.gameObject.SetActive (false);
		buffIcon = (Text)(transform.parent.transform.FindChild ("Canvas").FindChild("ICON").GetComponent<Text>());
		buffIcon.gameObject.SetActive (false);
	}

	// Update is called once per frame
	void Update () 
	{
		float t = Time.time;
		transform.Rotate (new Vector3(15, 30, 45) * Time.deltaTime);
		//transform.position += Vector3.up * Time.deltaTime * Mathf.Abs(Mathf.Sin(Time.deltaTime));
		transform.position = new Vector3 (
			originalPos.x,
			originalPos.y + buffBounceHeight * Mathf.Abs (Mathf.Sin (Time.time*buffBounceSpeed)),
			originalPos.z);
	}
}
