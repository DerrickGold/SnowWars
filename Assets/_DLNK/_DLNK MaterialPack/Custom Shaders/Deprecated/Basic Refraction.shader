// Shader created with Shader Forge Beta 0.34 
// Shader Forge (c) Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.34;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:0,uamb:True,mssp:True,lmpd:False,lprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,blpr:1,bsrc:3,bdst:7,culm:0,dpts:2,wrdp:False,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.4788062,fgcg:0.6402428,fgcb:0.9044118,fgca:1,fgde:0.02,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1,x:32652,y:32636|normal-21-OUT,alpha-233-OUT,refract-37-OUT;n:type:ShaderForge.SFN_Tex2d,id:19,x:33583,y:32727,ptlb:Normal Map,ptin:_NormalMap,tex:483ba4131c713fa4f8f09793d85d4a1d,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Vector3,id:20,x:33583,y:32892,v1:0,v2:0,v3:1;n:type:ShaderForge.SFN_Lerp,id:21,x:33407,y:32756|A-19-RGB,B-20-OUT,T-23-OUT;n:type:ShaderForge.SFN_ValueProperty,id:23,x:33617,y:33029,ptlb:Smooth Normal,ptin:_SmoothNormal,glob:False,v1:0;n:type:ShaderForge.SFN_ComponentMask,id:29,x:33239,y:32655,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-21-OUT;n:type:ShaderForge.SFN_Multiply,id:30,x:33092,y:32855|A-29-OUT,B-340-OUT;n:type:ShaderForge.SFN_ValueProperty,id:31,x:33841,y:33213,ptlb:Refraction Power,ptin:_RefractionPower,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:37,x:32908,y:32904|A-315-OUT,B-30-OUT;n:type:ShaderForge.SFN_Fresnel,id:212,x:33244,y:33103|EXP-219-OUT;n:type:ShaderForge.SFN_ValueProperty,id:219,x:33559,y:33167,ptlb:Refraction Fresnel,ptin:_RefractionFresnel,glob:False,v1:2;n:type:ShaderForge.SFN_Vector1,id:233,x:32956,y:32798,v1:0;n:type:ShaderForge.SFN_OneMinus,id:315,x:33044,y:33062|IN-212-OUT;n:type:ShaderForge.SFN_Depth,id:333,x:34193,y:33314;n:type:ShaderForge.SFN_Multiply,id:338,x:33657,y:33258|A-31-OUT,B-342-OUT;n:type:ShaderForge.SFN_Max,id:340,x:33479,y:33258|A-338-OUT,B-341-OUT;n:type:ShaderForge.SFN_Vector1,id:341,x:33657,y:33427,v1:0;n:type:ShaderForge.SFN_OneMinus,id:342,x:33841,y:33321|IN-347-OUT;n:type:ShaderForge.SFN_Multiply,id:347,x:34019,y:33321|A-350-OUT,B-333-OUT;n:type:ShaderForge.SFN_ValueProperty,id:350,x:34193,y:33221,ptlb:Distance Fallof,ptin:_DistanceFallof,glob:False,v1:1;proporder:19-23-31-219-350;pass:END;sub:END;*/

Shader "DLNK/Deprecated/Particles/BasicRefraction" {
    Properties {
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _SmoothNormal ("Smooth Normal", Float ) = 0
        _RefractionPower ("Refraction Power", Float ) = 1
        _RefractionFresnel ("Refraction Fresnel", Float ) = 2
        _DistanceFallof ("Distance Fallof", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 200
        GrabPass{ }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform sampler2D _GrabTexture;
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform float _SmoothNormal;
            uniform float _RefractionPower;
            uniform float _RefractionFresnel;
            uniform float _DistanceFallof;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                float4 projPos : TEXCOORD6;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(float4(v.normal,0), _World2Object).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                o.screenPos = o.pos;
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                #if UNITY_UV_STARTS_AT_TOP
                    float grabSign = -_ProjectionParams.x;
                #else
                    float grabSign = _ProjectionParams.x;
                #endif
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
/////// Normals:
                float2 node_360 = i.uv0;
                float3 node_21 = lerp(UnpackNormal(tex2D(_NormalMap,TRANSFORM_TEX(node_360.rg, _NormalMap))).rgb,float3(0,0,1),_SmoothNormal);
                float3 normalLocal = node_21;
                float3 normalDirection =  normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
                float node_212 = pow(1.0-max(0,dot(normalDirection, viewDirection)),_RefractionFresnel);
                float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + ((1.0 - node_212)*(node_21.rg*max((_RefractionPower*(1.0 - (_DistanceFallof*partZ))),0.0)));
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
////// Lighting:
                float3 finalColor = 0;
/// Final Color:
                return fixed4(lerp(sceneColor.rgb, finalColor,0.0),1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
