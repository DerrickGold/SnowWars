// Shader created with Shader Forge v1.04 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.04;sub:START;pass:START;ps:flbk:DLNK/Standar/Basic/BasicOpaque,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:True,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,dith:2,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1722,x:33017,y:32618,varname:node_1722,prsc:2|diff-643-OUT,spec-3794-OUT,gloss-7756-OUT,normal-1347-OUT;n:type:ShaderForge.SFN_Color,id:6757,x:32328,y:32229,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_6757,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:2752,x:32499,y:32321,varname:node_2752,prsc:2|A-6757-RGB,B-8205-RGB,C-6343-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:258,x:32147,y:32389,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:node_258,tex:1255553da6ea21a4fb14e86c046e92d7,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8205,x:32312,y:32389,varname:node_8205,prsc:2,tex:1255553da6ea21a4fb14e86c046e92d7,ntxv:0,isnm:False|UVIN-1210-OUT,TEX-258-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:8062,x:32145,y:33172,ptovrint:False,ptlb:Bump Map,ptin:_BumpMap,varname:node_8062,tex:4583c4361cbb8424ba516fec45ce6e7c,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:8695,x:32341,y:33132,varname:node_8695,prsc:2,tex:4583c4361cbb8424ba516fec45ce6e7c,ntxv:0,isnm:False|UVIN-1210-OUT,TEX-8062-TEX;n:type:ShaderForge.SFN_Lerp,id:1347,x:32710,y:32962,varname:node_1347,prsc:2|A-8695-RGB,B-587-RGB,T-5916-OUT;n:type:ShaderForge.SFN_Multiply,id:7981,x:32391,y:32570,varname:node_7981,prsc:2|A-8205-RGB,B-4369-OUT,C-6343-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4369,x:32229,y:32581,ptovrint:False,ptlb:Specular Power,ptin:_SpecularPower,varname:node_4369,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:9467,x:32391,y:32879,varname:node_9467,prsc:2|A-8205-A,B-5323-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5323,x:32217,y:32891,ptovrint:False,ptlb:Shininess,ptin:_Shininess,varname:node_5323,prsc:2,glob:False,v1:0.5;n:type:ShaderForge.SFN_Tex2dAsset,id:6842,x:32161,y:32003,ptovrint:False,ptlb:Top Tex,ptin:_TopTex,varname:node_6842,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:1179,x:32328,y:31828,ptovrint:False,ptlb:Top Color,ptin:_TopColor,varname:node_1179,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2dAsset,id:2398,x:32145,y:33378,ptovrint:False,ptlb:Top Bump,ptin:_TopBump,varname:node_2398,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:587,x:32341,y:33276,varname:node_587,prsc:2,ntxv:0,isnm:False|UVIN-1210-OUT,TEX-2398-TEX;n:type:ShaderForge.SFN_Lerp,id:643,x:32713,y:32422,varname:node_643,prsc:2|A-2752-OUT,B-8172-OUT,T-5916-OUT;n:type:ShaderForge.SFN_Tex2d,id:243,x:32328,y:32003,varname:node_243,prsc:2,ntxv:0,isnm:False|UVIN-1210-OUT,TEX-6842-TEX;n:type:ShaderForge.SFN_Multiply,id:8172,x:32511,y:31956,varname:node_8172,prsc:2|A-1179-RGB,B-243-RGB;n:type:ShaderForge.SFN_Multiply,id:90,x:32391,y:32693,varname:node_90,prsc:2|A-243-RGB,B-9908-OUT;n:type:ShaderForge.SFN_Multiply,id:6450,x:32391,y:33002,varname:node_6450,prsc:2|A-243-A,B-5438-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5438,x:32217,y:33002,ptovrint:False,ptlb:Top Shininess,ptin:_TopShininess,varname:node_5438,prsc:2,glob:False,v1:0.5;n:type:ShaderForge.SFN_ValueProperty,id:9908,x:32217,y:32681,ptovrint:False,ptlb:Top Specular Power,ptin:_TopSpecularPower,varname:node_9908,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Lerp,id:3794,x:32710,y:32579,varname:node_3794,prsc:2|A-7981-OUT,B-90-OUT,T-5916-OUT;n:type:ShaderForge.SFN_Lerp,id:7756,x:32710,y:32767,varname:node_7756,prsc:2|A-9467-OUT,B-6450-OUT,T-5916-OUT;n:type:ShaderForge.SFN_Clamp01,id:5916,x:31744,y:32510,varname:node_5916,prsc:2|IN-2970-OUT;n:type:ShaderForge.SFN_ComponentMask,id:8754,x:31555,y:32510,varname:node_8754,prsc:2,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-1704-OUT;n:type:ShaderForge.SFN_NormalVector,id:1704,x:31320,y:32541,prsc:2,pt:False;n:type:ShaderForge.SFN_ValueProperty,id:2201,x:31213,y:32772,ptovrint:False,ptlb:TopBottom Level,ptin:_TopBottomLevel,varname:node_2201,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:5344,x:31555,y:32668,varname:node_5344,prsc:2|A-8754-OUT,B-2201-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:9567,x:33361,y:32135,ptovrint:False,ptlb:Occlusion Map,ptin:_OcclusionMap,varname:node_9567,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:510,x:33361,y:32299,varname:node_510,prsc:2,ntxv:0,isnm:False|UVIN-1210-OUT,TEX-9567-TEX;n:type:ShaderForge.SFN_Power,id:833,x:33562,y:32299,varname:node_833,prsc:2|VAL-510-RGB,EXP-7183-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7183,x:33361,y:32450,ptovrint:False,ptlb:AO Power,ptin:_AOPower,varname:node_7183,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:6343,x:33733,y:32299,varname:node_6343,prsc:2|IN-833-OUT;n:type:ShaderForge.SFN_Blend,id:2970,x:31744,y:32650,varname:node_2970,prsc:2,blmd:3,clmp:True|SRC-5344-OUT,DST-1765-OUT;n:type:ShaderForge.SFN_Power,id:1267,x:31566,y:32349,varname:node_1267,prsc:2|VAL-6343-OUT,EXP-946-OUT;n:type:ShaderForge.SFN_ValueProperty,id:946,x:31744,y:32299,ptovrint:False,ptlb:AO Blend Power,ptin:_AOBlendPower,varname:node_946,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:1765,x:31744,y:32349,varname:node_1765,prsc:2|A-6343-OUT,B-946-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8273,x:31756,y:32125,ptovrint:False,ptlb:Main Tiling,ptin:_MainTiling,varname:node_8273,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:1210,x:31912,y:32015,varname:node_1210,prsc:2|A-8570-UVOUT,B-8273-OUT;n:type:ShaderForge.SFN_TexCoord,id:8570,x:31756,y:31967,varname:node_8570,prsc:2,uv:0;proporder:6757-258-8273-8062-4369-5323-9567-7183-1179-6842-2398-9908-5438-2201-946;pass:END;sub:END;*/

