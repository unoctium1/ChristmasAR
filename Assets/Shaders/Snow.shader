Shader "Unlit/Snow"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.
    Properties
    {
        _BaseColor ("Main Color", Color) = (0,0,0,0)
        _PathColor("Path Color", Color) = (0,0,0,0)
        _Tess("Tessellation", Range(1, 32)) = 20
        _MaxTessDistance("Max Tess Distance", Range(1, 32)) = 20
        _Noise("Noise", 2D) = "gray" {}
        _SparkleNoise("Sparkle Noise", 2D) = "gray" {}
        _SparkleScale("Sparkle Scale", Range(0,10)) = 10
        _SparkleCutoff("Sparkle Cutoff", Range(0,10)) = 0.1
        _NoiseWeight("Noise Weight", Range(0,1)) = 0
        _SnowHeight("Height Amount", Range(0, 1)) = 0
        _SnowDepth("Depth Amount", Range(0, 1)) = 0
        _Mask("Render Texture Mask", 2D) = "white" {}
        /*
        _CameraPosition("Camera Position", Vector) = (0,0,0,0)
        _RenderTexture("Render Texture", 2D) = "white" {}
        _OrthographicCameraSize("Camera Size", Float) = 15
        */
    }
 
    // The SubShader block containing the Shader code. 
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
 
        Pass
        {
            Tags{ "LightMode" = "UniversalForward" }
 
 
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"    
            #include "Assets/Shaders/CustomTessellation.hlsl"
 
 
            #pragma require tessellation
            // This line defines the name of the vertex shader. 
            #pragma vertex TessellationVertexProgram
            // This line defines the name of the fragment shader. 
            #pragma fragment frag
            // This line defines the name of the hull shader. 
            #pragma hull hull
            // This line defines the name of the domain shader. 
            #pragma domain domain
 
            sampler2D _Noise;
            sampler2D _Mask;
            sampler2D _SparkleNoise;
            float _SnowHeight;
            float _SnowDepth;
            float _NoiseWeight;
            float _SparkleScale;
            float _SparkleCutoff;
            half4 _BaseColor;
            half4 _PathColor;
            uniform half4 _CameraPosition;
            uniform float _OrthographicCameraSize;

            uniform sampler2D _RenderTexture;
 
            // pre tesselation vertex program
            ControlPoint TessellationVertexProgram(Attributes v)
            {
                ControlPoint p;
 
                p.vertex = v.vertex;
                p.uv = v.uv;
                p.normal = v.normal;
                p.color = v.color;
 
                return p;
            }
 
            // after tesselation
            Varyings vert(Attributes input)
            {
                Varyings output;
                float Noise = tex2Dlod(_Noise, float4(input.uv, 0, 0)).r;
                
                float3 worldPosition = mul(unity_ObjectToWorld, input.vertex).xyz;
                // Effects RenderTexture Reading
                float2 uv = worldPosition.xz - _CameraPosition.xz;
                uv = uv / (_OrthographicCameraSize * 2);
                uv += 0.5;
                // Mask to prevent bleeding
                float mask = tex2Dlod(_Mask, float4(uv , 0,0)).a;
                float4 RTEffect = tex2Dlod(_RenderTexture, float4(uv, 0, 0));
                RTEffect *= mask;

                input.vertex.xyz += normalize(input.normal) * saturate((input.color.r * _SnowHeight) + (Noise * _NoiseWeight * input.color.r));
                input.vertex.xyz -= normalize(input.normal) * (RTEffect.g * saturate(input.color.r)) * _SnowDepth;
                output.vertex = TransformObjectToHClip(input.vertex.xyz);
                output.color = input.color;
                output.normal = input.normal;
                output.uv = input.uv;
                output.worldPosition = worldPosition;
                return output;
            }
 
            [UNITY_domain("tri")]
            Varyings domain(TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
            {
                Attributes v;
 
                #define DomainPos(fieldName) v.fieldName = \
                patch[0].fieldName * barycentricCoordinates.x + \
                patch[1].fieldName * barycentricCoordinates.y + \
                patch[2].fieldName * barycentricCoordinates.z;
 
                DomainPos(vertex)
                DomainPos(uv)
                DomainPos(color)
                DomainPos(normal)
 
                return vert(v);
            }
 
            // The fragment shader definition.            
            half4 frag(Varyings IN) : SV_Target
            {
                // Effects RenderTexture Reading
                float2 uv = IN.worldPosition.xz - _CameraPosition.xz;
                uv = uv / (_OrthographicCameraSize * 2);
                uv += 0.5;
                // Mask to prevent bleeding
                float mask = tex2D(_Mask, uv).a;
                float4 effect = tex2D(_RenderTexture, float2 (uv.x, uv.y));
                effect *= mask;
             
                half4 noise = tex2D(_Noise, IN.uv);
                half4 tex = _BaseColor;
                
                noise = clamp(noise, 0, 0.3);
                tex += noise;
                float vertexColoredPrimary = step(0.6* noise,IN.color.r);

                float sparklesStatic = tex2D(_SparkleNoise, IN.uv * _SparkleScale * 5) ;
                //float sparklesResult = tex2D(_SparkleNoise, (IN.uv * IN.vertex) * _SparkleScale) * sparklesStatic;
                
                tex = lerp(tex, _PathColor * effect.g, saturate(effect.g * 2 * vertexColoredPrimary));

                tex += step(_SparkleCutoff, sparklesStatic) *vertexColoredPrimary;
                return tex;
            }
        ENDHLSL
        }
    }
}
