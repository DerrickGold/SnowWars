// Shader created with Shader Forge v1.04 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.04;sub:START;pass:START;ps:flbk:DLNK/Standar/Basic/BasicOpaque,lico:1,lgpr:1,nrmq:1,limd:3,uamb:True,mssp:False,lmpd:True,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,dith:2,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1722,x:32871,y:32759,varname:node_1722,prsc:2|diff-2752-OUT,spec-7516-OUT,gloss-3633-OUT,normal-1347-OUT,amdfl-4051-OUT,amspl-8337-OUT;n:type:ShaderForge.SFN_Color,id:6757,x:32328,y:32229,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_6757,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:2752,x:32521,y:32393,varname:node_2752,prsc:2|A-6757-RGB,B-8205-RGB;n:type:ShaderForge.SFN_Tex2dAsset,id:258,x:32163,y:32381,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:node_258,tex:1255553da6ea21a4fb14e86c046e92d7,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8205,x:32328,y:32381,varname:node_8205,prsc:2,tex:1255553da6ea21a4fb14e86c046e92d7,ntxv:0,isnm:False|TEX-258-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:8062,x:32128,y:32921,ptovrint:False,ptlb:Bump Map,ptin:_BumpMap,varname:node_8062,tex:4583c4361cbb8424ba516fec45ce6e7c,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:8695,x:32324,y:32881,varname:node_8695,prsc:2,tex:4583c4361cbb8424ba516fec45ce6e7c,ntxv:0,isnm:False|TEX-8062-TEX;n:type:ShaderForge.SFN_Lerp,id:1347,x:32517,y:32900,varname:node_1347,prsc:2|A-8695-RGB,B-7443-OUT,T-120-OUT;n:type:ShaderForge.SFN_Vector3,id:7443,x:32324,y:33010,varname:node_7443,prsc:2,v1:0,v2:0,v3:1;n:type:ShaderForge.SFN_ValueProperty,id:120,x:32324,y:33121,ptovrint:False,ptlb:Bump Power,ptin:_BumpPower,varname:node_120,prsc:2,glob:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:4378,x:32500,y:33176,varname:node_4378,prsc:2|A-6781-RGB,B-1929-OUT;n:type:ShaderForge.SFN_Multiply,id:1929,x:32355,y:33240,varname:node_1929,prsc:2|A-9985-OUT,B-6781-A;n:type:ShaderForge.SFN_Multiply,id:7690,x:32355,y:33605,varname:node_7690,prsc:2|A-722-OUT,B-4461-A;n:type:ShaderForge.SFN_Multiply,id:8337,x:32558,y:33360,varname:node_8337,prsc:2|A-4461-RGB,B-7690-OUT;n:type:ShaderForge.SFN_Cubemap,id:4461,x:32109,y:33420,ptovrint:False,ptlb:IBL Specular,ptin:_IBLSpecular,varname:node_4461,prsc:2,cube:2deeb75ee4068ff4aa6a88f87006b023,pvfc:0|MIP-7570-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9985,x:32109,y:33186,ptovrint:False,ptlb:Difuse Intensity IBL,ptin:_DifuseIntensityIBL,varname:node_9985,prsc:2,glob:False,v1:3;n:type:ShaderForge.SFN_ValueProperty,id:722,x:32109,y:33639,ptovrint:False,ptlb:Specular Intensity IBL,ptin:_SpecularIntensityIBL,varname:node_722,prsc:2,glob:False,v1:8;n:type:ShaderForge.SFN_RemapRange,id:7570,x:31915,y:33448,varname:node_7570,prsc:2,frmn:0,frmx:1,tomn:9,tomx:1|IN-3633-OUT;n:type:ShaderForge.SFN_Cubemap,id:6781,x:32109,y:33258,ptovrint:False,ptlb:IBL Diffuse,ptin:_IBLDiffuse,varname:node_6781,prsc:2|DIR-7059-OUT,MIP-7466-OUT;n:type:ShaderForge.SFN_Slider,id:7466,x:31721,y:33305,ptovrint:False,ptlb:Smooth  Diffuse IBL,ptin:_SmoothDiffuseIBL,varname:node_7466,prsc:2,min:0,cur:8,max:10;n:type:ShaderForge.SFN_NormalVector,id:7059,x:31865,y:33142,prsc:2,pt:True;n:type:ShaderForge.SFN_Slider,id:3633,x:32297,y:32764,ptovrint:False,ptlb:Shininess,ptin:_Shininess,varname:node_3633,prsc:2,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Add,id:4051,x:32823,y:33406,varname:node_4051,prsc:2|A-4378-OUT,B-689-OUT;n:type:ShaderForge.SFN_Fresnel,id:2406,x:32823,y:33563,varname:node_2406,prsc:2|NRM-7059-OUT,EXP-2123-OUT;n:type:ShaderForge.SFN_RemapRange,id:2123,x:32653,y:33563,varname:node_2123,prsc:2,frmn:0,frmx:1,tomn:0.5,tomx:4|IN-3633-OUT;n:type:ShaderForge.SFN_Multiply,id:689,x:32995,y:33563,varname:node_689,prsc:2|A-2406-OUT,B-4435-OUT,C-6781-RGB;n:type:ShaderForge.SFN_ValueProperty,id:4435,x:32823,y:33720,ptovrint:False,ptlb:Diffuse Rim,ptin:_DiffuseRim,varname:node_4435,prsc:2,glob:False,v1:0.5;n:type:ShaderForge.SFN_ValueProperty,id:7516,x:32454,y:32686,ptovrint:False,ptlb:Specular Power,ptin:_SpecularPower,varname:node_7516,prsc:2,glob:False,v1:0.2;proporder:6757-258-8062-120-7516-3633-4461-722-6781-9985-7466-4435;pass:END;sub:END;*/

