Shader "Hidden/Shader/NoiseEffect"
{
	HLSLINCLUDE

	#pragma target 4.5
	#pragma only_renderers d3d11 playstation xboxone vulkan metal switch

	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

	struct Attributes
	{
		uint vertexID : SV_VertexID;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct Varyings
	{
		float4 positionCS : SV_POSITION;
		float2 texcoord   : TEXCOORD0;
		UNITY_VERTEX_OUTPUT_STEREO
	};

	Varyings Vert(Attributes input)
	{
		Varyings output;
		UNITY_SETUP_INSTANCE_ID(input);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
		output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
		output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
		return output;
	}

	// List of properties to control your post process effect
	float _X;
	float _Y;
	TEXTURE2D_X(_InputTexture);

	float smoothstep(float t)
	{
		return t * t * (3.0 - 2.0 * t);
	}
	float remap(float x, float start0, float end0, float start1, float end1)
	{
		return start1 + clamp((x - start0) / (end0 - start0), 0, 1) * (end1 - start1);
	}
	float random(float2 uv)
	{
		return frac(sin(dot(uv, float2(12.9898, 78.2323)))*46789.23514879);
	}
	float noise(float2 uv)
	{
		float2 i = floor(uv);
		float2 f = frac(uv);

		float a = random(i + float2(0, 0));
		float b = random(i + float2(1, 0));
		float c = random(i + float2(0, 1));
		float d = random(i + float2(1, 1));

		// Cubic Hermine Curve (same as smoothstep)
		float2 u = f * f*(3.0 - 2.0*f);

		return lerp(a, b, u.x)
			+ (c - a) * u.y * (1.0f - u.x)
			+ (d - b) * u.x * u.y;
	}
	float4 CustomPostProcess(Varyings input) : SV_Target
	{
		//UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		//
		//uint2 positionSS = input.texcoord * _ScreenSize.xy;
		//float3 outColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz;
		//outColor.r = 1;
		//return float4(outColor, 1);
		float2 uv = input.texcoord * _ScreenSize.xy * _X;

		float n = noise(uv);

		float ns = smoothstep(remap(1 - n, _Y, 1, 0, 1));

		return float4(ns.xxx, 1);
	}

		ENDHLSL

		SubShader
	{
		Pass
		{
			Name "NoiseEffect"

			ZWrite Off
			ZTest Always
			Blend Off
			Cull Off

			HLSLPROGRAM
				#pragma fragment CustomPostProcess
				#pragma vertex Vert
			ENDHLSL
		}
	}
	Fallback Off
}
