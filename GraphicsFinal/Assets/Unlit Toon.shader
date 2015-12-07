Shader "Duel Shader/Unlit Toon" {

	Properties 
	{
		_LitTex ("Lit (RGB)", 2D) = "white" {}
		_OutlineThickness ("Outline Thickness", Range(0,.05)) = .01
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
	}
	SubShader 
	{
		Pass
		{
			Cull Front
			
			Blend SrcAlpha OneMinusSrcAlpha
	        Tags { "LightMode" = "ForwardBase" } 
			LOD 200
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "UnityCG.cginc"
			uniform float _OutlineThickness;
			uniform float4 _OutlineColor;
			
			struct vertexInput 
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD1;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float2 uv : TEXCOORD0;
			};
			
			float4 _LitTex_ST;
			
			vertexOutput vert(appdata_base input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				output.posWorld = mul(modelMatrix, input.vertex);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				
				float3 norm = mul ((float3x3)UNITY_MATRIX_MV, input.normal);
    			norm.x *= UNITY_MATRIX_P[0][0];
    			norm.y *= UNITY_MATRIX_P[1][1];
    			output.pos.xy += norm.xy * _OutlineThickness;
				   
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{	
					return _OutlineColor;	
			}
			ENDCG
		 }
		 
		 Pass
		 {
		 	Tags { "LightMode" = "ForwardBase" } 
			LOD 200
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			
			#include "UnityCG.cginc"
			uniform float4 _LightColor0;
			uniform sampler2D _LitTex;
			uniform float4 _OutlineColor;
			
			
			struct vertexInput 
			{	
				float4 vertex : POSITION;
           		float4 texcoord : TEXCOORD0;
            	float3 normal : NORMAL;
            	float4 tangent : TANGENT;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float2 uv : TEXCOORD0;
				float3 normal;
			};
			
			float4 _LitTex_ST;
			float4 _NormalTex_ST;
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				output.posWorld = mul(modelMatrix, input.vertex);
				output.normal = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				output.uv = TRANSFORM_TEX(input.texcoord, _LitTex);
				   
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{				
				float4 fragmentColor = tex2D(_LitTex, input.uv);// * _LightColor0;
				return fragmentColor;
			}
			ENDCG
		 }
	}
	
	FallBack "Diffuse"
}