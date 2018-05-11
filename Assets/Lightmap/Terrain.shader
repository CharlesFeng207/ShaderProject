Shader "Unlit/Terrain"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Alpha("Alpha", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { 
				"RenderType"="Transparent"
				"Queue" = "Transparent"
		 }

		  // Disable lighting, we're only using the lightmap
        Lighting Off

		 ZWrite On
		 Blend SrcAlpha OneMinusSrcAlpha  

		LOD 100
		//Blend One OneMinusSrcAlpha  // The value of this stage is multiplied by (1 - source alpha).

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Alpha;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST; // Define this since its expected by TRANSFORM_TEX; it is also pre-populated by Unity.
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				// Use `unity_LightmapST` NOT `unity_Lightmap_ST`
                o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Sample the texture
				fixed4 t = tex2D(_MainTex, i.uv);
                t.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1));

				return fixed4(t.rgb, _Alpha);
			}
			ENDCG
		}
	}
}
