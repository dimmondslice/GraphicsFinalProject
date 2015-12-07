using UnityEngine;
using System.Collections;

public class Discoer : MonoBehaviour 
{
    public float lowerBound;
    public float upperBound;

    void Update()
    {
        float SliceAmount = GetComponent<Renderer>().material.GetFloat("_SliceAmount");

        //float lerp = Mathf.Lerp(SliceAmoun)

        //GetComponent<Renderer>().material.SetFloat("_SliceAmount");
    }
}
