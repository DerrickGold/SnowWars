// Shader created with Shader Forge v1.04 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.04;sub:START;pass:START;ps:flbk:DLNK/Standar/Detail/DetailOpaque,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:True,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,dith:2,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:333,x:33741,y:32807,varname:node_333,prsc:2|diff-6140-OUT,spec-3653-OUT,gloss-1603-OUT,normal-9341-OUT,difocc-4770-OUT,spcocc-4770-OUT;n:type:ShaderForge.SFN_TexCoord,id:7405,x:32143,y:32880,varname:node_7405,prsc:2,uv:0;n:type:ShaderForge.SFN_ValueProperty,id:134,x:32337,y:32736,ptovrint:False,ptlb:Parallax,ptin:_Parallax,varname:node_134,prsc:2,glob:False,v1:0.03;n:type:ShaderForge.SFN_Tex2dAsset,id:8608,x:32120,y:32632,ptovrint:False,ptlb:Parallax Map,ptin:_ParallaxMap,varname:node_8608,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8144,x:32902,y:32696,varname:node_8144,prsc:2,ntxv:0,isnm:False|UVIN-4862-UVOUT,TEX-3968-TEX;n:type:ShaderForge.SFN_Lerp,id:3879,x:33161,y:32855,varname:node_3879,prsc:2|A-1100-RGB,B-7182-OUT,T-9566-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:3968,x:32902,y:32522,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:node_3968,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2dAsset,id:9564,x:32725,y:32862,ptovrint:False,ptlb:Bump Map,ptin:_BumpMap,varname:node_9564,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:1100,x:32902,y:32852,varname:node_1100,prsc:2,ntxv:0,isnm:False|UVIN-4862-UVOUT,TEX-9564-TEX;n:type:ShaderForge.SFN_Vector3,id:7182,x:32902,y:32980,varname:node_7182,prsc:2,v1:0,v2:0,v3:1;n:type:ShaderForge.SFN_ValueProperty,id:9566,x:32902,y:33090,ptovrint:False,ptlb:Bump Power,ptin:_BumpPower,varname:node_9566,prsc:2,glob:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6140,x:33161,y:32707,varname:node_6140,prsc:2|A-3842-RGB,B-8144-RGB,C-4770-OUT,D-2303-RGB,E-8629-OUT;n:type:ShaderForge.SFN_Color,id:3842,x:33161,y:32557,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_3842,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:3653,x:33204,y:32999,varname:node_3653,prsc:2|A-8144-RGB,B-4587-OUT,C-2303-RGB,D-8629-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4587,x:33049,y:33090,ptovrint:False,ptlb:Specular Power,ptin:_SpecularPower,varname:node_4587,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:7037,x:33049,y:33166,ptovrint:False,ptlb:Shininess,ptin:_Shininess,varname:node_7037,prsc:2,glob:False,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:1603,x:33204,y:33142,varname:node_1603,prsc:2|A-8144-A,B-7037-OUT,C-2303-A,D-8629-OUT;n:type:ShaderForge.SFN_Multiply,id:8199,x:32311,y:32880,varname:node_8199,prsc:2|A-7405-UVOUT,B-9804-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9804,x:32143,y:33053,ptovrint:False,ptlb:Main Tiling,ptin:_MainTiling,varname:node_9804,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Tex2d,id:498,x:33081,y:32316,varname:node_498,prsc:2,ntxv:0,isnm:False|UVIN-4862-UVOUT,TEX-9745-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:9745,x:33081,y:32144,ptovrint:False,ptlb:Occlusion Map,ptin:_OcclusionMap,varname:node_9745,ntxv:0,isnm:False;n:type:ShaderForge.SFN_ValueProperty,id:1980,x:33081,y:32459,ptovrint:False,ptlb:AO Power,ptin:_AOPower,varname:node_1980,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:4770,x:33459,y:32316,varname:node_4770,prsc:2|IN-1663-OUT;n:type:ShaderForge.SFN_Power,id:1663,x:33301,y:32316,varname:node_1663,prsc:2|VAL-498-RGB,EXP-1980-OUT;n:type:ShaderForge.SFN_Parallax,id:4862,x:32542,y:32646,varname:node_4862,prsc:2|UVIN-8199-OUT,HEI-5330-A,DEP-134-OUT,REF-2521-OUT;n:type:ShaderForge.SFN_Tex2d,id:5330,x:32337,y:32591,varname:node_5330,prsc:2,ntxv:0,isnm:False|UVIN-8199-OUT,TEX-8608-TEX;n:type:ShaderForge.SFN_Vector1,id:2521,x:32474,y:32894,varname:node_2521,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:6910,x:32311,y:33005,varname:node_6910,prsc:2|A-8199-OUT,B-7223-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7223,x:32143,y:33135,ptovrint:False,ptlb:Detail Tiling,ptin:_DetailTiling,varname:node_7223,prsc:2,glob:False,v1:4;n:type:ShaderForge.SFN_Tex2dAsset,id:9099,x:32521,y:32263,ptovrint:False,ptlb:Detail Tex,ptin:_DetailTex,varname:node_9099,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2dAsset,id:275,x:32617,y:33265,ptovrint:False,ptlb:Bump Detail,ptin:_BumpDetail,varname:node_275,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:2988,x:32794,y:33265,varname:node_2988,prsc:2,ntxv:0,isnm:False|UVIN-6910-OUT,TEX-275-TEX;n:type:ShaderForge.SFN_Tex2d,id:2303,x:32692,y:32263,varname:node_2303,prsc:2,ntxv:0,isnm:False|UVIN-6910-OUT,TEX-9099-TEX;n:type:ShaderForge.SFN_ValueProperty,id:4371,x:32794,y:33425,ptovrint:False,ptlb:Bump Detail Power,ptin:_BumpDetailPower,varname:node_4371,prsc:2,glob:False,v1:0;n:type:ShaderForge.SFN_Lerp,id:2383,x:33161,y:33305,varname:node_2383,prsc:2|A-2988-RGB,B-7182-OUT,T-4371-OUT;n:type:ShaderForge.SFN_NormalBlend,id:9341,x:33451,y:33178,varname:node_9341,prsc:2|BSE-3879-OUT,DTL-2383-OUT;n:type:ShaderForge.SFN_Vector1,id:8629,x:32902,y:32446,varname:node_8629,prsc:2,v1:2;proporder:3842-3968-9804-9099-7223-9564-9566-275-4371-4587-7037-8608-134-9745-1980;pass:END;sub:END;*/

