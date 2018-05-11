// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/HeatDistortion"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_NoiseTex("Noise Texture (RG)", 2D) = "white" {}
		_HeatTime("Heat Time", range(0,1)) = 0.1

		_Force0("Force0", range(0,0.1)) = 0
		_Distance0("Distance0", Range(0, 1000)) = 100
		_Radius0("Radius0", Range(0, 100)) = 50
		_Center0("Center0", Vector) = (300, 300, 0, 0)

		_Force1("Force1", range(0,0.1)) = 0
		_Distance1("Distance1", Range(0, 1000)) = 100
		_Radius1("Radius1", Range(0, 100)) = 50
		_Center1("Center1", Vector) = (300, 300, 0, 0)
	
		_Force2("Force2", range(0,0.1)) = 0
		_Distance2("Distance2", Range(0, 1000)) = 100
		_Radius2("Radius2", Range(0, 100)) = 50
		_Center2("Center2", Vector) = (300, 300, 0, 0)

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
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _NoiseTex;
				fixed _HeatTime;

				fixed _Force0;
				half _Distance0;
				half _Radius0;
				half2 _Center0;

				fixed _Force1;
				half _Distance1;
				half _Radius1;
				half2 _Center1;

				fixed _Force2;
				half _Distance2;
				half _Radius2;
				half2 _Center2;

				struct v2f 
				{
					half4 pos:SV_POSITION;
					half4 uv : TEXCOORD0;
				};

				v2f vert(appdata_full v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv.xy = v.texcoord.xy;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					
					fixed4 offsetColor1 = tex2D(_NoiseTex, i.uv + _Time.xz*_HeatTime);
					fixed4 offsetColor2 = tex2D(_NoiseTex, i.uv - _Time.yx*_HeatTime);
					fixed2 t = ((offsetColor1.rg + offsetColor2.rg) - 1) ;

					half2 scrPos = i.uv.xy * _ScreenParams.xy;

					i.uv.xy += t * (1 - smoothstep(0, _Radius0, abs(_Distance0 - length(scrPos - _Center0)))) * _Force0;
					i.uv.xy += t * (1 - smoothstep(0, _Radius1, abs(_Distance1 - length(scrPos - _Center1)))) * _Force1;
					i.uv.xy += t * (1 - smoothstep(0, _Radius2, abs(_Distance2 - length(scrPos - _Center2)))) * _Force2;

					fixed4 renderTex = tex2D(_MainTex, i.uv);

					return renderTex;
				}
				ENDCG
			}
		}

	FallBack off
}
