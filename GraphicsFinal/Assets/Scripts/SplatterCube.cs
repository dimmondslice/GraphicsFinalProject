using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;

public class SplatterCube : MonoBehaviour {

    public Texture2D[] splatTextures;

    void OnCollisionEnter(Collision collision) {
        if (collision.transform.tag != "Splat") {
            return;
        }
        //for the first point of contact, calculate the uv where we hit and add a splat texture there
        //then destroy the projectile
        foreach (ContactPoint contact in collision.contacts) {
            RaycastHit hitinfo;
            Ray ray = new Ray(contact.point + contact.normal, -contact.normal);
            if (contact.otherCollider.Raycast(ray, out hitinfo, 1.1f)) {
                Color splatColor = GetComponent<Renderer>().material.color;
                AddSplat(collision.transform, hitinfo.textureCoord, splatColor);
                Destroy(gameObject);
                break;
            }
        }
    }


    void AddSplat(Transform other, Vector2 texCoord, Color col) {
        Texture2D splatTex = splatTextures[UnityEngine.Random.Range(0, splatTextures.Length)];
        Texture2D otherTex = (Texture2D)Instantiate(other.GetComponent<Renderer>().material.GetTexture("_SplatTex"));
        int startX = (int)(otherTex.width * texCoord.x) - (int)(splatTex.width / 2f);
        int startY = (int)(otherTex.height * texCoord.y) - (int)(splatTex.height / 2f);

        //tells us whether or not we want the splat to wrap if we hit an edge
        bool wrap = other.GetComponent<Renderer>().material.GetFloat("_Wrap") == 0 ? false : true;
        bool leftSide = false;
        bool topSide = false;

        //if the starting point is negative and we aren't wrapping, we only want to draw the left side
        if (startX < 0) {
            leftSide = true;
            startX += otherTex.width;
        }
        if(startY < 0) {
            topSide = true;
            startY += otherTex.height;
        }
    

        Color32[] splatColors = splatTex.GetPixels32();
        Color32[] sourceColors = otherTex.GetPixels32();

        //List<Color32> r = new List<Color32>();
        //List<Color32> l = new List<Color32>();

        List<Color32> br = new List<Color32>();
        List<Color32> tr = new List<Color32>();
        List<Color32> bl = new List<Color32>();
        List<Color32> tl = new List<Color32>();


        //bool singleArray = true;

        bool singleHArray = true;
        bool singleVArray = true;


        int rWidth = 0;
        for(int i = 0; i < splatColors.Length; i++) {
            int j = i % splatTex.width + (i / splatTex.width) * otherTex.width;
            int startIndex = startY * otherTex.width + startX;
            //check if the next pixel would be on a different line
            if ((i/splatTex.width + startY) < ((j+startIndex)/otherTex.width)) {
                if(singleHArray) {
                    rWidth = br.Count; //the first time we need to wrap, that width is the width of the right side
                    singleHArray = false;
                }
                //l.Add(splatColors[i]);*/
                if (startY + i / splatTex.width > otherTex.height - 1) {
                    singleVArray = false;
                    tl.Add(splatColors[i]);
                }
                else {
                    bl.Add(splatColors[i]);
                }
            }
            else {
                if((startY + i/splatTex.width) > (otherTex.height - 1)) {
                    singleVArray = false;
                    tr.Add(splatColors[i]);
                }
                else {
                    br.Add(splatColors[i]);
                }
                //r.Add(splatColors[i]);
            }
        }

        if (bl.Count == 0) {
            rWidth = splatTex.width;
        }

        int bHeight = 0;
        if (singleVArray)
            bHeight = splatTex.height;
        else {
            bHeight = (otherTex.height - 1) - startY;
        }

        Color32[] brArr = br.ToArray();
        Color32[] trArr = tr.ToArray();
        Color32[] blArr = bl.ToArray();
        Color32[] tlArr = tl.ToArray();

        //loop through the array(s) and interpolate between the base and splat textures
        //based on the splat texture's transparency
        for (int i = 0; i < brArr.Length; i++) {
            int counter = i % rWidth + (i / rWidth) * otherTex.width;
            brArr[i] = Color32.Lerp(sourceColors[otherTex.width * startY + startX + counter], col/*rArr[i]*/, brArr[i].a);
        }

        int lWidth = splatTex.width - rWidth;
        for(int i = 0; i < blArr.Length; i++) {
            int counter = i % lWidth + (i / lWidth) * otherTex.width;
            blArr[i] = Color32.Lerp(sourceColors[otherTex.width * startY + counter], col/*lArr[i]*/, blArr[i].a);
        }

        for(int i = 0; i < trArr.Length; i++) {
            int counter = i % rWidth + (i / rWidth) * otherTex.width;
            trArr[i] = Color32.Lerp(sourceColors[startX + counter], col, trArr[i].a);
        }

        int tHeight = splatTex.height - bHeight;
        if (tHeight != 0)
            tHeight -= 1;
        for(int i = 0; i < tlArr.Length; i++) {
            int counter = i % lWidth + (i / lWidth) * otherTex.width;
            tlArr[i] = Color32.Lerp(sourceColors[counter], col, tlArr[i].a);
        }


        //if we're wrapping, draw both l and r arrays, otherwise only draw one
        if (wrap) {
            otherTex.SetPixels32(startX, startY, rWidth, bHeight, brArr);
            otherTex.SetPixels32(0, startY, lWidth, bHeight, blArr);
            otherTex.SetPixels32(startX, 0, rWidth, tHeight, trArr);
            otherTex.SetPixels32(0, 0, lWidth, tHeight, tlArr);
        }
        else if (leftSide) {
            if (topSide) { //top left
                otherTex.SetPixels32(0, 0, lWidth, tHeight, tlArr);
            }
            else { //bottom left
                otherTex.SetPixels32(0, startY, lWidth, bHeight, blArr);
            }
        }
        else { //don't wrap, not on the left edge
            if (topSide) {  //top right
                otherTex.SetPixels32(startX, 0, rWidth, tHeight, trArr);
            }
            else { //bottom right
                otherTex.SetPixels32(startX, startY, rWidth, bHeight, brArr);
            }
        }
        
        //actually apply the new texture to the material
        otherTex.Apply();
        other.GetComponent<Renderer>().material.SetTexture("_SplatTex", otherTex);

        //gotta do this, otherwise the textures stay in memory and cause crashes
        Resources.UnloadUnusedAssets(); 
        return;
    }

}
