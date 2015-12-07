Shader "Custom/SquareShaderFrag"
{
	/*
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Emission("Emission", Color) = (1.0, 1.0, 1.0, 1.0)
		_EmissionMap("Emission Map", 2D) = "white" {}

		_MainTex("Texture (RGB)", 2D) = "white" {}
		_SliceGuide("SliceGuide (RGB)", 2D) = "white" {}
		_SliceAmount("Slice Amount", Range(0.0, 1.0)) = 0.5

		_BurnSize("BurnSize", Range(0.0, 1.0)) = 0.15
		_BurnRamp("Burn Ramp (RGB)", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 uv_SliceGuide : _SliceGuide;
			};

			struct Input {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;

				//float2 uv_MainTex;
				//float2 uv_EmissionMap;
				//float2 uv_SliceGuide;
				float _SliceAmount;
			};
			uniform float4 _Color;
			uniform float4 _Emission;
			sampler2D _EmissionMap;

			sampler2D _MainTex;
			sampler2D _SliceGuide;
			float _SliceAmount;

			sampler2D _BurnRamp;
			float _BurnSize;

			Input vert (appdata v)
			{
				Input o;
				//o.uv_MainTex = _MainTex;
				//o.uv_EmissionMap = _EmissionMap
				//o.uv_SliceGuide = _SliceGuide;
				o._SliceAmount = _SliceAmount;


				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			

			

			fixed4 frag (Input i) : SV_Target
			{
				clip(tex2D(_SliceGuide, i.uv_SliceGuide).rgb - _SliceAmount);
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				col = 1 - col;
				return col;
				


				//o.Albedo = (tex2D(_MainTex, In.uv_MainTex).rgb) * _Color;

				//o.Emission = (tex2D(_EmissionMap, In.uv_EmissionMap).rgb) * _Emission;


				//half test = tex2D(_SliceGuide, In.uv_MainTex).rgb - _SliceAmount;
			}
			ENDCG
		}
	}*/
	Fallback "Diffuse"
}
