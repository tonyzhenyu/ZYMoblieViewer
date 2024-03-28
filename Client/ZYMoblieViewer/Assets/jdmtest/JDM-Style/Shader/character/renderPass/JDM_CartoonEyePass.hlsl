#ifndef INCLUDE_CHARACTER_EYE_PASS
#define INCLUDE_CHARACTER_EYE_PASS
        struct Attributes{
            float4 positionOS : POSITION;
            half2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
        };
        struct FragmentOutput{
            half4 color : SV_Target0;
            half4 emission : SV_Target1;
        };
        struct Varyings{
            float4 positionCS : SV_POSITION;
            half2 uv : TEXCOORD0;
            float3 positionWS : TEXCOORD4;
            half3 normalWS : TEXCOORD1;
            half3 tangentWS : TEXCOORD2;
            half3 biTangent : TEXCOORD3;
            float3 vertexLighting: TEXCOORD5;
            float4 shadowCoord: TEXCOORD6;
            float3 viewDirectionWS:TEXCOORD7;
            float3 positionVS : TEXCOORD8;
            half fog : TEXCOORD9;
        };
        cbuffer UnityPerMaterial
        {
            half4 _BaseMap_ST;
            half4 _BaseColor;
            half _BumpScale;
            half4 _FinalColorTint;

            // #ifdef _ALPHACLIP_ENABLE
                half _Cutoff;
            // #endif

            // #ifdef _IRIDESCENCE_ENABLE
                half _IridescenceWeight;
            // #endif

            // #ifdef _ADVANCED_ENABLE
                half _SpecularWeight;
                half _RimWeight;
            // #endif

            // #ifdef _MATCAP_ENABLE
                half _MatcapMetalWeight;
                half _MatcapSpecularWeight;
                half _MatcapSpecularTint;
            // #endif

            // #ifdef _DETAIL_TEXTURE_ENABLE
                half4 _DetailColor00;
                half4 _DetailColor01;
                half4 _DetailColor02;
                half4 _DetailColor03;

                half4 _Detail00_ST;
                half4 _Detail01_ST;
                half4 _Detail02_ST;
                half4 _Detail03_ST;
            // #endif
        };            
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_BumpMap);
        TEXTURE2D(_PBRMap);    
        TEXTURE2D(_IDEAMap);    

        #ifdef _MATCAP_ENABLE
            TEXTURE2D(_MatcapMetalMap);
            TEXTURE2D(_MatcapSpecularMap);
        #endif
        #include "../lib/JDM_CharacterCore.hlsl"
        Varyings vert(Attributes input)
        {
            Varyings output = (Varyings)0;
            VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);
            output.normalWS = normalInput.normalWS;
            output.biTangent = normalInput.bitangentWS;
            output.tangentWS = normalInput.tangentWS;
            output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
            output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);
            output.uv = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
            output.viewDirectionWS = GetWorldSpaceViewDir(output.positionWS);
            output.vertexLighting = VertexCartoonBRDF(output.normalWS,output.positionWS);
            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
            output.positionVS = normalize(mul(UNITY_MATRIX_V , float4(output.positionWS,1)).xyz);
            output.fog = FogGeneration(mul(UNITY_MATRIX_V , -float4(output.positionWS,1)).xyz);
            return output;
        }

        FragmentOutput frag(Varyings input)
        {
            FragmentOutput output = (FragmentOutput)0;

            half4 diffMap = _BaseMap.Sample(sampler_BaseMap,input.uv).rgba * _BaseColor.rgba;

            #ifdef _ALPHACLIP_ENABLE
                clip(diffMap.a - _Cutoff);
            #endif

            half3 mixmap = _PBRMap.Sample(sampler_BaseMap,input.uv).rgb;
            half4 ideaMap = _IDEAMap.Sample(sampler_BaseMap,input.uv).rgba ;
            half3 normalTS = UnpackNormalScale(_BumpMap.Sample(sampler_BaseMap, input.uv),_BumpScale);

            #ifdef _DETAIL_TEXTURE_ENABLE                
                diffMap.rgb = DetailTexturing(diffMap.rgb,ideaMap.r,input.uv);
            #endif

            InputData inputData = (InputData)0;
            inputData.normalWS = normalize(normalTS.x * input.tangentWS + normalTS.y * input.biTangent + normalTS.z * input.normalWS);
            inputData.viewDirectionWS = normalize(input.viewDirectionWS);
            inputData.positionWS = input.positionWS;
            inputData.shadowCoord = input.shadowCoord;
            inputData.vertexLighting = input.vertexLighting;

            SurfaceData surfaceData = (SurfaceData)0;
            surfaceData.albedo = diffMap.rgb;
            surfaceData.occlusion = mixmap.r;
            surfaceData.smoothness = mixmap.g;
            surfaceData.metallic = mixmap.b;
            surfaceData.alpha = diffMap.a;

            ExternData exData = (ExternData)0;
            #ifdef _IRIDESCENCE_ENABLE
                exData.iridescence = _IridescenceWeight;
                exData.iridescenceMask = ideaMap.g;
            #endif

            #ifdef _ADVANCED_ENABLE
                exData.specularWeight = _SpecularWeight;
                exData.rimWeight = _RimWeight;
            #else
                exData.specularWeight = 1;
                exData.rimWeight = 1;
            #endif

            exData.vertexNormal = normalize(input.normalWS);
            exData.positionVS = input.positionVS;

            #ifdef _MATCAP_ENABLE
                exData.matcapUV = GetMatcapUV(normalize(input.positionVS),inputData.normalWS);
                exData.highlightMatcap = _MatcapSpecularMap.Sample(sampler_LinearClamp,exData.matcapUV ).rgb * _MatcapSpecularWeight;
                exData.highlightTint = _MatcapSpecularTint;
                exData.matcapReflection = _MatcapMetalMap.Sample(sampler_LinearClamp,exData.matcapUV).rgb * _MatcapMetalWeight;// addition for metal
            #endif

            half4 mashUp = MashUp(exData);

            half3 raddiance = 0;
            raddiance = JDMFragmentCartoon(inputData,surfaceData,exData).rgb; // lit result

            half3 color = raddiance * _FinalColorTint.rgb;// result plus tint
            color = JDMPixelToneMapping(color).rgb;// nuetrual tonemapping
            color = lerp(color,raddiance ,ideaMap.a); // tonemapping weight;
            color = lerp(color,mashUp.rgb,mashUp.a); // mashup effect;
            color = Fever(color,ideaMap.b);// fever effect;
            color = FogBlending(color,input.fog); // fog blending
            output.color = saturate(float4(color,surfaceData.alpha)); 

            half3 emit = max(0,raddiance.rgb - 1) / 40;
            emit /= 1 + emit;
            emit = lerp(0,emit,surfaceData.metallic);
            emit = lerp(color,mashUp.rgb,mashUp.a); // mashup effect;
            emit = Fever(emit,ideaMap.b);// fever effect;
            output.emission.rgb = emit; 
            output.emission.a = 1;
            
            return output;
        }
#endif