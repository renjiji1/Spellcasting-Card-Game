Shader "TextMeshPro/SRP/TMP_SDF-URP Lit Front"
{
    Properties
    {
        [HDR]_FaceColor("Face Color", Color) = (1, 1, 1, 1)
        _IsoPerimeter("Outline Width", Vector, 4) = (0, 0, 0, 0)
        [HDR]_OutlineColor1("Outline Color 1", Color) = (0, 1, 1, 1)
        [HDR]_OutlineColor2("Outline Color 2", Color) = (0.009433985, 0.02534519, 1, 1)
        [HDR]_OutlineColor3("Outline Color 3", Color) = (0, 0, 0, 1)
        _OutlineOffset1("Outline Offset 1", Vector, 2) = (0, 0, 0, 0)
        _OutlineOffset2("Outline Offset 2", Vector, 2) = (0, 0, 0, 0)
        _OutlineOffset3("Outline Offset 3", Vector, 2) = (0, 0, 0, 0)
        [ToggleUI]_OutlineMode("OutlineMode", Float) = 0
        _Softness("Softness", Vector, 4) = (0, 0, 0, 0)
        [NoScaleOffset]_FaceTex("Face Texture", 2D) = "white" {}
        _FaceUVSpeed("_FaceUVSpeed", Vector, 2) = (0, 0, 0, 0)
        _FaceTex_ST("_FaceTex_ST", Vector, 4) = (2, 2, 0, 0)
        [NoScaleOffset]_OutlineTex("Outline Texture", 2D) = "white" {}
        _OutlineTex_ST("_OutlineTex_ST", Vector, 4) = (1, 1, 0, 0)
        _OutlineUVSpeed("_OutlineUVSpeed", Vector, 2) = (0, 0, 0, 0)
        _UnderlayColor("_UnderlayColor", Color) = (0, 0, 0, 1)
        _UnderlayOffset("Underlay Offset", Vector, 2) = (0, 0, 0, 0)
        _UnderlayDilate("Underlay Dilate", Float) = 0
        _UnderlaySoftness("_UnderlaySoftness", Float) = 0
        [ToggleUI]_BevelType("Bevel Type", Float) = 0
        _BevelAmount("Bevel Amount", Range(0, 1)) = 0
        _BevelOffset("Bevel Offset", Range(-0.5, 0.5)) = 0
        _BevelWidth("Bevel Width", Range(0, 0.5)) = 0.5
        _BevelRoundness("Bevel Roundness", Range(0, 1)) = 0
        _BevelClamp("Bevel Clamp", Range(0, 1)) = 0
        [HDR]_SpecularColor("Light Color", Color) = (1, 1, 1, 1)
        _LightAngle("Light Angle", Range(0, 6.28)) = 0
        _SpecularPower("Specular Power", Range(0, 4)) = 0
        _Reflectivity("Reflectivity Power", Range(5, 15)) = 5
        _Diffuse("Diffuse Shadow", Range(0, 1)) = 0.3
        _Ambient("Ambient Shadow", Range(0, 1)) = 0.3
        [NoScaleOffset]_MainTex("_MainTex", 2D) = "white" {}
        _GradientScale("_GradientScale", Float) = 10
        _ScaleRatioA("_ScaleRatioA", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile_fragment _ _SCREEN_SPACE_IRRADIANCE
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma multi_compile _ REFLECTION_PROBE_ROTATION
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 texCoord1 : INTERP7;
             float4 color : INTERP8;
             float4 fogFactorAndVertexLight : INTERP9;
             float3 positionWS : INTERP10;
             float3 normalWS : INTERP11;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            float4 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4;
            float3 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            float2 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2;
            Unity_Combine_float(_Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float, float(0), _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2);
            surface.BaseColor = _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_IRRADIANCE
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
        #pragma multi_compile _ REFLECTION_PROBE_ROTATION
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 texCoord1 : INTERP7;
             float4 color : INTERP8;
             float4 fogFactorAndVertexLight : INTERP9;
             float3 positionWS : INTERP10;
             float3 normalWS : INTERP11;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            float4 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4;
            float3 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            float2 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2;
            Unity_Combine_float(_Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float, float(0), _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2);
            surface.BaseColor = _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 color : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 color : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float4 texCoord1 : INTERP2;
             float4 color : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define ATTRIBUTES_NEED_INSTANCEID
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float4 color : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            float4 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4;
            float3 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            float2 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2;
            Unity_Combine_float(_Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float, float(0), _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2);
            surface.BaseColor = _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 color : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 color : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            float4 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4;
            float3 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            float2 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2;
            Unity_Combine_float(_Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float, float(0), _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2);
            surface.BaseColor = _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_CULLFACE
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 uv1;
             float4 VertexColor;
             float FaceSign;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 color : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _FaceColor;
        float4 _IsoPerimeter;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float2 _OutlineOffset1;
        float2 _OutlineOffset2;
        float2 _OutlineOffset3;
        float _OutlineMode;
        float4 _Softness;
        float4 _FaceTex_TexelSize;
        float2 _FaceUVSpeed;
        float4 _FaceTex_ST;
        float4 _OutlineTex_TexelSize;
        float4 _OutlineTex_ST;
        float2 _OutlineUVSpeed;
        float4 _UnderlayColor;
        float2 _UnderlayOffset;
        float _UnderlayDilate;
        float _UnderlaySoftness;
        float _BevelType;
        float _BevelAmount;
        float _BevelOffset;
        float _BevelWidth;
        float _BevelRoundness;
        float _BevelClamp;
        float4 _SpecularColor;
        float _LightAngle;
        float _SpecularPower;
        float _Reflectivity;
        float _Diffuse;
        float _Ambient;
        float4 _MainTex_TexelSize;
        float _GradientScale;
        float _ScaleRatioA;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FaceTex);
        SAMPLER(sampler_FaceTex);
        TEXTURE2D(_OutlineTex);
        SAMPLER(sampler_OutlineTex);
        SAMPLER(SamplerState_Linear_Clamp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        #include_with_pragmas "Assets/TextMesh Pro/Shaders/SDFFunctions.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.z;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Height_2_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.w;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelWidth_3_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.x;
            float _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_TexelHeight_4_Float = _Property_52798bdb86f6400e86489a7a368e9f8b_Out_0_Texture2D.texelSize.y;
            float _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float;
            ScreenSpaceRatio_float((_UV_36f1b4d96f2941c39e5cd95d9c1d2ce6_Out_0_Vector4.xy), _TexelSize_f383b24f0bc6434dafe44b3e3d338a63_Width_0_Float, 0, _ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float);
            UnityTexture2D _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_R_4_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.r;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_G_5_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.g;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_B_6_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.b;
            float _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float = _SampleTexture2D_9c228fac287d446296b91a4acf5cec59_RGBA_0_Vector4.a;
            float4 _UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4 = IN.uv0;
            float2 _Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2 = _OutlineOffset1;
            float _Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float = _GradientScale;
            UnityTexture2D _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.z;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.w;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelWidth_3_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.x;
            float _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_TexelHeight_4_Float = _Property_007c75c776ac4f1babe9cd7ae1fc4f14_Out_0_Texture2D.texelSize.y;
            float4 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4;
            float3 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3;
            float2 _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2;
            Unity_Combine_float(_TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Width_0_Float, _TexelSize_b571db753a1948d5a6f1de4e7d0c7238_Height_2_Float, float(0), float(0), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGBA_4_Vector4, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RGB_5_Vector3, _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2);
            float2 _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2;
            Unity_Divide_float2((_Property_9147636b0cfa466a9b37a013d8f693bf_Out_0_Float.xx), _Combine_bc9afcb18afa4ccc82d2cdc34d3f4641_RG_6_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2);
            float2 _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_63c7cd57fc3c45a9a97b514fdae32693_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2);
            float2 _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_56c25395796e4d2fbe5c892d428d1620_Out_2_Vector2, _Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2);
            float4 _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7a80e8839f0e4a1d9a6c0814f8793ee6_Out_2_Vector2) );
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_R_4_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.r;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_G_5_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.g;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_B_6_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.b;
            float _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float = _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_RGBA_0_Vector4.a;
            float2 _Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2 = _OutlineOffset2;
            float2 _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_d4df208fc23b42f2b52364124f1b661c_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2);
            float2 _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_6b2f65c1463f4f7bad16c54a95d2fe75_Out_2_Vector2, _Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2);
            float4 _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_7d7696aa6d184b4fb9c316a9dec37aee_Out_2_Vector2) );
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_R_4_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.r;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_G_5_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.g;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_B_6_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.b;
            float _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float = _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_RGBA_0_Vector4.a;
            float2 _Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2 = _OutlineOffset3;
            float2 _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_aef5c44f84e04c3185e0b93e95e34204_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2);
            float2 _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2;
            Unity_Subtract_float2((_UV_9d3c3383d5934a17bf9efbb7fd9e9043_Out_0_Vector4.xy), _Multiply_109f638d1f9b49d4991d6d21a86d4eb7_Out_2_Vector2, _Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2);
            float4 _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.tex, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.samplerstate, _Property_150533bad8e2424aaa2c74e253af8592_Out_0_Texture2D.GetTransformedUV(_Subtract_ec1f2e8bc9fd4ae38b133c60ee6c49b8_Out_2_Vector2) );
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_R_4_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.r;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_G_5_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.g;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_B_6_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.b;
            float _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float = _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_RGBA_0_Vector4.a;
            float4 _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4;
            float3 _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3;
            float2 _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2;
            Unity_Combine_float(_SampleTexture2D_9c228fac287d446296b91a4acf5cec59_A_7_Float, _SampleTexture2D_65c8e64a7535466e933eed08a2f77532_A_7_Float, _SampleTexture2D_319916a5921343f7b7eef0e50dc93def_A_7_Float, _SampleTexture2D_f814deb543c24fbbafbcdb5071d96022_A_7_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Combine_4abff6ff92fa4a05b203f10580988335_RGB_5_Vector3, _Combine_4abff6ff92fa4a05b203f10580988335_RG_6_Vector2);
            float _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float = _GradientScale;
            float4 _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4 = _IsoPerimeter;
            float4 _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4 = _Softness;
            float _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean = _OutlineMode;
            float4 _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4;
            ComputeSDF44_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _Combine_4abff6ff92fa4a05b203f10580988335_RGBA_4_Vector4, _Property_f3d31c1f18d8491a8ecf5cbc37e4b7db_Out_0_Float, _Property_1c4df61c2fea404eb3b87b270d7c59bc_Out_0_Vector4, _Property_19075add867e4757b9520d18fe8de1d0_Out_0_Vector4, _Property_c9d7f0dbae7d422985a1cc87c025e76b_Out_0_Boolean, _ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4);
            float4 _Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FaceColor) : _FaceColor;
            UnityTexture2D _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FaceTex);
            float4 _UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4 = IN.uv1;
            float4 _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4 = _FaceTex_ST;
            float2 _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2 = _FaceUVSpeed;
            float2 _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2;
            GenerateUV_float((_UV_dbcb748279484a4590e53518c49122b8_Out_0_Vector4.xy), _Property_ec184d6d9fb2494897774c9e7d279e6d_Out_0_Vector4, _Property_95928bcb6a284b8d88105a84c2e1d3ce_Out_0_Vector2, _GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2);
            float4 _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.tex, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.samplerstate, _Property_04dc152dd2ba4d519391577eb1156235_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_a455bd79094c4413a7b7dd80ca8b9368_UV_2_Vector2) );
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_R_4_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.r;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_G_5_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.g;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_B_6_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.b;
            float _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_A_7_Float = _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4.a;
            float4 _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4f194ff591484e908fc2bcdacbcf2570_Out_0_Vector4, _SampleTexture2D_b163c9f1666644b0bba62cf0e12df7bc_RGBA_0_Vector4, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4);
            float4 _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4;
            Unity_Multiply_float4_float4(IN.VertexColor, _Multiply_9f0de188085746d5a19073da1de85ddb_Out_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4);
            float4 _Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor1) : _OutlineColor1;
            UnityTexture2D _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OutlineTex);
            float4 _UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4 = IN.uv1;
            float4 _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4 = _OutlineTex_ST;
            float2 _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2 = _OutlineUVSpeed;
            float2 _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2;
            GenerateUV_float((_UV_4648b46ad29a4008a80de4f8a5a5b813_Out_0_Vector4.xy), _Property_a535f3bcbeb14622bb177eb6f46e76f4_Out_0_Vector4, _Property_9e87ce9607e14015a3790c528ca5dfda_Out_0_Vector2, _GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2);
            float4 _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.tex, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.samplerstate, _Property_2db15d90c2204143b225ec4ef08d0755_Out_0_Texture2D.GetTransformedUV(_GenerateUVCustomFunction_c234e5216678436195ee1a5914bc79da_UV_2_Vector2) );
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_R_4_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.r;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_G_5_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.g;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_B_6_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.b;
            float _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_A_7_Float = _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4.a;
            float4 _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_285f6a9863d54ed2a8150727ad749456_Out_0_Vector4, _SampleTexture2D_fdb77c3e92ee497b88ca5dc46dc45350_RGBA_0_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4);
            float4 _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor2) : _OutlineColor2;
            float4 _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor3) : _OutlineColor3;
            float4 _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4;
            Layer4_float(_ComputeSDF44CustomFunction_e818605f8f5a4f01bf61caaa33693581_Alpha_2_Vector4, _Multiply_7d78a616c2754cc28d1f32cf66ade611_Out_2_Vector4, _Multiply_59bd90a849624124bae6464ee3669aa6_Out_2_Vector4, _Property_8135ca333f8f4ea78163743e6ec1f55c_Out_0_Vector4, _Property_85b5940eb77e4625812ded7215bab8d7_Out_0_Vector4, _Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4);
            UnityTexture2D _Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            UnityTexture2D _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.z;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.w;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelWidth_3_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.x;
            float _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_TexelHeight_4_Float = _Property_9e6e50a71d9843b49b62ebe1cf7d3d59_Out_0_Texture2D.texelSize.y;
            float4 _UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4 = IN.uv0;
            float _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean = max(0, IN.FaceSign.x);
            float3 _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3;
            GetSurfaceNormal_float(_Property_67a519f507384ff1861df5d8d5b486be_Out_0_Texture2D.tex, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Width_0_Float, _TexelSize_acd0cd5a177f4a97bf23db7219305e3f_Height_2_Float, (_UV_7444469eb9884253819add9ef96baa25_Out_0_Vector4.xy), _IsFrontFace_2a552a0b828f457c911aa19561e410ae_Out_0_Boolean, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3);
            float4 _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4;
            EvaluateLight_float(_Layer4CustomFunction_f23a8b2b7c85478388ff7a8c8a6de740_RGBA_2_Vector4, _GetSurfaceNormalCustomFunction_51378bae98a94c309785d14cd5cbb453_Normal_0_Vector3, _EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4);
            UnityTexture2D _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4 = IN.uv0;
            float2 _Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2 = _UnderlayOffset;
            float2 _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_105b1ed1aa714e41bbe1ef5472bdb11f_Out_0_Vector2, _Divide_faace8101df943d8956faa31728cb004_Out_2_Vector2, _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2);
            float2 _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2;
            Unity_Subtract_float2((_UV_1e12726617b24675958e942eb62e4b09_Out_0_Vector4.xy), _Multiply_b4a40cb6acd441acb83cfe0240bf910d_Out_2_Vector2, _Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2);
            float4 _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.tex, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.samplerstate, _Property_42a586e4f6ec40eeaba891b7fd133864_Out_0_Texture2D.GetTransformedUV(_Subtract_dff7a66b353a4023b29c9d937da77960_Out_2_Vector2) );
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_R_4_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.r;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_G_5_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.g;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_B_6_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.b;
            float _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float = _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_RGBA_0_Vector4.a;
            float _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float = _GradientScale;
            float _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float = _UnderlayDilate;
            float _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float = _UnderlaySoftness;
            float _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float;
            ComputeSDF_float(_ScreenSpaceRatioCustomFunction_85a1ad8e741e41759002e8cdc8cd0b96_SSR_2_Float, _SampleTexture2D_cdddee3a537c464697357f11b966f9b8_A_7_Float, _Property_c7ddee91dc5b48dc828309c77fdb0b88_Out_0_Float, _Property_aa87c72ac0e64469acc34f936f00b3d0_Out_0_Float, _Property_7e0fadb2533f496192c1ad3e78642010_Out_0_Float, _ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float);
            float4 _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4 = _UnderlayColor;
            float4 _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4;
            Layer1_float(_ComputeSDFCustomFunction_88253223d2c34ecfab92b0c344048f94_Alpha_2_Float, _Property_4488af8ff6a7421298a7e827f567263b_Out_0_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4);
            float4 _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4;
            Composite_float(_EvaluateLightCustomFunction_aa3e347d733e48f7b65d8a8847370eec_Color_1_Vector4, _Layer1CustomFunction_44317f2e371447e2a8d894f8a021a235_RGBA_2_Vector4, _CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4);
            float _Split_163beb4431c34f538340bc0af0991e6f_R_1_Float = IN.VertexColor[0];
            float _Split_163beb4431c34f538340bc0af0991e6f_G_2_Float = IN.VertexColor[1];
            float _Split_163beb4431c34f538340bc0af0991e6f_B_3_Float = IN.VertexColor[2];
            float _Split_163beb4431c34f538340bc0af0991e6f_A_4_Float = IN.VertexColor[3];
            float4 _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_CompositeCustomFunction_2ac79705aa9e415dbb74ec215233fd1b_RGBA_2_Vector4, (_Split_163beb4431c34f538340bc0af0991e6f_A_4_Float.xxxx), _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4);
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[0];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[1];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[2];
            float _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float = _Multiply_7984fd094e1147bdabb4e26fbd3d31c8_Out_2_Vector4[3];
            float4 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4;
            float3 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            float2 _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2;
            Unity_Combine_float(_Split_91890fe48ebe4717aea61ecaf3ad4861_R_1_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_G_2_Float, _Split_91890fe48ebe4717aea61ecaf3ad4861_B_3_Float, float(0), _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGBA_4_Vector4, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3, _Combine_3e231021af7b47ba97f2871e7f25d0fe_RG_6_Vector2);
            surface.BaseColor = _Combine_3e231021af7b47ba97f2871e7f25d0fe_RGB_5_Vector3;
            surface.Alpha = _Split_91890fe48ebe4717aea61ecaf3ad4861_A_4_Float;
            surface.AlphaClipThreshold = float(0.001);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.uv1 = input.texCoord1;
            output.VertexColor = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "TMPro.EditorUtilities.TMP_SDFShaderGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}