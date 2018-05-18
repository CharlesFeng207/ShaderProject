Shader "G03/MinorShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AnimMap ("AnimMap", 2D) ="white" {}
		_AnimLen("Anim Length", Float) = 0
		_AnimTimeOffset("Anim Time Offset", Float) = 0
		_AnimStartTime("Anim Start Time", Float) = 0
		_AnimEndTime("Anim End Time", Float) = 0
		_DiffuseFactor("LightFactor", Range(0, 5)) = 1
	}

	SubShader
	{

		LOD 100
		Lighting off
        ZWrite On

        // Shadow pass
		Pass
		{
            Tags {"RenderType"="Transparent" "Queue"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			struct appdata
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;

			sampler2D _AnimMap;
			half4 _AnimMap_TexelSize;  // x == 1/width
            half _AnimGlobalTime;
            half _AnimStartTime;
            half _AnimEndTime;
            half _AnimTimeOffset;
			half _AnimLen;

            half _lightRad;
            half4 _shadowColor;
            half4 _shadowDir;

			v2f vert (appdata v, uint vid : SV_VertexID)
			{
				UNITY_SETUP_INSTANCE_ID(v);

                // Apply GPU animation
                half t = min(_AnimEndTime, _AnimGlobalTime - _AnimStartTime);
				half f = fmod((t + _AnimTimeOffset) / _AnimLen, 1.0);
				half animMap_x = (vid + 0.5) * _AnimMap_TexelSize.x;
				half animMap_y = f;
			    half4 pos = tex2Dlod(_AnimMap, float4(animMap_x, animMap_y, 0, 0));

                // Apply shadow
				half4 worldPos = mul(UNITY_MATRIX_M, pos);
			    half l = worldPos.z / tan(_lightRad);

			    worldPos.xy += _shadowDir * l;
                worldPos.z = 0; // Proect to X-Y plane

				v2f o;
				o.pos = mul(UNITY_MATRIX_VP, worldPos);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return _shadowColor;
			}

			ENDCG
		}

        Pass
		{
		    Tags {"RenderType"="Opaque" "Queue"="Opaque"}

            ZWrite On

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_instancing

			struct appdata
			{
				half2 uv : TEXCOORD0;
				half3 normal : NORMAL;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				fixed4 diffuse : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;

			sampler2D _AnimMap;
			half4 _AnimMap_TexelSize;  // x == 1/width
            half _AnimGlobalTime;
            half _AnimStartTime;
            half _AnimEndTime;
            half _AnimTimeOffset;
			half _AnimLen;

            half3 _SimLightDir;
            half _DiffuseFactor;

			v2f vert (appdata v, uint vid : SV_VertexID)
			{
				UNITY_SETUP_INSTANCE_ID(v);

                 // Apply GPU animation
                half t = min(_AnimEndTime, _AnimGlobalTime - _AnimStartTime);
				half f = fmod((t + _AnimTimeOffset) / _AnimLen, 1.0);
				half animMap_x = (vid + 0.5) * _AnimMap_TexelSize.x;
				half animMap_y = f;
			    half4 pos = tex2Dlod(_AnimMap, float4(animMap_x, animMap_y, 0, 0));

				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.pos = UnityObjectToClipPos(pos);

                // Apply diffuse lighting
				half3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.diffuse = 1 + _DiffuseFactor * dot(worldNormal, normalize(_SimLightDir));

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
			    fixed4 t = tex2D(_MainTex, i.uv) * i.diffuse;
				return t;
			}

			ENDCG
		}


	}
}