Shader "DLNK/Standar/Detail/DetailParallax" {
    Properties {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _MainTiling ("Main Tiling", Float ) = 1
        _DetailTex ("Detail Tex", 2D) = "white" {}
        _DetailTiling ("Detail Tiling", Float ) = 4
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpPower ("Bump Power", Float ) = 0
        _BumpDetail ("Bump Detail", 2D) = "bump" {}
        _BumpDetailPower ("Bump Detail Power", Float ) = 0
        _SpecularPower ("Specular Power", Float ) = 1
        _Shininess ("Shininess", Float ) = 0.5
        _ParallaxMap ("Parallax Map", 2D) = "white" {}
        _Parallax ("Parallax", Float ) = 0.03
        _OcclusionMap ("Occlusion Map", 2D) = "white" {}
        _AOPower ("AO Power", Float ) = 1
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
            uniform float _Parallax;
            uniform sampler2D _ParallaxMap; uniform float4 _ParallaxMap_ST;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
            uniform float _BumpPower;
            uniform float4 _Color;
            uniform float _SpecularPower;
            uniform float _Shininess;
            uniform float _MainTiling;
            uniform sampler2D _OcclusionMap; uniform float4 _OcclusionMap_ST;
            uniform float _AOPower;
            uniform float _DetailTiling;
            uniform sampler2D _DetailTex; uniform float4 _DetailTex_ST;
            uniform sampler2D _BumpDetail; uniform float4 _BumpDetail_ST;
            uniform float _BumpDetailPower;
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
                float2 node_8199 = (i.uv0*_MainTiling);
                float4 node_5330 = tex2D(_ParallaxMap,TRANSFORM_TEX(node_8199, _ParallaxMap));
                float2 node_4862 = (_Parallax*(node_5330.a - 0.5)*mul(tangentTransform, viewDirection).xy + node_8199);
                float3 node_1100 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(node_4862.rg, _BumpMap)));
                float3 node_7182 = float3(0,0,1);
                float2 node_6910 = (node_8199*_DetailTiling);
                float3 node_2988 = UnpackNormal(tex2D(_BumpDetail,TRANSFORM_TEX(node_6910, _BumpDetail)));
                float3 node_9341_nrm_base = lerp(node_1100.rgb,node_7182,_BumpPower) + float3(0,0,1);
                float3 node_9341_nrm_detail = lerp(node_2988.rgb,node_7182,_BumpDetailPower) * float3(-1,-1,1);
                float3 node_9341_nrm_combined = node_9341_nrm_base*dot(node_9341_nrm_base, node_9341_nrm_detail)/node_9341_nrm_base.z - node_9341_nrm_detail;
                float3 node_9341 = node_9341_nrm_combined;
                float3 normalLocal = node_9341;
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
                float4 node_8144 = tex2D(_MainTex,TRANSFORM_TEX(node_4862.rg, _MainTex));
                float4 node_2303 = tex2D(_DetailTex,TRANSFORM_TEX(node_6910, _DetailTex));
                float node_8629 = 2.0;
                float gloss = (node_8144.a*_Shininess*node_2303.a*node_8629);
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = (node_8144.rgb*_SpecularPower*node_2303.rgb*node_8629);
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
                float4 node_498 = tex2D(_OcclusionMap,TRANSFORM_TEX(node_4862.rg, _OcclusionMap));
                float3 node_4770 = saturate(pow(node_498.rgb,_AOPower));
                indirectDiffuse *= node_4770; // Diffuse AO
                float3 diffuse = (directDiffuse + indirectDiffuse) * (_Color.rgb*node_8144.rgb*node_4770*node_2303.rgb*node_8629);
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
            uniform float _Parallax;
            uniform sampler2D _ParallaxMap; uniform float4 _ParallaxMap_ST;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
            uniform float _BumpPower;
            uniform float4 _Color;
            uniform float _SpecularPower;
            uniform float _Shininess;
            uniform float _MainTiling;
            uniform sampler2D _OcclusionMap; uniform float4 _OcclusionMap_ST;
            uniform float _AOPower;
            uniform float _DetailTiling;
            uniform sampler2D _DetailTex; uniform float4 _DetailTex_ST;
            uniform sampler2D _BumpDetail; uniform float4 _BumpDetail_ST;
            uniform float _BumpDetailPower;
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
                float2 node_8199 = (i.uv0*_MainTiling);
                float4 node_5330 = tex2D(_ParallaxMap,TRANSFORM_TEX(node_8199, _ParallaxMap));
                float2 node_4862 = (_Parallax*(node_5330.a - 0.5)*mul(tangentTransform, viewDirection).xy + node_8199);
                float3 node_1100 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(node_4862.rg, _BumpMap)));
                float3 node_7182 = float3(0,0,1);
                float2 node_6910 = (node_8199*_DetailTiling);
                float3 node_2988 = UnpackNormal(tex2D(_BumpDetail,TRANSFORM_TEX(node_6910, _BumpDetail)));
                float3 node_9341_nrm_base = lerp(node_1100.rgb,node_7182,_BumpPower) + float3(0,0,1);
                float3 node_9341_nrm_detail = lerp(node_2988.rgb,node_7182,_BumpDetailPower) * float3(-1,-1,1);
                float3 node_9341_nrm_combined = node_9341_nrm_base*dot(node_9341_nrm_base, node_9341_nrm_detail)/node_9341_nrm_base.z - node_9341_nrm_detail;
                float3 node_9341 = node_9341_nrm_combined;
                float3 normalLocal = node_9341;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float4 node_8144 = tex2D(_MainTex,TRANSFORM_TEX(node_4862.rg, _MainTex));
                float4 node_2303 = tex2D(_DetailTex,TRANSFORM_TEX(node_6910, _DetailTex));
                float node_8629 = 2.0;
                float gloss = (node_8144.a*_Shininess*node_2303.a*node_8629);
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = (node_8144.rgb*_SpecularPower*node_2303.rgb*node_8629);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow);
                float3 specular = directSpecular * specularColor;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float4 node_498 = tex2D(_OcclusionMap,TRANSFORM_TEX(node_4862.rg, _OcclusionMap));
                float3 node_4770 = saturate(pow(node_498.rgb,_AOPower));
                float3 diffuse = directDiffuse * (_Color.rgb*node_8144.rgb*node_4770*node_2303.rgb*node_8629);
/// Final Color:
                float3 finalColor = diffuse + specular;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "DLNK/Standar/Detail/DetailOpaque"
    CustomEditor "ShaderForgeMaterialInspector"
}
