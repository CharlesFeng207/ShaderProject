// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "stalendp/NoiseImage" {
	Properties{
		_MainTex("image", 2D) = "white" {}
	_NoiseTex("noise", 2D) = "bump" {}
	_percent("percent", Range(-0.3, 1)) = 0
		_DefColor("defalutColor", COLOR) = (0, .8, .4, 1)
	}

		CGINCLUDE
#include "UnityCG.cginc"             

		sampler2D _MainTex;
	sampler2D _NoiseTex;
	float _percent;
	fixed4 _DefColor;

	struct v2f {
		half4 pos:SV_POSITION;
		half4 uv : TEXCOORD0;
	};

	v2f vert(appdata_full v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = v.texcoord.xy;
		o.uv.zw = v.texcoord.xy - _Time.xx; //诸多信息可以放在vert里面计算，可以优化
		return o;
	}

	fixed4 frag(v2f i) : COLOR0{
		// 原始卡牌, 把alpha设置为1，屏蔽掉alpha通道信息  
		fixed4 tex0 = tex2D(_MainTex, i.uv.xy);
		tex0.a = 1;

	// 透明躁动卡牌; 使用alpha通道信息，设置显示颜色，并加入躁动；
	half3 noise = tex2D(_NoiseTex, i.uv.zw);
	fixed4 tex1 = tex2D(_MainTex, i.uv.xy + noise.xy * 0.05 - 0.025);
	tex1.a = (tex1.r + tex1.g + tex1.b) / 3;
	//tex1.rgb = _DefColor.rgb / 3;

	return lerp(tex0, tex1, smoothstep(0, 0.3, i.uv.y - _percent));
	//return tex1;
	//return fixed4(noise, 1);
	}
		ENDCG

		SubShader {
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