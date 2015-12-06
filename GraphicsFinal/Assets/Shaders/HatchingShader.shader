﻿Shader "Custom/HatchingShader" {
    Properties{

        _Color("Color", Color) = (1.0,1.0,1.0,1.0)

        _HatchTex0("Hatch Texture 0", 2D) = "white" {}
        _HatchTex1("Hatch Texture 1", 2D) = "white" {}
        _HatchTex2("Hatch Texture 2", 2D) = "white" {}
        _HatchTex3("Hatch Texture 3", 2D) = "white" {}
        _HatchTex4("Hatch Texture 4", 2D) = "white" {}
        _HatchTex5("Hatch Texture 5", 2D) = "white" {}
        /*
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        */

    }

    SubShader{
        LOD 200

        Pass {
            Tags{ "LightMode" = "ForwardBase" }


            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnitycG.cginc"
            #include "Autolight.cginc"

            uniform float4 _Color;
            

            struct vertexInput {
                float4 vertex : POSITION;
                float4 vertUV : TEXCOORD0;

                float3 normal : NORMAL;

            };


            struct vertexOutput {
                float4 pos : SV_POSITION;
                //float4 posWorld : TEXCOORD0;

                float4 fragUV : TEXCOORD0;

                float3 normalDir : TEXCOORD1;

                float4 posWorld : TEXCORD6;

                LIGHTING_COORDS(3, 4)

            };


            //VERTEX FUNCTION
            vertexOutput vert(vertexInput v) {
                vertexOutput o;


                float3 posInc = float3(0.0, 0.0, 0.0);




                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);//moves vertex from local to position to Unity's model matrix
                                                            //so we can do the right lighting calculations
                o.normalDir = v.normal;

                o.fragUV = v.vertUV;

                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }


            //FRAGMENT FUNCTION
            float4 frag(vertexOutput i) : SV_Target{

                float atten = LIGHT_ATTENUATION(i);


                //return _Color * float4(abs( i.normalDir), 1.0);

                //return _Color;
                return float4(0.0, 0.0, 0.0, 1.0);
            }


            ENDCG
        }

        Pass {
            Tags {"LightMode" = "ForwardAdd"}

            BLEND ONE ONE

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnitycG.cginc"
            #include "Autolight.cginc"

            uniform float4 _Color;

            sampler2D _HatchTex0;
            sampler2D _HatchTex1;
            sampler2D _HatchTex2;
            sampler2D _HatchTex3;
            sampler2D _HatchTex4;
            sampler2D _HatchTex5;

            struct vertexInput {
                float4 vertex : POSITION;
                float4 vertUV : TEXCOORD0;

                float3 normal : NORMAL;

            };


            struct vertexOutput {
                float4 pos : SV_POSITION;
                //float4 posWorld : TEXCOORD0;

                float4 fragUV : TEXCOORD0;

                float3 normalDir : TEXCOORD1;

                float4 posWorld : TEXCORD6;

                LIGHTING_COORDS(3, 4)
                float3 lightDir : TEXCOORD5;

            };


            //VERTEX FUNCTION
            vertexOutput vert(vertexInput v) {
                vertexOutput o;


                float3 posInc = float3(0.0, 0.0, 0.0);




                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);//moves vertex from local to position to Unity's model matrix
                                                        //so we can do the right lighting calculations
                o.normalDir = v.normal;

                o.fragUV = v.vertUV;
                
                o.lightDir = ObjSpaceLightDir(v.vertex);


                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }


            //FRAGMENT FUNCTION
            float4 frag(vertexOutput i) : SV_Target{

                float atten = LIGHT_ATTENUATION(i);

                float4 lights = dot(i.normalDir, i.lightDir);


                float shading = atten * lights;
                
                float4 c;
                float step = 1.0 / 6.0;
                if (shading <= step) {
                    c = lerp(tex2D(_HatchTex5, i.fragUV), tex2D(_HatchTex4, i.fragUV), 6.0 * shading);
                }
                if (shading > step && shading <= step * 2.0) {
                    c = lerp(tex2D(_HatchTex4, i.fragUV), tex2D(_HatchTex3, i.fragUV), 6.0 * (shading - step));
                }
                if (shading > (2.0 * step) && shading <= step * 3.0) {
                    c = lerp(tex2D(_HatchTex3, i.fragUV), tex2D(_HatchTex2, i.fragUV), 6.0 * (shading - (step * 2.0)));
                }
                if (shading > (3.0 * step) && shading <= step * 4.0) {
                    c = lerp(tex2D(_HatchTex2, i.fragUV), tex2D(_HatchTex1, i.fragUV), 6.0 * (shading - (step * 3.0)));
                }
                if (shading > (4.0 * step) && shading <= step * 5.0) {
                    c = lerp(tex2D(_HatchTex1, i.fragUV), tex2D(_HatchTex0, i.fragUV), 6.0 * (shading - (step * 4.0)));
                }
                if (shading > 5.0 * step) {
                    c = lerp(tex2D(_HatchTex0, i.fragUV), float4(1.0, 1.0, 1.0, 1.0), 6.0 * (shading - (step * 5.0)));
                }

                float4 source = lerp(lerp(_Color, float4(1.0, 1.0, 1.0, 1.0), c.r), c, 0.5);

            //return _Color * float4(abs( i.normalDir), 1.0);

                //return float4 (atten, atten, atten, 1.0);

                return source;
                //return _Color * atten * lights;
                //return float4(1.0, 1.0, 1.0, 1.0) * atten * lights;
            }


            ENDCG

        }


	} 
	FallBack "Diffuse"
}