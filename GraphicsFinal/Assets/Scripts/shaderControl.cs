using UnityEngine;
using System.Collections;

public class shaderControl : MonoBehaviour {
    public float index = 0.0f;
    public Renderer rend;
    // Use this for initialization
	void Start () {
        rend = GetComponent<Renderer>();
       // rend.material.shader = Shader.Find("LiquidCloakShader");
	}
	
	// Update is called once per frame
	void Update () {
        index = Mathf.PingPong(Time.time, 0.2f)+1.0f;
        rend.material.SetFloat("_IndexRefract", index);
	}
}
