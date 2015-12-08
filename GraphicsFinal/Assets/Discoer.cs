using UnityEngine;
using System.Collections;

public class Discoer : MonoBehaviour 
{
    public float lowerBound;
    public float upperBound;

    private bool buildUp;

    public float buildUpDelta;

    private float goal;

    private float lerpAmount = 0;

    void Start()
    {
        goal = upperBound;
        GetComponent<Renderer>().material.SetFloat("_SliceAmount", 0);
    }
    void Update()
    {

        lerpAmount = Mathf.MoveTowards(lerpAmount,
            buildUp ? upperBound : lowerBound,
            buildUpDelta);

        if (lerpAmount == lowerBound || lerpAmount == upperBound)
        {
            buildUp = !buildUp;
        }

        GetComponent<Renderer>().material.SetFloat("_SliceAmount", lerpAmount);


        /*
        float SliceAmount = GetComponent<Renderer>().material.GetFloat("_SliceAmount");

        float lerp = Mathf.Lerp(SliceAmount, goal, Time.deltaTime);
        if (lerp > upperBound * .99)
        {
            goal = lowerBound;
            GetComponent<Renderer>().material.SetFloat("_SliceAmount",upperBound *.98f);
        }
        else if (lerp < upperBound * .99f)
        {
            goal = upperBound;
            GetComponent<Renderer>().material.SetFloat("_SliceAmount", upperBound * .98f);
        }
        

        GetComponent<Renderer>().material.SetFloat("_SliceAmount", lerp);
        */
    }
}
