Shader "Sliced/SlicedBacking" {
	Properties {
		_LitTex("Lit (RGB)", 2D) = "white" {}
		_OutlineThickness("Outline Thickness", Range(0, .05)) = .01
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)

        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Emission("Emission", Color) = (1.0, 1.0, 1.0, 1.0)
        _EmissionMap("Emission Map", 2D) = "white" {}

		_MainTex("Texture (RGB)", 2D) = "white" {}
		_SliceGuide ("SliceGuide (RGB)", 2D) = "white" {}
		_SliceAmount ("Slice Amount", Range(0.0, 1.0)) = 0.5
		
	}

	SubShader {
		

		Pass
		{
			Name "Outline Pass"
			Cull Front
			
			Blend SrcAlpha OneMinusSrcAlpha
			Tags{ "LightMode" = "ForwardBase" }
			LOD 200

			CGPROGRAM

			sampler2D _SliceGuide;
			float _SliceAmount;
			uniform sampler2D _MainTex;

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			uniform float _OutlineThickness;
			uniform float4 _OutlineColor;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv_SliceGuide : TEXCOORD0;
			};

			float4 _MainTex_ST;

			v2f vert(appdata_base input)
			{
				v2f output;

				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				float3 norm = mul((float3x3)UNITY_MATRIX_MV, input.normal);
				norm.x *= UNITY_MATRIX_P[0][0];
				norm.y *= UNITY_MATRIX_P[1][1];
				output.pos.xy += norm.xy * _OutlineThickness;

				output.uv_SliceGuide = TRANSFORM_TEX(input.texcoord, _MainTex);

				return output;
			}
			float4 frag(v2f input) : COLOR
			{
				return _OutlineColor;
			}
			ENDCG
		}

		Tags{ "RenderType" = "Opaque" }
		Cull Off

		CGPROGRAM

		#pragma surface surf Lambert addshadow
		
		struct Input {
			float2 uv_MainTex;
            float2 uv_EmissionMap;
			float2 uv_SliceGuide;
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
		
		void surf(Input In, inout SurfaceOutput o) {
			clip(tex2D(_SliceGuide, In.uv_SliceGuide).rgb - _SliceAmount);
			o.Albedo = (tex2D(_MainTex, In.uv_MainTex).rgb) * _Color;
            o.Emission = (tex2D(_EmissionMap, In.uv_EmissionMap).rgb) * _Emission;
		}
		ENDCG
	}	
	Fallback "Diffuse"
}