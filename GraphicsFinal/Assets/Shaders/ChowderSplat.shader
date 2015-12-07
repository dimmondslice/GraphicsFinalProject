Shader "Custom/ChowderSplat" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SplatTex("Splat Texture", 2D) = "clear" {}
		_ChowderTex("Chowder", 2D) = "white" {}
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		[Material Toggle] _Wrap("Wrap", Float) = 1
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

		sampler2D _MainTex;
		//float4 _MainTex_ST;
		sampler2D _SplatTex;
		//float4 _SplatTex_ST;
		sampler2D _ChowderTex;

	struct Input {
		float2 uv_MainTex;
		float4 screenPos;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	void surf(Input IN, inout SurfaceOutputStandard o) {
		// Albedo comes from a texture tinted by color
		float2 screenUV = IN.screenPos.xy / IN.screenPos.w;// *_MainTex_ST.xy + _MainTex_ST.zw;
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		fixed4 splat = tex2D(_SplatTex, IN.uv_MainTex) * _Color;
		fixed4 chow = tex2D(_ChowderTex, screenUV) * _Color;
		o.Albedo = chow.rgb;//splat.rgb;
		if (splat.a == 0)
			o.Albedo = c.rgb;
		// Metallic and smoothness come from slider variables
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
		o.Alpha = c.a;
	}
	ENDCG
	}
		FallBack "Diffuse"
}

