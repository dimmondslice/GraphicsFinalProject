Shader "Splat"
{
	Properties
	{
		_Color("Color", COLOR) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_SplatTex("Splat Texture", 2D) = "clear" {}
		_NormalTex("Normal", 2D) = "bump" {}
		[MaterialToggle] _Wrap("Wrap", Float) = 1
		_SplatThickness ("Splat Thickness", Range(0,1)) = .75
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			uniform float4 _LightColor0;
			uniform sampler2D _MainTex;
			uniform sampler2D _SplatTex;
			uniform sampler2D _NormalTex;
			uniform float _SplatThickness;

			float4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float3 normal : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
				float3 lightDir : TEXCOORD5;

				float3 tangentWorld : TEXCOORD6;
				float3 normalWorld : TEXCOORD7;
				float3 binormalWorld : TEXCOORD8;
			};

			float4 _MainTex_ST;
			float4 _SplatTex_ST;
			float4 _NormalTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				float4x4 modelMatrixInverse = _World2Object;
				o.posWorld = mul(_Object2World, v.vertex);
				//o.normal = v.normal;
				o.normal = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.lightDir = ObjSpaceLightDir(v.vertex);
				o.lightDir = normalize(_WorldSpaceLightPos0.xyz);
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				o.tangentWorld = normalize(
					mul(_Object2World, float4(v.tangent.xyz, 0.0)).xyz);
				o.normalWorld = normalize(
					mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
				o.binormalWorld = normalize(
					cross(o.normalWorld, o.tangentWorld)
					* v.tangent.w);

				return o;
			}
			
			

			fixed4 frag (v2f i) : SV_Target
			{
				float4 encodedNormal = tex2D(_NormalTex,
				_NormalTex_ST.xy * i.uv.xy + _NormalTex_ST.zw);
				float3 localCoords = float3(2.0 * encodedNormal.a - 1.0,
					2.0 * encodedNormal.g - 1.0, 0.0);
				localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld);
				float3 baseNormal;

				baseNormal = normalize(mul(localCoords, local2WorldTranspose));

				float3 normal = i.normal * _SplatThickness + baseNormal * (1 - _SplatThickness);

				float atten = LIGHT_ATTENUATION(i);

				fixed4 tex = tex2D(_SplatTex, i.uv);
				if (tex.a == 0)
				{
					normal = baseNormal;
					tex = tex2D(_MainTex, i.uv) * _Color;
				}

				float4 lights = dot(normal, i.lightDir);
				lights = max(0.0, lights);
				fixed4 c;
				c.rgb = tex.rgb * _LightColor0;
				c.rgb *= lights;
				c.a = tex.a + _LightColor0.a;
				return c;
			}
			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			uniform float4 _LightColor0;
			sampler2D _MainTex;
			sampler2D _SplatTex;
			float4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float3 normal : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
				float3 lightDir : TEXCOORD5;
			};

			float4 _MainTex_ST;
			float4 _SplatTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				float4x4 modelMatrixInverse = _World2Object;
				o.posWorld = mul(_Object2World, v.vertex);
				o.normal = v.normal;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.lightDir = ObjSpaceLightDir(v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}



			fixed4 frag(v2f i) : SV_Target
			{
				float atten = LIGHT_ATTENUATION(i);

			fixed4 tex = tex2D(_SplatTex, i.uv);
			if (tex.a == 0)
			{
				tex = tex2D(_MainTex, i.uv) * _Color;
			}

			float4 lights = dot(i.normal, i.lightDir);
			fixed4 c;
			c.rgb = tex.rgb * _LightColor0 *(atten);
			c.rgb *= lights;
			c.a = tex.a + _LightColor0.a * atten;
			return c;
			}
			ENDCG
		}
	}
}
