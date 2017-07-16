/*
//
// Normal map to Curvature/Cavity map shader made by @xerxes1138
//
// MIT License
//
// Copyright (c) 2017 Charles Greivelding Thomas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
*/
Shader "Xerxes1138/NormalMapToCavityMap"
{
	Properties
	{
		_BumpTex ("Normal", 2D) = "bump" {}
		_CavityRadius("Cavity Radius", Range(0.0, 1.0)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
	
			struct VertexInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D	_BumpTex;

			float4		_BumpTex_ST,
						_BumpTex_TexelSize;

			half		_CavityRadius;

			VertexOutput vert (VertexInput v)
			{
				VertexOutput o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BumpTex);
				return o;
			}

			float ComputeCurvature(sampler2D tex, float2 i_uv, float2 texelSize, float radius) 
			{
				half normalNegX = UnpackNormal(tex2D(tex, float2(i_uv.x - radius * texelSize.x, i_uv.y))).r; 
				half normalPosX = UnpackNormal(tex2D(tex, float2(i_uv.x + radius * texelSize.x, i_uv.y))).r; 

				half normalNegY = UnpackNormal(tex2D(tex, float2(i_uv.x, i_uv.y - radius * texelSize.y))).g; 
				half normalPosY = UnpackNormal(tex2D(tex, float2(i_uv.x, i_uv.y + radius * texelSize.y))).g; 

				half normalX = 1 - ((normalNegX - normalPosX) * 0.5 + 0.5);
				half normalY = 1 - ((normalNegY - normalPosY) * 0.5 + 0.5);

				return saturate(dot(normalX, normalY));
			}

			fixed4 frag (VertexOutput i) : SV_Target
			{
				return ComputeCurvature(_BumpTex, i.uv, _BumpTex_TexelSize, _CavityRadius);
			}
			ENDCG
		}
	}
}
