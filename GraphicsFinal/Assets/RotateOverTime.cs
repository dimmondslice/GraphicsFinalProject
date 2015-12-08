using UnityEngine;
using System.Collections;

public class RotateOverTime : MonoBehaviour {

    public float rotateAmount;

    private Quaternion rotQuat;

    void Awake() {
        rotQuat = Quaternion.AngleAxis(rotateAmount, Vector3.up);
    }

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        rotQuat = Quaternion.AngleAxis(rotateAmount, Vector3.up);


        gameObject.transform.rotation *= rotQuat;
    }
}
