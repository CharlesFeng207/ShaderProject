// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "stalendp/waitIcons" {
	CGINCLUDE

#include "UnityCG.cginc"                      
#pragma target 3.0          
	struct v2f {
		float4 pos:SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert(appdata_base v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	fixed calcDot(fixed a, fixed ca, float2 uv) {
		a /= degrees(1);
		ca /= degrees(1);
		fixed tt = 180 / 57.295779513;

		uv = (fixed2(cos(a), sin(a)) * 0.2 + uv) * 10;

		fixed adit = tt * 2 * step(tt, a - ca);
		fixed r = 1 - step(ca + adit, a);
		r *= lerp(0.2, -1, saturate((ca - a + adit) / 25)) * 2;

		return smoothstep(r - 0.2, r, length((fixed2)uv.xy));
	}

	fixed4 frag(v2f input) : COLOR0{
		float2 uv = input.uv.xy - float2(0.5, 0.5); 
		float rx = fmod(uv.x, 0.4);
		float ry = fmod(uv.y, 0.4);
		float mx = step(0.4, abs(uv.x));
		float my = step(0.4, abs(uv.y));
		float alpha = 1 - mx*my*step(0.1, length(float2(rx,ry)));
		alpha *= 0.9;

		fixed4 foreColor = fixed4(1, 1, 1, 1);
		fixed4 bgColor = fixed4(fixed3(0.4, 0.4, 0.4),alpha);
		fixed4 result = bgColor;

		fixed ca = fmod(_Time.y, 2) * 180;

		for (fixed i = 0; i < 360; i += 30)
		{
			bgColor = lerp(foreColor, bgColor, calcDot(i, ca, uv));
		}

		return bgColor;
	}
		ENDCG

		SubShader {
		LOD 200
			Tags{ "Queue" = "Transparent" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Pass{
			CGPROGRAM

#pragma vertex vert          
#pragma fragment frag          
#pragma fragmentoption ARB_precision_hint_fastest           

			ENDCG
		}

	}
	FallBack Off
}
