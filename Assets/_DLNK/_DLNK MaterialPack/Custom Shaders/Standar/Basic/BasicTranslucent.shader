// Shader created with Shader Forge v1.04 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.04;sub:START;pass:START;ps:flbk:DLNK/Standar/Basic/BasicOpaque,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:True,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,dith:2,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1722,x:32871,y:32759,varname:node_1722,prsc:2|diff-2752-OUT,spec-7981-OUT,gloss-9467-OUT,normal-1347-OUT,lwrap-549-OUT;n:type:ShaderForge.SFN_Color,id:6757,x:32328,y:32229,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_6757,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:2752,x:32521,y:32393,varname:node_2752,prsc:2|A-6757-RGB,B-8205-RGB;n:type:ShaderForge.SFN_Tex2dAsset,id:258,x:32163,y:32381,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:node_258,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8205,x:32328,y:32381,varname:node_8205,prsc:2,ntxv:0,isnm:False|UVIN-9333-OUT,TEX-258-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:8062,x:32128,y:32921,ptovrint:False,ptlb:Bump Map,ptin:_BumpMap,varname:node_8062,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:8695,x:32324,y:32881,varname:node_8695,prsc:2,ntxv:0,isnm:False|UVIN-9333-OUT,TEX-8062-TEX;n:type:ShaderForge.SFN_Lerp,id:1347,x:32517,y:32900,varname:node_1347,prsc:2|A-8695-RGB,B-7443-OUT,T-120-OUT;n:type:ShaderForge.SFN_Vector3,id:7443,x:32324,y:33010,varname:node_7443,prsc:2,v1:0,v2:0,v3:1;n:type:ShaderForge.SFN_ValueProperty,id:120,x:32324,y:33121,ptovrint:False,ptlb:Bump Power,ptin:_BumpPower,varname:node_120,prsc:2,glob:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7981,x:32454,y:32623,varname:node_7981,prsc:2|A-8205-RGB,B-4369-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4369,x:32273,y:32642,ptovrint:False,ptlb:Specular Power,ptin:_SpecularPower,varname:node_4369,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:9467,x:32454,y:32745,varname:node_9467,prsc:2|A-8205-A,B-5323-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5323,x:32273,y:32766,ptovrint:False,ptlb:Shininess,ptin:_Shininess,varname:node_5323,prsc:2,glob:False,v1:0.5;n:type:ShaderForge.SFN_TexCoord,id:6371,x:31858,y:32575,varname:node_6371,prsc:2,uv:0;n:type:ShaderForge.SFN_ValueProperty,id:9635,x:31858,y:32739,ptovrint:False,ptlb:Main Tiling,ptin:_MainTiling,varname:node_9635,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:9333,x:32013,y:32575,varname:node_9333,prsc:2|A-6371-UVOUT,B-9635-OUT;n:type:ShaderForge.SFN_Multiply,id:549,x:32564,y:33244,varname:node_549,prsc:2|A-5347-RGB,B-5553-OUT,C-6995-RGB;n:type:ShaderForge.SFN_Tex2dAsset,id:5296,x:32152,y:33260,ptovrint:False,ptlb:Translucent Mask,ptin:_TranslucentMask,varname:node_5296,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5347,x:32340,y:33210,varname:node_5347,prsc:2,ntxv:0,isnm:False|UVIN-9333-OUT,TEX-5296-TEX;n:type:ShaderForge.SFN_ValueProperty,id:5553,x:32340,y:33353,ptovrint:False,ptlb:Translucent Power,ptin:_TranslucentPower,varname:node_5553,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Color,id:6995,x:32340,y:33428,ptovrint:False,ptlb:Translucent Color,ptin:_TranslucentColor,varname:node_6995,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:6757-258-9635-8062-120-4369-5323-6995-5296-5553;pass:END;sub:END;*/