Shader "DLNK/Standar/Basic/BasicTopBottom" {
    Properties {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _MainTiling ("Main Tiling", Float ) = 1
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _SpecularPower ("Specular Power", Float ) = 1
        _Shininess ("Shininess", Float ) = 0.5
        _OcclusionMap ("Occlusion Map", 2D) = "white" {}
        _AOPower ("AO Power", Float ) = 1
        _TopColor ("Top Color", Color) = (0.5,0.5,0.5,1)
        _TopTex ("Top Tex", 2D) = "white" {}
        _TopBump ("Top Bump", 2D) = "bump" {}
        _TopSpecularPower ("Top Specular Power", Float ) = 1
        _TopShininess ("Top Shininess", Float ) = 0.5
        _TopBottomLevel ("TopBottom Level", Float ) = 1
        _AOBlendPower ("AO Blend Power", Float ) = 1
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
            uniform float _SpecularPower;
            uniform float _Shininess;
            uniform sampler2D _TopTex; uniform float4 _TopTex_ST;
            uniform float4 _TopColor;
            uniform sampler2D _TopBump; uniform float4 _TopBump_ST;
            uniform float _TopShininess;
            uniform float _TopSpecularPower;
            uniform float _TopBottomLevel;
            uniform sampler2D _OcclusionMap; uniform float4 _OcclusionMap_ST;
            uniform float _AOPower;
            uniform float _AOBlendPower;
            uniform float _MainTiling;
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
                float2 node_1210 = (i.uv0*_MainTiling);
                float3 node_8695 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(node_1210, _BumpMap)));
                float3 node_587 = UnpackNormal(tex2D(_TopBump,TRANSFORM_TEX(node_1210, _TopBump)));
                float4 node_510 = tex2D(_OcclusionMap,TRANSFORM_TEX(node_1210, _OcclusionMap));
                float3 node_6343 = saturate(pow(node_510.rgb,_AOPower));
                float3 node_5916 = saturate(saturate(((i.normalDir.g*_TopBottomLevel)+(node_6343*_AOBlendPower)-1.0)));
                float3 normalLocal = lerp(node_8695.rgb,node_587.rgb,node_5916);
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
                float4 node_8205 = tex2D(_MainTex,TRANSFORM_TEX(node_1210, _MainTex));
                float4 node_243 = tex2D(_TopTex,TRANSFORM_TEX(node_1210, _TopTex));
                float gloss = lerp((node_8205.a*_Shininess),(node_243.a*_TopShininess),node_5916);
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = lerp((node_8205.rgb*_SpecularPower*node_6343),(node_243.rgb*_TopSpecularPower),node_5916);
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
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 indirectDiffuse = float3(0,0,0);
                #ifndef LIGHTMAP_OFF
                    float3 directDiffuse = float3(0,0,0);
                #else
                    float3 directDiffuse = max( 0.0, NdotL) * attenColor;
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
                float3 diffuse = (directDiffuse + indirectDiffuse) * lerp((_Color.rgb*node_8205.rgb*node_6343),(_TopColor.rgb*node_243.rgb),node_5916);
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
            uniform float _SpecularPower;
            uniform float _Shininess;
            uniform sampler2D _TopTex; uniform float4 _TopTex_ST;
            uniform float4 _TopColor;
            uniform sampler2D _TopBump; uniform float4 _TopBump_ST;
            uniform float _TopShininess;
            uniform float _TopSpecularPower;
            uniform float _TopBottomLevel;
            uniform sampler2D _OcclusionMap; uniform float4 _OcclusionMap_ST;
            uniform float _AOPower;
            uniform float _AOBlendPower;
            uniform float _MainTiling;
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
                float2 node_1210 = (i.uv0*_MainTiling);
                float3 node_8695 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(node_1210, _BumpMap)));
                float3 node_587 = UnpackNormal(tex2D(_TopBump,TRANSFORM_TEX(node_1210, _TopBump)));
                float4 node_510 = tex2D(_OcclusionMap,TRANSFORM_TEX(node_1210, _OcclusionMap));
                float3 node_6343 = saturate(pow(node_510.rgb,_AOPower));
                float3 node_5916 = saturate(saturate(((i.normalDir.g*_TopBottomLevel)+(node_6343*_AOBlendPower)-1.0)));
                float3 normalLocal = lerp(node_8695.rgb,node_587.rgb,node_5916);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float4 node_8205 = tex2D(_MainTex,TRANSFORM_TEX(node_1210, _MainTex));
                float4 node_243 = tex2D(_TopTex,TRANSFORM_TEX(node_1210, _TopTex));
                float gloss = lerp((node_8205.a*_Shininess),(node_243.a*_TopShininess),node_5916);
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = lerp((node_8205.rgb*_SpecularPower*node_6343),(node_243.rgb*_TopSpecularPower),node_5916);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow);
                float3 specular = directSpecular * specularColor;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 diffuse = directDiffuse * lerp((_Color.rgb*node_8205.rgb*node_6343),(_TopColor.rgb*node_243.rgb),node_5916);
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