Shader "DLNK/Standar/Basic/BasicIBL" {
    Properties {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpPower ("Bump Power", Float ) = 0
        _SpecularPower ("Specular Power", Float ) = 0.2
        _Shininess ("Shininess", Range(0, 1)) = 0
        _IBLSpecular ("IBL Specular", Cube) = "_Skybox" {}
        _SpecularIntensityIBL ("Specular Intensity IBL", Float ) = 8
        _IBLDiffuse ("IBL Diffuse", Cube) = "_Skybox" {}
        _DifuseIntensityIBL ("Difuse Intensity IBL", Float ) = 3
        _SmoothDiffuseIBL ("Smooth  Diffuse IBL", Range(0, 10)) = 8
        _DiffuseRim ("Diffuse Rim", Float ) = 0.5
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
            #pragma glsl
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
            uniform samplerCUBE _IBLSpecular;
            uniform float _DifuseIntensityIBL;
            uniform float _SpecularIntensityIBL;
            uniform samplerCUBE _IBLDiffuse;
            uniform float _SmoothDiffuseIBL;
            uniform float _Shininess;
            uniform float _DiffuseRim;
            uniform float _SpecularPower;
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
                float3 node_8695 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap)));
                float3 normalLocal = lerp(node_8695.rgb,float3(0,0,1),_BumpPower);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
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
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = _Shininess;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float4 _IBLSpecular_var = texCUBElod(_IBLSpecular,float4(viewReflectDirection,(_Shininess*-8.0+9.0)));
                float node_7690 = (_SpecularIntensityIBL*_IBLSpecular_var.a);
                float3 specularColor = float3(_SpecularPower,_SpecularPower,_SpecularPower);
                float specularMonochrome = dot(specularColor,float3(0.3,0.59,0.11));
                float HdotL = max(0.0,dot(halfDirection,lightDirection));
                float3 fresnelTerm = specularColor + ( 1.0 - specularColor ) * pow((1.0 - HdotL),5);
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float3 fresnelTermAmb = specularColor + ( 1.0 - specularColor ) * ( pow((1.0 - NdotV),5) / (4-3*gloss) );
                float alpha = 1.0 / ( sqrt( (Pi/4.0) * specPow + Pi/2.0 ) );
                float visTerm = ( NdotL * ( 1.0 - alpha ) + alpha ) * ( NdotV * ( 1.0 - alpha ) + alpha );
                visTerm = 1.0 / visTerm;
                float normTerm = (specPow + 8.0 ) / (8.0 * Pi);
                #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_OFF)
                    float3 directSpecular = float3(0,0,0);
                #else
                    float3 directSpecular = 1 * pow(max(0,dot(halfDirection,normalDirection)),specPow)*fresnelTerm*visTerm*normTerm;
                #endif
                float3 indirectSpecular = (0 + (_IBLSpecular_var.rgb*node_7690)) * fresnelTermAmb;
                float3 specular = (directSpecular + indirectSpecular) * specularColor;
                #ifndef LIGHTMAP_OFF
                    #ifndef DIRLIGHTMAP_OFF
                        specular *= lightmap;
                    #else
                        specular *= attenColor;
                    #endif
                #else
                    specular *= attenColor;
                #endif
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 indirectDiffuse = float3(0,0,0);
                #ifndef LIGHTMAP_OFF
                    float3 directDiffuse = float3(0,0,0);
                #else
                    float3 directDiffuse = max( 0.0, NdotL)*InvPi * attenColor;
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
                float4 _IBLDiffuse_var = texCUBElod(_IBLDiffuse,float4(normalDirection,_SmoothDiffuseIBL));
                indirectDiffuse += ((_IBLDiffuse_var.rgb*(_DifuseIntensityIBL*_IBLDiffuse_var.a))+(pow(1.0-max(0,dot(normalDirection, viewDirection)),(_Shininess*3.5+0.5))*_DiffuseRim*_IBLDiffuse_var.rgb)); // Diffuse Ambient Light
                float4 node_8205 = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 diffuse = (directDiffuse + indirectDiffuse) * (_Color.rgb*node_8205.rgb);
                diffuse *= 1-specularMonochrome;
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
            #pragma glsl
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
            uniform float _BumpPower;
            uniform float _Shininess;
            uniform float _SpecularPower;
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
                float3 node_8695 = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap)));
                float3 normalLocal = lerp(node_8695.rgb,float3(0,0,1),_BumpPower);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = _Shininess;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float3 specularColor = float3(_SpecularPower,_SpecularPower,_SpecularPower);
                float specularMonochrome = dot(specularColor,float3(0.3,0.59,0.11));
                float HdotL = max(0.0,dot(halfDirection,lightDirection));
                float3 fresnelTerm = specularColor + ( 1.0 - specularColor ) * pow((1.0 - HdotL),5);
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float alpha = 1.0 / ( sqrt( (Pi/4.0) * specPow + Pi/2.0 ) );
                float visTerm = ( NdotL * ( 1.0 - alpha ) + alpha ) * ( NdotV * ( 1.0 - alpha ) + alpha );
                visTerm = 1.0 / visTerm;
                float normTerm = (specPow + 8.0 ) / (8.0 * Pi);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*fresnelTerm*visTerm*normTerm;
                float3 specular = directSpecular * specularColor;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL)*InvPi * attenColor;
                float4 node_8205 = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 diffuse = directDiffuse * (_Color.rgb*node_8205.rgb);
                diffuse *= 1-specularMonochrome;
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
