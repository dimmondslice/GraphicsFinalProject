Shader "Custom/TestShader" {
	
	SubShader {
		Tags{"RenderType" = "Opaque"}
		cull Off
		Pass {
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct vertOut
			{
				float4 pos : SV_POSITION;
				fixed4 col : COLOR;
				float4 tanVec : TANGENT;
			};
			
			
			vertOut vert(appdata_tan v)
			{
				vertOut o;
				
				o.col.xyz = v.normal * 0.5 + 0.5;
				o.col.w = 1.0;
				o.tanVec = v.tangent;
				o.pos = v.vertex - v.tangent/2;
				o.pos = mul (UNITY_MATRIX_MVP, o.pos);
				return o;
			}
			
			fixed4 frag(float4 sp:VPOS) : SV_Target {
                float2 wcoord = sp.xy/_ScreenParams.xy;
                float vig = clamp(3.0*length(wcoord-0.5),0.0,1.0);
                return lerp (fixed4(wcoord,0.0,1.0),fixed4(0.3,0.3,0.3,1.0),vig);
            }
			
			ENDCG
		}
	} 
}