Shader "DLNK/Standar/Basic/BasicTranslucent" {
    Properties {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _MainTiling ("Main Tiling", Float ) = 1
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpPower ("Bump Power", Float ) = 0
        _SpecularPower ("Specular Power", Float ) = 1
        _Shininess ("Shininess", Float ) = 0.5
        _TranslucentColor ("Translucent Color", Color) = (0.5,0.5,0.5,1)
        _TranslucentMask ("Translucent Mask", 2D) = "white" {}
        _TranslucentPower ("Translucent Power", Float ) = 1
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 200
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            #ifndef LIGHTMAP_OFF
                float4 unity_LightmapST;
                sampler2D unity_Lightmap;
                #ifndef DIRLIGHTMAP_OFF
                    sampler2D unity_LightmapInd;
                #endif
            #endif
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
            uniform float _BumpPower;
            uniform float _SpecularPower;
            uniform float _Shininess;
            uniform float _MainTiling;
            uniform sampler2D _TranslucentMask; uniform float4 _TranslucentMask_ST;
            uniform float _TranslucentPower;
            uniform float4 _TranslucentColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                #ifndef LIGHTMAP_OFF
                    float2 uvLM : TEXCOORD7;
                #endif
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(_Object2World, float4(v.normal,0)).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                #ifndef LIGHTMAP_OFF
                    o.uvLM = v.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
/////// Vectors:
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float2 node_9333 = (i.uv0*_MainTiling);
                float3 node_8695 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(node_9333, _BumpMap)));
                float3 normalLocal = lerp(node_8695.rgb,float3(0,0,1),_BumpPower);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                #ifndef LIGHTMAP_OFF
                    float4 lmtex = tex2D(unity_Lightmap,i.uvLM);
                    #ifndef DIRLIGHTMAP_OFF
                        float3 lightmap = DecodeLightmap(lmtex);
                        float3 scalePerBasisVector = DecodeLightmap(tex2D(unity_LightmapInd,i.uvLM));
                        UNITY_DIRBASIS
                        half3 normalInRnmBasis = saturate (mul (unity_DirBasis, normalLocal));
                        lightmap *= dot (normalInRnmBasis, scalePerBasisVector);
                    #else
                        float3 lightmap = DecodeLightmap(lmtex);
                    #endif
                #endif
                #ifndef LIGHTMAP_OFF
                    #ifdef DIRLIGHTMAP_OFF
                        float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                    #else
                        float3 lightDirection = normalize (scalePerBasisVector.x * unity_DirBasis[0] + scalePerBasisVector.y * unity_DirBasis[1] + scalePerBasisVector.z * unity_DirBasis[2]);
                        lightDirection = mul(lightDirection,tangentTransform); // Tangent to world
                    #endif
                #else
                    float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                #endif
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float4 node_8205 = tex2D(_MainTex,TRANSFORM_TEX(node_9333, _MainTex));
                float gloss = (node_8205.a*_Shininess);
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = (node_8205.rgb*_SpecularPower);
                #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_OFF)
                    float3 directSpecular = float3(0,0,0);
                #else
                    float3 directSpecular = 1 * pow(max(0,dot(halfDirection,normalDirection)),specPow);
                #endif
                float3 specular = directSpecular * specularColor;
                #ifndef LIGHTMAP_OFF
                    #ifndef DIRLIGHTMAP_OFF
                        specular *= lightmap;
                    #else
                        specular *= (floor(attenuation) * _LightColor0.xyz);
                    #endif
                #else
                    specular *= (floor(attenuation) * _LightColor0.xyz);
                #endif
/////// Diffuse:
                NdotL = dot( normalDirection, lightDirection );
                float4 node_5347 = tex2D(_TranslucentMask,TRANSFORM_TEX(node_9333, _TranslucentMask));
                float3 w = (node_5347.rgb*_TranslucentPower*_TranslucentColor.rgb)*0.5; // Light wrapping
                float3 NdotLWrap = NdotL * ( 1.0 - w );
                float3 forwardLight = max(float3(0.0,0.0,0.0), NdotLWrap + w );
                float3 indirectDiffuse = float3(0,0,0);
                #ifndef LIGHTMAP_OFF
                    float3 directDiffuse = float3(0,0,0);
                #else
                    float3 directDiffuse = forwardLight * attenColor;
                #endif
                #ifndef LIGHTMAP_OFF
                    #ifdef SHADOWS_SCREEN
                        #if (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)) && defined(SHADER_API_MOBILE)
                            directDiffuse += min(lightmap.rgb, attenuation);
                        #else
                            directDiffuse += max(min(lightmap.rgb,attenuation*lmtex.rgb), lightmap.rgb*attenuation*0.5);
                        #endif
                    #else
                        directDiffuse += lightmap.rgb;
                    #endif
                #endif
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float3 diffuse = (directDiffuse + indirectDiffuse) * (_Color.rgb*node_8205.rgb);
/// Final Color:
                float3 finalColor = diffuse + specular;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ForwardAdd"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            Fog { Color (0,0,0,0) }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
            uniform float _BumpPower;
            uniform float _SpecularPower;
            uniform float _Shininess;
            uniform float _MainTiling;
            uniform sampler2D _TranslucentMask; uniform float4 _TranslucentMask_ST;
            uniform float _TranslucentPower;
            uniform float4 _TranslucentColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(_Object2World, float4(v.normal,0)).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
/////// Vectors:
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float2 node_9333 = (i.uv0*_MainTiling);
                float3 node_8695 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(node_9333, _BumpMap)));
                float3 normalLocal = lerp(node_8695.rgb,float3(0,0,1),_BumpPower);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float4 node_8205 = tex2D(_MainTex,TRANSFORM_TEX(node_9333, _MainTex));
                float gloss = (node_8205.a*_Shininess);
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = (node_8205.rgb*_SpecularPower);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow);
                float3 specular = directSpecular * specularColor;
/////// Diffuse:
                NdotL = dot( normalDirection, lightDirection );
                float4 node_5347 = tex2D(_TranslucentMask,TRANSFORM_TEX(node_9333, _TranslucentMask));
                float3 w = (node_5347.rgb*_TranslucentPower*_TranslucentColor.rgb)*0.5; // Light wrapping
                float3 NdotLWrap = NdotL * ( 1.0 - w );
                float3 forwardLight = max(float3(0.0,0.0,0.0), NdotLWrap + w );
                float3 directDiffuse = forwardLight * attenColor;
                float3 diffuse = directDiffuse * (_Color.rgb*node_8205.rgb);
/// Final Color:
                float3 finalColor = diffuse + specular;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "DLNK/Standar/Basic/BasicOpaque"
    CustomEditor "ShaderForgeMaterialInspector"
}
