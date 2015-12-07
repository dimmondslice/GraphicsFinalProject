using UnityEngine;
using System.Collections;

public class Destroy : MonoBehaviour {
    public float Timer = 5;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        Timer -= Time.deltaTime;

        if (Timer <= 0.0f)
        {
            Destroy(gameObject);
        }
	}
}
