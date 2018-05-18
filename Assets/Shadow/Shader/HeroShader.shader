Shader "G03/HeroShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DiffuseFactor("DiffuseFactor", Range(0, 5)) = 1

        _SpecularColor("SpecularColor", COLOR) = (1,1,1,1)
		_SpecularArea("SpecularArea", Range(0, 100)) = 10
		_SpecularFactor("SpecularFactor", Range(0, 1000)) = 100

	}

	SubShader
	{

        Lighting off
		LOD 100
        ZWrite On

        // Shadow pass
        Pass
		{
		    Tags {"RenderType"="Transparent"}
		    Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				half4 pos : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

            half _lightRad;
            half4 _shadowDir;
            half4 _shadowColor;

			v2f vert (appdata v)
			{

			    half4 worldPos = mul(UNITY_MATRIX_M,v.pos);
			    half l = worldPos.z / tan(_lightRad);
			    worldPos += _shadowDir * l;
                worldPos.z = 0;

				v2f o;
				o.pos = mul(UNITY_MATRIX_VP, worldPos);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return  _shadowColor;
			}

			ENDCG
		}

		Pass
		{
		    Tags {"RenderType"="Opaque"}

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				half4 pos : POSITION;
				half2 uv : TEXCOORD0;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				fixed4 diffuse : COLOR0;

                // Specular lighting
				half3 worldNormal : NORMAL;
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;

            sampler2D _SpecularMask;
            half4 _SpecularMask_ST;
            half4 _SpecularColor;
            half _SpecularArea;
            half _SpecularFactor;

            half _DiffuseFactor;
            half3 _SimLightDir;

			v2f vert (appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.pos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				half3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.diffuse = 1 + _DiffuseFactor * dot(worldNormal, normalize(_SimLightDir));  // [1 - _DiffuseFactor, 1 + _DiffuseFactor]

                // Specular lighting
				o.worldNormal = worldNormal;
                o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 texCol = tex2D(_MainTex, i.uv);

                // Specular lighting
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                half3 halfDir = normalize(normalize(_SimLightDir) + viewDir);

                half specularLight = pow(saturate(dot(halfDir, i.worldNormal)), _SpecularArea);  // [0, 1]
                fixed specularMask = texCol.a; // [0, 1]
                half4 specular = 1 + specularLight * specularMask * _SpecularFactor * _SpecularColor;

                fixed4 c = texCol * i.diffuse * specular;
                c.a = 1;
				return c;
			}
			ENDCG
		}
     }
}
