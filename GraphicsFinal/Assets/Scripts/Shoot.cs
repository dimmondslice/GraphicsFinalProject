using UnityEngine;
using System.Collections;

public class Shoot : MonoBehaviour {

    public GameObject projectile;
    public Color[] colors;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetMouseButtonDown(0)) {
            GameObject proj = (GameObject)Instantiate(projectile, transform.position + transform.forward, Quaternion.identity);
            proj.GetComponent<Renderer>().material.color = colors[Random.Range(0, colors.Length)];
            proj.GetComponent<Rigidbody>().AddForce((transform.forward * 10), ForceMode.Impulse);
        }
	}
}
