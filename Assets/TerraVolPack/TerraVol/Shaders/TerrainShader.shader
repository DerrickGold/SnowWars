// TERRAVOL TERRAIN SHADER
// Copyright(c) TerraVol, 2013. Do not redistribute.

Shader "TerraVol/Terrain" {
	Properties {
		_Color ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_TilingTop ("Tiling Top", Float) = 1
		_TilingSides ("Tiling Sides", Float) = 1
		_TilingRed ("Tiling Red", Float) = 1
		_TilingGreen ("Tiling Green", Float) = 1
		_TilingBlue ("Tiling Blue", Float) = 1
		_TilingAlpha ("Tiling Alpha", Float) = 1
		_MainTex ("Top (RGB)", 2D) = "white" {}
		_MainTex2 ("Sides (RGB)", 2D) = "white" {}
		_BlendTex1 ("Top Blend Red (RGBA)", 2D) = "white" {}
		_BlendTex2 ("Top Blend Green (RGBA)", 2D) = "white" {}
		_BlendTex3 ("Top Blend Blue (RGBA)", 2D) = "white" {}
		_BlendTex4 ("Top Blend Alpha (RGBA)", 2D) = "white" {}		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		LOD 400
			
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
Program "vp" {
// Vertex combos: 12
//   opengl - ALU: 13 to 68
//   d3d9 - ALU: 13 to 68
SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_WorldSpaceCameraPos]
Vector 10 [unity_SHAr]
Vector 11 [unity_SHAg]
Vector 12 [unity_SHAb]
Vector 13 [unity_SHBr]
Vector 14 [unity_SHBg]
Vector 15 [unity_SHBb]
Vector 16 [unity_SHC]
Matrix 5 [_Object2World]
Vector 17 [unity_Scale]
"3.0-!!ARBvp1.0
# 33 ALU
PARAM c[18] = { { 1 },
		state.matrix.mvp,
		program.local[5..17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, vertex.normal, c[17].w;
DP3 R3.xy, R1, c[6];
DP3 R2.zw, R1, c[7];
DP3 R0.x, R1, c[5];
MOV R0.y, R3.x;
MOV R0.z, R2;
MOV R0.w, c[0].x;
MUL R1, R0.xyzz, R0.yzzx;
DP4 R2.z, R0, c[12];
DP4 R2.y, R0, c[11];
DP4 R2.x, R0, c[10];
MUL R0.y, R3.x, R3.x;
MAD R3.x, R0, R0, -R0.y;
DP4 R0.z, R1, c[14];
DP4 R0.y, R1, c[13];
DP4 R0.w, R1, c[15];
ADD R2.xyz, R2, R0.yzww;
MUL R1.xyz, R3.x, c[16];
MOV R0.z, R2.w;
MOV R0.y, R3;
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
ADD result.texcoord[4].xyz, R2, R1;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[0].xyz, R0;
ADD result.texcoord[5].xyz, -R0, c[9];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 33 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [unity_SHAr]
Vector 10 [unity_SHAg]
Vector 11 [unity_SHAb]
Vector 12 [unity_SHBr]
Vector 13 [unity_SHBg]
Vector 14 [unity_SHBb]
Vector 15 [unity_SHC]
Matrix 4 [_Object2World]
Vector 16 [unity_Scale]
"vs_3_0
; 33 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c17, 1.00000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c16.w
dp3 r3.xy, r1, c5
dp3 r2.zw, r1, c6
dp3 r0.x, r1, c4
mov r0.y, r3.x
mov r0.z, r2
mov r0.w, c17.x
mul r1, r0.xyzz, r0.yzzx
dp4 r2.z, r0, c11
dp4 r2.y, r0, c10
dp4 r2.x, r0, c9
mul r0.y, r3.x, r3.x
mad r3.x, r0, r0, -r0.y
dp4 r0.z, r1, c13
dp4 r0.y, r1, c12
dp4 r0.w, r1, c14
add r2.xyz, r2, r0.yzww
mul r1.xyz, r3.x, c15
mov r0.z, r2.w
mov r0.y, r3
mov o2.xyz, r0
mov o4.xyz, r0
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
add o5.xyz, r2, r1
mov o3, v2
mov o1.xyz, r0
add o6.xyz, -r0, c8
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 c_105;
  lowp float tmpvar_106;
  tmpvar_106 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_107;
  tmpvar_107 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_106) * 2.0);
  c_105.xyz = tmpvar_107;
  c_105.w = 0.0;
  c_1.w = c_105.w;
  c_1.xyz = (c_105.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 c_105;
  lowp float tmpvar_106;
  tmpvar_106 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_107;
  tmpvar_107 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_106) * 2.0);
  c_105.xyz = tmpvar_107;
  c_105.w = 0.0;
  c_1.w = c_105.w;
  c_1.xyz = (c_105.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 5 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 13 ALU
PARAM c[11] = { program.local[0],
		state.matrix.mvp,
		program.local[5..10] };
TEMP R0;
MUL R0.xyz, vertex.normal, c[9].w;
MOV result.texcoord[2], vertex.color;
DP3 result.texcoord[1].z, R0, c[7];
DP3 result.texcoord[1].y, R0, c[6];
DP3 result.texcoord[1].x, R0, c[5];
MAD result.texcoord[3].xy, vertex.texcoord[1], c[10], c[10].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 13 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [_Object2World]
Vector 8 [unity_Scale]
Vector 9 [unity_LightmapST]
"vs_3_0
; 13 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dcl_color0 v3
mul r0.xyz, v1, c8.w
mov o3, v3
dp3 o2.z, r0, c6
dp3 o2.y, r0, c5
dp3 o2.x, r0, c4
mad o4.xy, v2, c9, c9.zwzw
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  mat3 tmpvar_1;
  tmpvar_1[0] = _Object2World[0].xyz;
  tmpvar_1[1] = _Object2World[1].xyz;
  tmpvar_1[2] = _Object2World[2].xyz;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_1 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  c_1.xyz = (tmpvar_2 * (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz));
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  mat3 tmpvar_1;
  tmpvar_1[0] = _Object2World[0].xyz;
  tmpvar_1[1] = _Object2World[1].xyz;
  tmpvar_1[2] = _Object2World[2].xyz;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_1 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 tmpvar_105;
  tmpvar_105 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  c_1.xyz = (tmpvar_2 * ((8.0 * tmpvar_105.w) * tmpvar_105.xyz));
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 14 [unity_Scale]
Vector 15 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 26 ALU
PARAM c[16] = { { 1 },
		state.matrix.mvp,
		program.local[5..15] };
TEMP R0;
TEMP R1;
TEMP R2;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R1.xyz, R0, vertex.attrib[14].w;
MOV R0.xyz, c[13];
MOV R0.w, c[0].x;
DP4 R2.z, R0, c[11];
DP4 R2.x, R0, c[9];
DP4 R2.y, R0, c[10];
MAD R0.xyz, R2, c[14].w, -vertex.position;
DP3 result.texcoord[4].y, R0, R1;
DP3 result.texcoord[4].z, vertex.normal, R0;
DP3 result.texcoord[4].x, R0, vertex.attrib[14];
MUL R0.xyz, vertex.normal, c[14].w;
MOV result.texcoord[2], vertex.color;
DP3 result.texcoord[1].z, R0, c[7];
DP3 result.texcoord[1].y, R0, c[6];
DP3 result.texcoord[1].x, R0, c[5];
MAD result.texcoord[3].xy, vertex.texcoord[1], c[15], c[15].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 26 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 13 [unity_Scale]
Vector 14 [unity_LightmapST]
"vs_3_0
; 27 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c15, 1.00000000, 0, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord1 v3
dcl_color0 v4
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r1.xyz, r0, v1.w
mov r0.xyz, c12
mov r0.w, c15.x
dp4 r2.z, r0, c10
dp4 r2.x, r0, c8
dp4 r2.y, r0, c9
mad r0.xyz, r2, c13.w, -v0
dp3 o5.y, r0, r1
dp3 o5.z, v2, r0
dp3 o5.x, r0, v1
mul r0.xyz, v2, c13.w
mov o3, v4
dp3 o2.z, r0, c6
dp3 o2.y, r0, c5
dp3 o2.x, r0, c4
mad o4.xy, v3, c14, c14.zwzw
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_4 = tmpvar_1.xyz;
  tmpvar_5 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_6;
  tmpvar_6[0].x = tmpvar_4.x;
  tmpvar_6[0].y = tmpvar_5.x;
  tmpvar_6[0].z = tmpvar_2.x;
  tmpvar_6[1].x = tmpvar_4.y;
  tmpvar_6[1].y = tmpvar_5.y;
  tmpvar_6[1].z = tmpvar_2.y;
  tmpvar_6[2].x = tmpvar_4.z;
  tmpvar_6[2].y = tmpvar_5.z;
  tmpvar_6[2].z = tmpvar_2.z;
  highp vec4 tmpvar_7;
  tmpvar_7.w = 1.0;
  tmpvar_7.xyz = _WorldSpaceCameraPos;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (tmpvar_6 * (((_World2Object * tmpvar_7).xyz * unity_Scale.w) - _glesVertex.xyz));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  highp vec3 tmpvar_105;
  tmpvar_105 = normalize(xlv_TEXCOORD4);
  mediump vec4 tmpvar_106;
  mediump vec3 viewDir_107;
  viewDir_107 = tmpvar_105;
  highp float nh_108;
  mediump vec3 scalePerBasisVector_109;
  mediump vec3 lm_110;
  lowp vec3 tmpvar_111;
  tmpvar_111 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lm_110 = tmpvar_111;
  lowp vec3 tmpvar_112;
  tmpvar_112 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD3).xyz);
  scalePerBasisVector_109 = tmpvar_112;
  mediump float tmpvar_113;
  tmpvar_113 = max (0.0, normalize((normalize((((scalePerBasisVector_109.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_109.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_109.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_107)).z);
  nh_108 = tmpvar_113;
  highp vec4 tmpvar_114;
  tmpvar_114.xyz = lm_110;
  tmpvar_114.w = pow (nh_108, 0.0);
  tmpvar_106 = tmpvar_114;
  mediump vec3 tmpvar_115;
  tmpvar_115 = (tmpvar_2 * tmpvar_106.xyz);
  c_1.xyz = tmpvar_115;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_4 = tmpvar_1.xyz;
  tmpvar_5 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_6;
  tmpvar_6[0].x = tmpvar_4.x;
  tmpvar_6[0].y = tmpvar_5.x;
  tmpvar_6[0].z = tmpvar_2.x;
  tmpvar_6[1].x = tmpvar_4.y;
  tmpvar_6[1].y = tmpvar_5.y;
  tmpvar_6[1].z = tmpvar_2.y;
  tmpvar_6[2].x = tmpvar_4.z;
  tmpvar_6[2].y = tmpvar_5.z;
  tmpvar_6[2].z = tmpvar_2.z;
  highp vec4 tmpvar_7;
  tmpvar_7.w = 1.0;
  tmpvar_7.xyz = _WorldSpaceCameraPos;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (tmpvar_6 * (((_World2Object * tmpvar_7).xyz * unity_Scale.w) - _glesVertex.xyz));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 tmpvar_105;
  tmpvar_105 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  lowp vec4 tmpvar_106;
  tmpvar_106 = texture2D (unity_LightmapInd, xlv_TEXCOORD3);
  highp vec3 tmpvar_107;
  tmpvar_107 = normalize(xlv_TEXCOORD4);
  mediump vec4 tmpvar_108;
  mediump vec3 viewDir_109;
  viewDir_109 = tmpvar_107;
  highp float nh_110;
  mediump vec3 scalePerBasisVector_111;
  mediump vec3 lm_112;
  lowp vec3 tmpvar_113;
  tmpvar_113 = ((8.0 * tmpvar_105.w) * tmpvar_105.xyz);
  lm_112 = tmpvar_113;
  lowp vec3 tmpvar_114;
  tmpvar_114 = ((8.0 * tmpvar_106.w) * tmpvar_106.xyz);
  scalePerBasisVector_111 = tmpvar_114;
  mediump float tmpvar_115;
  tmpvar_115 = max (0.0, normalize((normalize((((scalePerBasisVector_111.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_111.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_111.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_109)).z);
  nh_110 = tmpvar_115;
  highp vec4 tmpvar_116;
  tmpvar_116.xyz = lm_112;
  tmpvar_116.w = pow (nh_110, 0.0);
  tmpvar_108 = tmpvar_116;
  mediump vec3 tmpvar_117;
  tmpvar_117 = (tmpvar_2 * tmpvar_108.xyz);
  c_1.xyz = tmpvar_117;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_WorldSpaceCameraPos]
Vector 10 [_ProjectionParams]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
Matrix 5 [_Object2World]
Vector 18 [unity_Scale]
"3.0-!!ARBvp1.0
# 40 ALU
PARAM c[19] = { { 1, 0.5 },
		state.matrix.mvp,
		program.local[5..18] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R2.xyz, vertex.normal, c[18].w;
DP3 R1.zw, R2, c[6];
DP3 R3.zw, R2, c[7];
DP3 R0.z, R2, c[5];
MUL R1.x, R1.z, R1.z;
MOV R0.x, R1.z;
MOV R0.y, R3.z;
MOV R0.w, c[0].x;
MAD R1.x, R0.z, R0.z, -R1;
MUL R2, R0.zxyy, R0.xyyz;
DP4 R3.z, R0.zxyw, c[13];
DP4 R3.y, R0.zxyw, c[12];
DP4 R3.x, R0.zxyw, c[11];
MUL R1.xyz, R1.x, c[17];
DP4 R0.w, R2, c[16];
DP4 R0.y, R2, c[15];
DP4 R0.x, R2, c[14];
ADD R2.xyz, R3, R0.xyww;
ADD result.texcoord[4].xyz, R2, R1;
DP4 R0.w, vertex.position, c[4];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R3.xyz, R0.xyww, c[0].y;
MUL R1.y, R3, c[10].x;
MOV R1.x, R3;
ADD result.texcoord[6].xy, R1, R3.z;
MOV R1.x, R0.z;
DP4 R0.z, vertex.position, c[3];
MOV result.position, R0;
MOV result.texcoord[6].zw, R0;
MOV R1.z, R3.w;
MOV R1.y, R1.w;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
MOV result.texcoord[1].xyz, R1;
MOV result.texcoord[3].xyz, R1;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[0].xyz, R0;
ADD result.texcoord[5].xyz, -R0, c[9];
END
# 40 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [_ProjectionParams]
Vector 10 [_ScreenParams]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
Matrix 4 [_Object2World]
Vector 18 [unity_Scale]
"vs_3_0
; 40 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_texcoord6 o7
def c19, 1.00000000, 0.50000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r2.xyz, v1, c18.w
dp3 r1.zw, r2, c5
dp3 r3.zw, r2, c6
dp3 r0.z, r2, c4
mul r1.x, r1.z, r1.z
mov r0.x, r1.z
mov r0.y, r3.z
mov r0.w, c19.x
mad r1.x, r0.z, r0.z, -r1
mul r2, r0.zxyy, r0.xyyz
dp4 r3.z, r0.zxyw, c13
dp4 r3.y, r0.zxyw, c12
dp4 r3.x, r0.zxyw, c11
mul r1.xyz, r1.x, c17
dp4 r0.w, r2, c16
dp4 r0.y, r2, c15
dp4 r0.x, r2, c14
add r2.xyz, r3, r0.xyww
add o5.xyz, r2, r1
dp4 r0.w, v0, c3
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r3.xyz, r0.xyww, c19.y
mul r1.y, r3, c9.x
mov r1.x, r3
mad o7.xy, r3.z, c10.zwzw, r1
mov r1.x, r0.z
dp4 r0.z, v0, c2
mov o0, r0
mov o7.zw, r0
mov r1.z, r3.w
mov r1.y, r1.w
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mov o2.xyz, r1
mov o4.xyz, r1
mov o3, v2
mov o1.xyz, r0
add o6.xyz, -r0, c8
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD6;
varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  xlv_TEXCOORD6 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD6;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float tmpvar_105;
  mediump float lightShadowDataX_106;
  highp float dist_107;
  lowp float tmpvar_108;
  tmpvar_108 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD6).x;
  dist_107 = tmpvar_108;
  highp float tmpvar_109;
  tmpvar_109 = _LightShadowData.x;
  lightShadowDataX_106 = tmpvar_109;
  highp float tmpvar_110;
  tmpvar_110 = max (float((dist_107 > (xlv_TEXCOORD6.z / xlv_TEXCOORD6.w))), lightShadowDataX_106);
  tmpvar_105 = tmpvar_110;
  lowp vec4 c_111;
  lowp float tmpvar_112;
  tmpvar_112 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_113;
  tmpvar_113 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_112) * (tmpvar_105 * 2.0));
  c_111.xyz = tmpvar_113;
  c_111.w = 0.0;
  c_1.w = c_111.w;
  c_1.xyz = (c_111.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD6;
varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_6;
  tmpvar_6 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = tmpvar_8;
  mediump vec3 tmpvar_10;
  mediump vec4 normal_11;
  normal_11 = tmpvar_9;
  highp float vC_12;
  mediump vec3 x3_13;
  mediump vec3 x2_14;
  mediump vec3 x1_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAr, normal_11);
  x1_15.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAg, normal_11);
  x1_15.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHAb, normal_11);
  x1_15.z = tmpvar_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = (normal_11.xyzz * normal_11.yzzx);
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBr, tmpvar_19);
  x2_14.x = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBg, tmpvar_19);
  x2_14.y = tmpvar_21;
  highp float tmpvar_22;
  tmpvar_22 = dot (unity_SHBb, tmpvar_19);
  x2_14.z = tmpvar_22;
  mediump float tmpvar_23;
  tmpvar_23 = ((normal_11.x * normal_11.x) - (normal_11.y * normal_11.y));
  vC_12 = tmpvar_23;
  highp vec3 tmpvar_24;
  tmpvar_24 = (unity_SHC.xyz * vC_12);
  x3_13 = tmpvar_24;
  tmpvar_10 = ((x1_15 + x2_14) + x3_13);
  shlight_2 = tmpvar_10;
  tmpvar_4 = shlight_2;
  highp vec4 o_25;
  highp vec4 tmpvar_26;
  tmpvar_26 = (tmpvar_6 * 0.5);
  highp vec2 tmpvar_27;
  tmpvar_27.x = tmpvar_26.x;
  tmpvar_27.y = (tmpvar_26.y * _ProjectionParams.x);
  o_25.xy = (tmpvar_27 + tmpvar_26.w);
  o_25.zw = tmpvar_6.zw;
  gl_Position = tmpvar_6;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  xlv_TEXCOORD6 = o_25;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD6;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 tmpvar_105;
  tmpvar_105 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD6);
  lowp vec4 c_106;
  lowp float tmpvar_107;
  tmpvar_107 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_108;
  tmpvar_108 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_107) * (tmpvar_105.x * 2.0));
  c_106.xyz = tmpvar_108;
  c_106.w = 0.0;
  c_1.w = c_106.w;
  c_1.xyz = (c_106.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 9 [_ProjectionParams]
Matrix 5 [_Object2World]
Vector 10 [unity_Scale]
Vector 11 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 18 ALU
PARAM c[12] = { { 0.5 },
		state.matrix.mvp,
		program.local[5..11] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].x;
MUL R1.y, R1, c[9].x;
ADD result.texcoord[4].xy, R1, R1.z;
MUL R1.xyz, vertex.normal, c[10].w;
MOV result.position, R0;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[4].zw, R0;
DP3 result.texcoord[1].z, R1, c[7];
DP3 result.texcoord[1].y, R1, c[6];
DP3 result.texcoord[1].x, R1, c[5];
MAD result.texcoord[3].xy, vertex.texcoord[1], c[11], c[11].zwzw;
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 18 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Matrix 4 [_Object2World]
Vector 10 [unity_Scale]
Vector 11 [unity_LightmapST]
"vs_3_0
; 18 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c12, 0.50000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dcl_color0 v3
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c12.x
mul r1.y, r1, c8.x
mad o5.xy, r1.z, c9.zwzw, r1
mul r1.xyz, v1, c10.w
mov o0, r0
mov o3, v3
mov o5.zw, r0
dp3 o2.z, r1, c6
dp3 o2.y, r1, c5
dp3 o2.x, r1, c4
mad o4.xy, v2, c11, c11.zwzw
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  mat3 tmpvar_1;
  tmpvar_1[0] = _Object2World[0].xyz;
  tmpvar_1[1] = _Object2World[1].xyz;
  tmpvar_1[2] = _Object2World[2].xyz;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_1 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float tmpvar_105;
  mediump float lightShadowDataX_106;
  highp float dist_107;
  lowp float tmpvar_108;
  tmpvar_108 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD4).x;
  dist_107 = tmpvar_108;
  highp float tmpvar_109;
  tmpvar_109 = _LightShadowData.x;
  lightShadowDataX_106 = tmpvar_109;
  highp float tmpvar_110;
  tmpvar_110 = max (float((dist_107 > (xlv_TEXCOORD4.z / xlv_TEXCOORD4.w))), lightShadowDataX_106);
  tmpvar_105 = tmpvar_110;
  c_1.xyz = (tmpvar_2 * min ((2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz), vec3((tmpvar_105 * 2.0))));
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _ProjectionParams;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  mat3 tmpvar_1;
  tmpvar_1[0] = _Object2World[0].xyz;
  tmpvar_1[1] = _Object2World[1].xyz;
  tmpvar_1[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_3;
  highp vec4 tmpvar_4;
  tmpvar_4 = (tmpvar_2 * 0.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = tmpvar_4.x;
  tmpvar_5.y = (tmpvar_4.y * _ProjectionParams.x);
  o_3.xy = (tmpvar_5 + tmpvar_4.w);
  o_3.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_1 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = o_3;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 tmpvar_105;
  tmpvar_105 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD4);
  lowp vec4 tmpvar_106;
  tmpvar_106 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  lowp vec3 tmpvar_107;
  tmpvar_107 = ((8.0 * tmpvar_106.w) * tmpvar_106.xyz);
  c_1.xyz = (tmpvar_2 * max (min (tmpvar_107, ((tmpvar_105.x * 2.0) * tmpvar_106.xyz)), (tmpvar_107 * tmpvar_105.x)));
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_ProjectionParams]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 31 ALU
PARAM c[17] = { { 1, 0.5 },
		state.matrix.mvp,
		program.local[5..16] };
TEMP R0;
TEMP R1;
TEMP R2;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R0.xyz, R0, vertex.attrib[14].w;
MOV R1.xyz, c[13];
MOV R1.w, c[0].x;
DP4 R0.w, vertex.position, c[4];
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R2.xyz, R2, c[15].w, -vertex.position;
DP3 result.texcoord[4].y, R2, R0;
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].y;
MUL R1.y, R1, c[14].x;
ADD result.texcoord[5].xy, R1, R1.z;
MUL R1.xyz, vertex.normal, c[15].w;
DP3 result.texcoord[4].z, vertex.normal, R2;
DP3 result.texcoord[4].x, R2, vertex.attrib[14];
MOV result.position, R0;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[5].zw, R0;
DP3 result.texcoord[1].z, R1, c[7];
DP3 result.texcoord[1].y, R1, c[6];
DP3 result.texcoord[1].x, R1, c[5];
MAD result.texcoord[3].xy, vertex.texcoord[1], c[16], c[16].zwzw;
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 31 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_ProjectionParams]
Vector 14 [_ScreenParams]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"vs_3_0
; 32 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c17, 1.00000000, 0.50000000, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord1 v3
dcl_color0 v4
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r0.xyz, r0, v1.w
mov r1.xyz, c12
mov r1.w, c17.x
dp4 r0.w, v0, c3
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r2.xyz, r2, c15.w, -v0
dp3 o5.y, r2, r0
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c17.y
mul r1.y, r1, c13.x
mad o6.xy, r1.z, c14.zwzw, r1
mul r1.xyz, v2, c15.w
dp3 o5.z, v2, r2
dp3 o5.x, r2, v1
mov o0, r0
mov o3, v4
mov o6.zw, r0
dp3 o2.z, r1, c6
dp3 o2.y, r1, c5
dp3 o2.x, r1, c4
mad o4.xy, v3, c16, c16.zwzw
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_4 = tmpvar_1.xyz;
  tmpvar_5 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_6;
  tmpvar_6[0].x = tmpvar_4.x;
  tmpvar_6[0].y = tmpvar_5.x;
  tmpvar_6[0].z = tmpvar_2.x;
  tmpvar_6[1].x = tmpvar_4.y;
  tmpvar_6[1].y = tmpvar_5.y;
  tmpvar_6[1].z = tmpvar_2.y;
  tmpvar_6[2].x = tmpvar_4.z;
  tmpvar_6[2].y = tmpvar_5.z;
  tmpvar_6[2].z = tmpvar_2.z;
  highp vec4 tmpvar_7;
  tmpvar_7.w = 1.0;
  tmpvar_7.xyz = _WorldSpaceCameraPos;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (tmpvar_6 * (((_World2Object * tmpvar_7).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD5 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float tmpvar_105;
  mediump float lightShadowDataX_106;
  highp float dist_107;
  lowp float tmpvar_108;
  tmpvar_108 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD5).x;
  dist_107 = tmpvar_108;
  highp float tmpvar_109;
  tmpvar_109 = _LightShadowData.x;
  lightShadowDataX_106 = tmpvar_109;
  highp float tmpvar_110;
  tmpvar_110 = max (float((dist_107 > (xlv_TEXCOORD5.z / xlv_TEXCOORD5.w))), lightShadowDataX_106);
  tmpvar_105 = tmpvar_110;
  highp vec3 tmpvar_111;
  tmpvar_111 = normalize(xlv_TEXCOORD4);
  mediump vec4 tmpvar_112;
  mediump vec3 viewDir_113;
  viewDir_113 = tmpvar_111;
  highp float nh_114;
  mediump vec3 scalePerBasisVector_115;
  mediump vec3 lm_116;
  lowp vec3 tmpvar_117;
  tmpvar_117 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lm_116 = tmpvar_117;
  lowp vec3 tmpvar_118;
  tmpvar_118 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD3).xyz);
  scalePerBasisVector_115 = tmpvar_118;
  mediump float tmpvar_119;
  tmpvar_119 = max (0.0, normalize((normalize((((scalePerBasisVector_115.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_115.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_115.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_113)).z);
  nh_114 = tmpvar_119;
  highp vec4 tmpvar_120;
  tmpvar_120.xyz = lm_116;
  tmpvar_120.w = pow (nh_114, 0.0);
  tmpvar_112 = tmpvar_120;
  lowp vec3 tmpvar_121;
  tmpvar_121 = vec3((tmpvar_105 * 2.0));
  mediump vec3 tmpvar_122;
  tmpvar_122 = (tmpvar_2 * min (tmpvar_112.xyz, tmpvar_121));
  c_1.xyz = tmpvar_122;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec3 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_5 = tmpvar_1.xyz;
  tmpvar_6 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_7;
  tmpvar_7[0].x = tmpvar_5.x;
  tmpvar_7[0].y = tmpvar_6.x;
  tmpvar_7[0].z = tmpvar_2.x;
  tmpvar_7[1].x = tmpvar_5.y;
  tmpvar_7[1].y = tmpvar_6.y;
  tmpvar_7[1].z = tmpvar_2.y;
  tmpvar_7[2].x = tmpvar_5.z;
  tmpvar_7[2].y = tmpvar_6.z;
  tmpvar_7[2].z = tmpvar_2.z;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = _WorldSpaceCameraPos;
  highp vec4 o_9;
  highp vec4 tmpvar_10;
  tmpvar_10 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_11;
  tmpvar_11.x = tmpvar_10.x;
  tmpvar_11.y = (tmpvar_10.y * _ProjectionParams.x);
  o_9.xy = (tmpvar_11 + tmpvar_10.w);
  o_9.zw = tmpvar_4.zw;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (tmpvar_7 * (((_World2Object * tmpvar_8).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD5 = o_9;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 tmpvar_105;
  tmpvar_105 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD5);
  lowp vec4 tmpvar_106;
  tmpvar_106 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2D (unity_LightmapInd, xlv_TEXCOORD3);
  highp vec3 tmpvar_108;
  tmpvar_108 = normalize(xlv_TEXCOORD4);
  mediump vec4 tmpvar_109;
  mediump vec3 viewDir_110;
  viewDir_110 = tmpvar_108;
  highp float nh_111;
  mediump vec3 scalePerBasisVector_112;
  mediump vec3 lm_113;
  lowp vec3 tmpvar_114;
  tmpvar_114 = ((8.0 * tmpvar_106.w) * tmpvar_106.xyz);
  lm_113 = tmpvar_114;
  lowp vec3 tmpvar_115;
  tmpvar_115 = ((8.0 * tmpvar_107.w) * tmpvar_107.xyz);
  scalePerBasisVector_112 = tmpvar_115;
  mediump float tmpvar_116;
  tmpvar_116 = max (0.0, normalize((normalize((((scalePerBasisVector_112.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_112.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_112.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_110)).z);
  nh_111 = tmpvar_116;
  highp vec4 tmpvar_117;
  tmpvar_117.xyz = lm_113;
  tmpvar_117.w = pow (nh_111, 0.0);
  tmpvar_109 = tmpvar_117;
  lowp vec3 arg1_118;
  arg1_118 = ((tmpvar_105.x * 2.0) * tmpvar_106.xyz);
  mediump vec3 tmpvar_119;
  tmpvar_119 = (tmpvar_2 * max (min (tmpvar_109.xyz, arg1_118), (tmpvar_109.xyz * tmpvar_105.x)));
  c_1.xyz = tmpvar_119;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_WorldSpaceCameraPos]
Vector 10 [unity_4LightPosX0]
Vector 11 [unity_4LightPosY0]
Vector 12 [unity_4LightPosZ0]
Vector 13 [unity_4LightAtten0]
Vector 14 [unity_LightColor0]
Vector 15 [unity_LightColor1]
Vector 16 [unity_LightColor2]
Vector 17 [unity_LightColor3]
Vector 18 [unity_SHAr]
Vector 19 [unity_SHAg]
Vector 20 [unity_SHAb]
Vector 21 [unity_SHBr]
Vector 22 [unity_SHBg]
Vector 23 [unity_SHBb]
Vector 24 [unity_SHC]
Matrix 5 [_Object2World]
Vector 25 [unity_Scale]
"3.0-!!ARBvp1.0
# 62 ALU
PARAM c[26] = { { 1, 0 },
		state.matrix.mvp,
		program.local[5..25] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
MUL R3.xyz, vertex.normal, c[25].w;
DP3 R4.xy, R3, c[6];
DP3 R5.x, R3, c[5];
DP3 R3.xy, R3, c[7];
DP4 R6.xy, vertex.position, c[6];
ADD R2, -R6.x, c[11];
DP4 R6.x, vertex.position, c[5];
MUL R0, R4.x, R2;
ADD R1, -R6.x, c[10];
DP4 R4.zw, vertex.position, c[7];
MOV R6.z, R4.w;
MUL R2, R2, R2;
MOV R5.z, R3.x;
MOV R5.y, R4.x;
MOV R5.w, c[0].x;
MAD R0, R5.x, R1, R0;
MAD R2, R1, R1, R2;
ADD R1, -R4.z, c[12];
MAD R2, R1, R1, R2;
MAD R0, R3.x, R1, R0;
MUL R1, R2, c[13];
ADD R1, R1, c[0].x;
RSQ R2.x, R2.x;
RSQ R2.y, R2.y;
RSQ R2.z, R2.z;
RSQ R2.w, R2.w;
MUL R0, R0, R2;
RCP R1.x, R1.x;
RCP R1.y, R1.y;
RCP R1.w, R1.w;
RCP R1.z, R1.z;
MAX R0, R0, c[0].y;
MUL R0, R0, R1;
MUL R1.xyz, R0.y, c[15];
MAD R1.xyz, R0.x, c[14], R1;
MAD R0.xyz, R0.z, c[16], R1;
MAD R1.xyz, R0.w, c[17], R0;
MUL R0, R5.xyzz, R5.yzzx;
MUL R1.w, R4.x, R4.x;
DP4 R3.w, R0, c[23];
DP4 R3.z, R0, c[22];
DP4 R3.x, R0, c[21];
MAD R1.w, R5.x, R5.x, -R1;
DP4 R2.z, R5, c[20];
DP4 R2.y, R5, c[19];
DP4 R2.x, R5, c[18];
MUL R0.xyz, R1.w, c[24];
ADD R2.xyz, R2, R3.xzww;
ADD R0.xyz, R2, R0;
ADD result.texcoord[4].xyz, R0, R1;
MOV R0.z, R3.y;
MOV R0.x, R5;
MOV R0.y, R4;
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[0].xyz, R6;
ADD result.texcoord[5].xyz, -R6, c[9];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 62 instructions, 7 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [unity_4LightPosX0]
Vector 10 [unity_4LightPosY0]
Vector 11 [unity_4LightPosZ0]
Vector 12 [unity_4LightAtten0]
Vector 13 [unity_LightColor0]
Vector 14 [unity_LightColor1]
Vector 15 [unity_LightColor2]
Vector 16 [unity_LightColor3]
Vector 17 [unity_SHAr]
Vector 18 [unity_SHAg]
Vector 19 [unity_SHAb]
Vector 20 [unity_SHBr]
Vector 21 [unity_SHBg]
Vector 22 [unity_SHBb]
Vector 23 [unity_SHC]
Matrix 4 [_Object2World]
Vector 24 [unity_Scale]
"vs_3_0
; 62 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c25, 1.00000000, 0.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r3.xyz, v1, c24.w
dp3 r4.xy, r3, c5
dp3 r5.x, r3, c4
dp3 r3.xy, r3, c6
dp4 r6.xy, v0, c5
add r2, -r6.x, c10
dp4 r6.x, v0, c4
mul r0, r4.x, r2
add r1, -r6.x, c9
dp4 r4.zw, v0, c6
mov r6.z, r4.w
mul r2, r2, r2
mov r5.z, r3.x
mov r5.y, r4.x
mov r5.w, c25.x
mad r0, r5.x, r1, r0
mad r2, r1, r1, r2
add r1, -r4.z, c11
mad r2, r1, r1, r2
mad r0, r3.x, r1, r0
mul r1, r2, c12
add r1, r1, c25.x
rsq r2.x, r2.x
rsq r2.y, r2.y
rsq r2.z, r2.z
rsq r2.w, r2.w
mul r0, r0, r2
rcp r1.x, r1.x
rcp r1.y, r1.y
rcp r1.w, r1.w
rcp r1.z, r1.z
max r0, r0, c25.y
mul r0, r0, r1
mul r1.xyz, r0.y, c14
mad r1.xyz, r0.x, c13, r1
mad r0.xyz, r0.z, c15, r1
mad r1.xyz, r0.w, c16, r0
mul r0, r5.xyzz, r5.yzzx
mul r1.w, r4.x, r4.x
dp4 r3.w, r0, c22
dp4 r3.z, r0, c21
dp4 r3.x, r0, c20
mad r1.w, r5.x, r5.x, -r1
dp4 r2.z, r5, c19
dp4 r2.y, r5, c18
dp4 r2.x, r5, c17
mul r0.xyz, r1.w, c23
add r2.xyz, r2, r3.xzww
add r0.xyz, r2, r0
add o5.xyz, r0, r1
mov r0.z, r3.y
mov r0.x, r5
mov r0.y, r4
mov o2.xyz, r0
mov o4.xyz, r0
mov o3, v2
mov o1.xyz, r6
add o6.xyz, -r6, c8
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  highp vec3 tmpvar_24;
  tmpvar_24 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_25;
  tmpvar_25 = (unity_4LightPosX0 - tmpvar_24.x);
  highp vec4 tmpvar_26;
  tmpvar_26 = (unity_4LightPosY0 - tmpvar_24.y);
  highp vec4 tmpvar_27;
  tmpvar_27 = (unity_4LightPosZ0 - tmpvar_24.z);
  highp vec4 tmpvar_28;
  tmpvar_28 = (((tmpvar_25 * tmpvar_25) + (tmpvar_26 * tmpvar_26)) + (tmpvar_27 * tmpvar_27));
  highp vec4 tmpvar_29;
  tmpvar_29 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_25 * tmpvar_7.x) + (tmpvar_26 * tmpvar_7.y)) + (tmpvar_27 * tmpvar_7.z)) * inversesqrt(tmpvar_28))) * (1.0/((1.0 + (tmpvar_28 * unity_4LightAtten0)))));
  highp vec3 tmpvar_30;
  tmpvar_30 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_29.x) + (unity_LightColor[1].xyz * tmpvar_29.y)) + (unity_LightColor[2].xyz * tmpvar_29.z)) + (unity_LightColor[3].xyz * tmpvar_29.w)));
  tmpvar_4 = tmpvar_30;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 c_105;
  lowp float tmpvar_106;
  tmpvar_106 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_107;
  tmpvar_107 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_106) * 2.0);
  c_105.xyz = tmpvar_107;
  c_105.w = 0.0;
  c_1.w = c_105.w;
  c_1.xyz = (c_105.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  highp vec3 tmpvar_24;
  tmpvar_24 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_25;
  tmpvar_25 = (unity_4LightPosX0 - tmpvar_24.x);
  highp vec4 tmpvar_26;
  tmpvar_26 = (unity_4LightPosY0 - tmpvar_24.y);
  highp vec4 tmpvar_27;
  tmpvar_27 = (unity_4LightPosZ0 - tmpvar_24.z);
  highp vec4 tmpvar_28;
  tmpvar_28 = (((tmpvar_25 * tmpvar_25) + (tmpvar_26 * tmpvar_26)) + (tmpvar_27 * tmpvar_27));
  highp vec4 tmpvar_29;
  tmpvar_29 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_25 * tmpvar_7.x) + (tmpvar_26 * tmpvar_7.y)) + (tmpvar_27 * tmpvar_7.z)) * inversesqrt(tmpvar_28))) * (1.0/((1.0 + (tmpvar_28 * unity_4LightAtten0)))));
  highp vec3 tmpvar_30;
  tmpvar_30 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_29.x) + (unity_LightColor[1].xyz * tmpvar_29.y)) + (unity_LightColor[2].xyz * tmpvar_29.z)) + (unity_LightColor[3].xyz * tmpvar_29.w)));
  tmpvar_4 = tmpvar_30;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 c_105;
  lowp float tmpvar_106;
  tmpvar_106 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_107;
  tmpvar_107 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_106) * 2.0);
  c_105.xyz = tmpvar_107;
  c_105.w = 0.0;
  c_1.w = c_105.w;
  c_1.xyz = (c_105.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_WorldSpaceCameraPos]
Vector 10 [_ProjectionParams]
Vector 11 [unity_4LightPosX0]
Vector 12 [unity_4LightPosY0]
Vector 13 [unity_4LightPosZ0]
Vector 14 [unity_4LightAtten0]
Vector 15 [unity_LightColor0]
Vector 16 [unity_LightColor1]
Vector 17 [unity_LightColor2]
Vector 18 [unity_LightColor3]
Vector 19 [unity_SHAr]
Vector 20 [unity_SHAg]
Vector 21 [unity_SHAb]
Vector 22 [unity_SHBr]
Vector 23 [unity_SHBg]
Vector 24 [unity_SHBb]
Vector 25 [unity_SHC]
Matrix 5 [_Object2World]
Vector 26 [unity_Scale]
"3.0-!!ARBvp1.0
# 68 ALU
PARAM c[27] = { { 1, 0, 0.5 },
		state.matrix.mvp,
		program.local[5..26] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
MUL R3.xyz, vertex.normal, c[26].w;
DP3 R4.xy, R3, c[6];
DP3 R5.x, R3, c[5];
DP3 R3.xy, R3, c[7];
DP4 R6.xy, vertex.position, c[6];
ADD R2, -R6.x, c[12];
DP4 R6.x, vertex.position, c[5];
MUL R0, R4.x, R2;
ADD R1, -R6.x, c[11];
DP4 R4.zw, vertex.position, c[7];
MOV R6.z, R4.w;
MUL R2, R2, R2;
MOV R5.z, R3.x;
MOV R5.y, R4.x;
MOV R5.w, c[0].x;
MAD R0, R5.x, R1, R0;
MAD R2, R1, R1, R2;
ADD R1, -R4.z, c[13];
MAD R2, R1, R1, R2;
MAD R0, R3.x, R1, R0;
MUL R1, R2, c[14];
ADD R1, R1, c[0].x;
RSQ R2.x, R2.x;
RSQ R2.y, R2.y;
RSQ R2.z, R2.z;
RSQ R2.w, R2.w;
MUL R0, R0, R2;
RCP R1.x, R1.x;
RCP R1.y, R1.y;
RCP R1.w, R1.w;
RCP R1.z, R1.z;
MAX R0, R0, c[0].y;
MUL R0, R0, R1;
MUL R1.xyz, R0.y, c[16];
MAD R1.xyz, R0.x, c[15], R1;
MAD R0.xyz, R0.z, c[17], R1;
MAD R1.xyz, R0.w, c[18], R0;
MUL R0, R5.xyzz, R5.yzzx;
MUL R1.w, R4.x, R4.x;
DP4 R3.w, R0, c[24];
DP4 R3.z, R0, c[23];
DP4 R3.x, R0, c[22];
MAD R1.w, R5.x, R5.x, -R1;
MUL R0.xyz, R1.w, c[25];
DP4 R0.w, vertex.position, c[4];
DP4 R2.z, R5, c[21];
DP4 R2.y, R5, c[20];
DP4 R2.x, R5, c[19];
ADD R2.xyz, R2, R3.xzww;
ADD R2.xyz, R2, R0;
ADD result.texcoord[4].xyz, R2, R1;
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R3.xzw, R0.xyyw, c[0].z;
MUL R1.y, R3.z, c[10].x;
MOV R1.x, R3;
ADD result.texcoord[6].xy, R1, R3.w;
MOV R1.z, R3.y;
MOV R1.x, R5;
MOV R1.y, R4;
MOV result.texcoord[1].xyz, R1;
MOV result.texcoord[3].xyz, R1;
MOV result.position, R0;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[6].zw, R0;
MOV result.texcoord[0].xyz, R6;
ADD result.texcoord[5].xyz, -R6, c[9];
END
# 68 instructions, 7 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [_ProjectionParams]
Vector 10 [_ScreenParams]
Vector 11 [unity_4LightPosX0]
Vector 12 [unity_4LightPosY0]
Vector 13 [unity_4LightPosZ0]
Vector 14 [unity_4LightAtten0]
Vector 15 [unity_LightColor0]
Vector 16 [unity_LightColor1]
Vector 17 [unity_LightColor2]
Vector 18 [unity_LightColor3]
Vector 19 [unity_SHAr]
Vector 20 [unity_SHAg]
Vector 21 [unity_SHAb]
Vector 22 [unity_SHBr]
Vector 23 [unity_SHBg]
Vector 24 [unity_SHBb]
Vector 25 [unity_SHC]
Matrix 4 [_Object2World]
Vector 26 [unity_Scale]
"vs_3_0
; 68 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_texcoord6 o7
def c27, 1.00000000, 0.00000000, 0.50000000, 0
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r3.xyz, v1, c26.w
dp3 r4.xy, r3, c5
dp3 r5.x, r3, c4
dp3 r3.xy, r3, c6
dp4 r6.xy, v0, c5
add r2, -r6.x, c12
dp4 r6.x, v0, c4
mul r0, r4.x, r2
add r1, -r6.x, c11
dp4 r4.zw, v0, c6
mov r6.z, r4.w
mul r2, r2, r2
mov r5.z, r3.x
mov r5.y, r4.x
mov r5.w, c27.x
mad r0, r5.x, r1, r0
mad r2, r1, r1, r2
add r1, -r4.z, c13
mad r2, r1, r1, r2
mad r0, r3.x, r1, r0
mul r1, r2, c14
add r1, r1, c27.x
rsq r2.x, r2.x
rsq r2.y, r2.y
rsq r2.z, r2.z
rsq r2.w, r2.w
mul r0, r0, r2
rcp r1.x, r1.x
rcp r1.y, r1.y
rcp r1.w, r1.w
rcp r1.z, r1.z
max r0, r0, c27.y
mul r0, r0, r1
mul r1.xyz, r0.y, c16
mad r1.xyz, r0.x, c15, r1
mad r0.xyz, r0.z, c17, r1
mad r1.xyz, r0.w, c18, r0
mul r0, r5.xyzz, r5.yzzx
mul r1.w, r4.x, r4.x
dp4 r3.w, r0, c24
dp4 r3.z, r0, c23
dp4 r3.x, r0, c22
mad r1.w, r5.x, r5.x, -r1
mul r0.xyz, r1.w, c25
dp4 r0.w, v0, c3
dp4 r2.z, r5, c21
dp4 r2.y, r5, c20
dp4 r2.x, r5, c19
add r2.xyz, r2, r3.xzww
add r2.xyz, r2, r0
add o5.xyz, r2, r1
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r3.xzw, r0.xyyw, c27.z
mul r1.y, r3.z, c9.x
mov r1.x, r3
mad o7.xy, r3.w, c10.zwzw, r1
mov r1.z, r3.y
mov r1.x, r5
mov r1.y, r4
mov o2.xyz, r1
mov o4.xyz, r1
mov o0, r0
mov o3, v2
mov o7.zw, r0
mov o1.xyz, r6
add o6.xyz, -r6, c8
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD6;
varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  highp vec3 tmpvar_24;
  tmpvar_24 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_25;
  tmpvar_25 = (unity_4LightPosX0 - tmpvar_24.x);
  highp vec4 tmpvar_26;
  tmpvar_26 = (unity_4LightPosY0 - tmpvar_24.y);
  highp vec4 tmpvar_27;
  tmpvar_27 = (unity_4LightPosZ0 - tmpvar_24.z);
  highp vec4 tmpvar_28;
  tmpvar_28 = (((tmpvar_25 * tmpvar_25) + (tmpvar_26 * tmpvar_26)) + (tmpvar_27 * tmpvar_27));
  highp vec4 tmpvar_29;
  tmpvar_29 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_25 * tmpvar_7.x) + (tmpvar_26 * tmpvar_7.y)) + (tmpvar_27 * tmpvar_7.z)) * inversesqrt(tmpvar_28))) * (1.0/((1.0 + (tmpvar_28 * unity_4LightAtten0)))));
  highp vec3 tmpvar_30;
  tmpvar_30 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_29.x) + (unity_LightColor[1].xyz * tmpvar_29.y)) + (unity_LightColor[2].xyz * tmpvar_29.z)) + (unity_LightColor[3].xyz * tmpvar_29.w)));
  tmpvar_4 = tmpvar_30;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  xlv_TEXCOORD6 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD6;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float tmpvar_105;
  mediump float lightShadowDataX_106;
  highp float dist_107;
  lowp float tmpvar_108;
  tmpvar_108 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD6).x;
  dist_107 = tmpvar_108;
  highp float tmpvar_109;
  tmpvar_109 = _LightShadowData.x;
  lightShadowDataX_106 = tmpvar_109;
  highp float tmpvar_110;
  tmpvar_110 = max (float((dist_107 > (xlv_TEXCOORD6.z / xlv_TEXCOORD6.w))), lightShadowDataX_106);
  tmpvar_105 = tmpvar_110;
  lowp vec4 c_111;
  lowp float tmpvar_112;
  tmpvar_112 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_113;
  tmpvar_113 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_112) * (tmpvar_105 * 2.0));
  c_111.xyz = tmpvar_113;
  c_111.w = 0.0;
  c_1.w = c_111.w;
  c_1.xyz = (c_111.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD6;
varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_6;
  tmpvar_6 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = tmpvar_8;
  mediump vec3 tmpvar_10;
  mediump vec4 normal_11;
  normal_11 = tmpvar_9;
  highp float vC_12;
  mediump vec3 x3_13;
  mediump vec3 x2_14;
  mediump vec3 x1_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAr, normal_11);
  x1_15.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAg, normal_11);
  x1_15.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHAb, normal_11);
  x1_15.z = tmpvar_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = (normal_11.xyzz * normal_11.yzzx);
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBr, tmpvar_19);
  x2_14.x = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBg, tmpvar_19);
  x2_14.y = tmpvar_21;
  highp float tmpvar_22;
  tmpvar_22 = dot (unity_SHBb, tmpvar_19);
  x2_14.z = tmpvar_22;
  mediump float tmpvar_23;
  tmpvar_23 = ((normal_11.x * normal_11.x) - (normal_11.y * normal_11.y));
  vC_12 = tmpvar_23;
  highp vec3 tmpvar_24;
  tmpvar_24 = (unity_SHC.xyz * vC_12);
  x3_13 = tmpvar_24;
  tmpvar_10 = ((x1_15 + x2_14) + x3_13);
  shlight_2 = tmpvar_10;
  tmpvar_4 = shlight_2;
  highp vec3 tmpvar_25;
  tmpvar_25 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_26;
  tmpvar_26 = (unity_4LightPosX0 - tmpvar_25.x);
  highp vec4 tmpvar_27;
  tmpvar_27 = (unity_4LightPosY0 - tmpvar_25.y);
  highp vec4 tmpvar_28;
  tmpvar_28 = (unity_4LightPosZ0 - tmpvar_25.z);
  highp vec4 tmpvar_29;
  tmpvar_29 = (((tmpvar_26 * tmpvar_26) + (tmpvar_27 * tmpvar_27)) + (tmpvar_28 * tmpvar_28));
  highp vec4 tmpvar_30;
  tmpvar_30 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_26 * tmpvar_8.x) + (tmpvar_27 * tmpvar_8.y)) + (tmpvar_28 * tmpvar_8.z)) * inversesqrt(tmpvar_29))) * (1.0/((1.0 + (tmpvar_29 * unity_4LightAtten0)))));
  highp vec3 tmpvar_31;
  tmpvar_31 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_30.x) + (unity_LightColor[1].xyz * tmpvar_30.y)) + (unity_LightColor[2].xyz * tmpvar_30.z)) + (unity_LightColor[3].xyz * tmpvar_30.w)));
  tmpvar_4 = tmpvar_31;
  highp vec4 o_32;
  highp vec4 tmpvar_33;
  tmpvar_33 = (tmpvar_6 * 0.5);
  highp vec2 tmpvar_34;
  tmpvar_34.x = tmpvar_33.x;
  tmpvar_34.y = (tmpvar_33.y * _ProjectionParams.x);
  o_32.xy = (tmpvar_34 + tmpvar_33.w);
  o_32.zw = tmpvar_6.zw;
  gl_Position = tmpvar_6;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  xlv_TEXCOORD6 = o_32;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD6;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp vec4 tmpvar_105;
  tmpvar_105 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD6);
  lowp vec4 c_106;
  lowp float tmpvar_107;
  tmpvar_107 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_108;
  tmpvar_108 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_107) * (tmpvar_105.x * 2.0));
  c_106.xyz = tmpvar_108;
  c_106.w = 0.0;
  c_1.w = c_106.w;
  c_1.xyz = (c_106.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX

#extension GL_EXT_shadow_samplers : enable
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
varying highp vec4 xlv_TEXCOORD6;
varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  xlv_TEXCOORD6 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD6;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2DShadow _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float shadow_105;
  lowp float tmpvar_106;
  tmpvar_106 = shadow2DEXT (_ShadowMapTexture, xlv_TEXCOORD6.xyz);
  highp float tmpvar_107;
  tmpvar_107 = (_LightShadowData.x + (tmpvar_106 * (1.0 - _LightShadowData.x)));
  shadow_105 = tmpvar_107;
  lowp vec4 c_108;
  lowp float tmpvar_109;
  tmpvar_109 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_110;
  tmpvar_110 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_109) * (shadow_105 * 2.0));
  c_108.xyz = tmpvar_110;
  c_108.w = 0.0;
  c_1.w = c_108.w;
  c_1.xyz = (c_108.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX

#extension GL_EXT_shadow_samplers : enable
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  mat3 tmpvar_1;
  tmpvar_1[0] = _Object2World[0].xyz;
  tmpvar_1[1] = _Object2World[1].xyz;
  tmpvar_1[2] = _Object2World[2].xyz;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_1 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2DShadow _ShadowMapTexture;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float shadow_105;
  lowp float tmpvar_106;
  tmpvar_106 = shadow2DEXT (_ShadowMapTexture, xlv_TEXCOORD4.xyz);
  highp float tmpvar_107;
  tmpvar_107 = (_LightShadowData.x + (tmpvar_106 * (1.0 - _LightShadowData.x)));
  shadow_105 = tmpvar_107;
  c_1.xyz = (tmpvar_2 * min ((2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz), vec3((shadow_105 * 2.0))));
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" "SHADOWS_NATIVE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX

#extension GL_EXT_shadow_samplers : enable
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
varying highp vec4 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_4 = tmpvar_1.xyz;
  tmpvar_5 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_6;
  tmpvar_6[0].x = tmpvar_4.x;
  tmpvar_6[0].y = tmpvar_5.x;
  tmpvar_6[0].z = tmpvar_2.x;
  tmpvar_6[1].x = tmpvar_4.y;
  tmpvar_6[1].y = tmpvar_5.y;
  tmpvar_6[1].z = tmpvar_2.y;
  tmpvar_6[2].x = tmpvar_4.z;
  tmpvar_6[2].y = tmpvar_5.z;
  tmpvar_6[2].z = tmpvar_2.z;
  highp vec4 tmpvar_7;
  tmpvar_7.w = 1.0;
  tmpvar_7.xyz = _WorldSpaceCameraPos;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = (tmpvar_6 * (((_World2Object * tmpvar_7).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD5 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2DShadow _ShadowMapTexture;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float shadow_105;
  lowp float tmpvar_106;
  tmpvar_106 = shadow2DEXT (_ShadowMapTexture, xlv_TEXCOORD5.xyz);
  highp float tmpvar_107;
  tmpvar_107 = (_LightShadowData.x + (tmpvar_106 * (1.0 - _LightShadowData.x)));
  shadow_105 = tmpvar_107;
  highp vec3 tmpvar_108;
  tmpvar_108 = normalize(xlv_TEXCOORD4);
  mediump vec4 tmpvar_109;
  mediump vec3 viewDir_110;
  viewDir_110 = tmpvar_108;
  highp float nh_111;
  mediump vec3 scalePerBasisVector_112;
  mediump vec3 lm_113;
  lowp vec3 tmpvar_114;
  tmpvar_114 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lm_113 = tmpvar_114;
  lowp vec3 tmpvar_115;
  tmpvar_115 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD3).xyz);
  scalePerBasisVector_112 = tmpvar_115;
  mediump float tmpvar_116;
  tmpvar_116 = max (0.0, normalize((normalize((((scalePerBasisVector_112.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_112.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_112.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_110)).z);
  nh_111 = tmpvar_116;
  highp vec4 tmpvar_117;
  tmpvar_117.xyz = lm_113;
  tmpvar_117.w = pow (nh_111, 0.0);
  tmpvar_109 = tmpvar_117;
  lowp vec3 tmpvar_118;
  tmpvar_118 = vec3((shadow_105 * 2.0));
  mediump vec3 tmpvar_119;
  tmpvar_119 = (tmpvar_2 * min (tmpvar_109.xyz, tmpvar_118));
  c_1.xyz = tmpvar_119;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX

#extension GL_EXT_shadow_samplers : enable
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
varying highp vec4 xlv_TEXCOORD6;
varying highp vec3 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 shlight_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_7;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_7;
  mediump vec3 tmpvar_9;
  mediump vec4 normal_10;
  normal_10 = tmpvar_8;
  highp float vC_11;
  mediump vec3 x3_12;
  mediump vec3 x2_13;
  mediump vec3 x1_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHAr, normal_10);
  x1_14.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAg, normal_10);
  x1_14.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAb, normal_10);
  x1_14.z = tmpvar_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = (normal_10.xyzz * normal_10.yzzx);
  highp float tmpvar_19;
  tmpvar_19 = dot (unity_SHBr, tmpvar_18);
  x2_13.x = tmpvar_19;
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBg, tmpvar_18);
  x2_13.y = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBb, tmpvar_18);
  x2_13.z = tmpvar_21;
  mediump float tmpvar_22;
  tmpvar_22 = ((normal_10.x * normal_10.x) - (normal_10.y * normal_10.y));
  vC_11 = tmpvar_22;
  highp vec3 tmpvar_23;
  tmpvar_23 = (unity_SHC.xyz * vC_11);
  x3_12 = tmpvar_23;
  tmpvar_9 = ((x1_14 + x2_13) + x3_12);
  shlight_2 = tmpvar_9;
  tmpvar_4 = shlight_2;
  highp vec3 tmpvar_24;
  tmpvar_24 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_25;
  tmpvar_25 = (unity_4LightPosX0 - tmpvar_24.x);
  highp vec4 tmpvar_26;
  tmpvar_26 = (unity_4LightPosY0 - tmpvar_24.y);
  highp vec4 tmpvar_27;
  tmpvar_27 = (unity_4LightPosZ0 - tmpvar_24.z);
  highp vec4 tmpvar_28;
  tmpvar_28 = (((tmpvar_25 * tmpvar_25) + (tmpvar_26 * tmpvar_26)) + (tmpvar_27 * tmpvar_27));
  highp vec4 tmpvar_29;
  tmpvar_29 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_25 * tmpvar_7.x) + (tmpvar_26 * tmpvar_7.y)) + (tmpvar_27 * tmpvar_7.z)) * inversesqrt(tmpvar_28))) * (1.0/((1.0 + (tmpvar_28 * unity_4LightAtten0)))));
  highp vec3 tmpvar_30;
  tmpvar_30 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_29.x) + (unity_LightColor[1].xyz * tmpvar_29.y)) + (unity_LightColor[2].xyz * tmpvar_29.z)) + (unity_LightColor[3].xyz * tmpvar_29.w)));
  tmpvar_4 = tmpvar_30;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  xlv_TEXCOORD6 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD6;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2DShadow _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
uniform lowp vec4 _WorldSpaceLightPos0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * xlv_TEXCOORD0.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * xlv_TEXCOORD0.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_54 * tmpvar_56);
  blendWeights_13 = tmpvar_57;
  mediump float tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_56.x);
  blendBottom_12 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_66;
  highp float tmpvar_67;
  tmpvar_67 = xlv_TEXCOORD2.x;
  vertBlend_3 = tmpvar_67;
  mediump float tmpvar_68;
  tmpvar_68 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c1_11, cb1_7, vec4(tmpvar_68));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c2_10, cb2_6, vec4(tmpvar_68));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c3_9, cb3_5, vec4(tmpvar_68));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c4_8, cb4_4, vec4(tmpvar_68));
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = xlv_TEXCOORD2.y;
  vertBlend_3 = tmpvar_77;
  mediump float tmpvar_78;
  tmpvar_78 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb1_7, vec4(tmpvar_78));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb2_6, vec4(tmpvar_78));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb3_5, vec4(tmpvar_78));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb4_4, vec4(tmpvar_78));
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = xlv_TEXCOORD2.z;
  vertBlend_3 = tmpvar_87;
  mediump float tmpvar_88;
  tmpvar_88 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb1_7, vec4(tmpvar_88));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb2_6, vec4(tmpvar_88));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb3_5, vec4(tmpvar_88));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb4_4, vec4(tmpvar_88));
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_96;
  highp float tmpvar_97;
  tmpvar_97 = xlv_TEXCOORD2.w;
  vertBlend_3 = tmpvar_97;
  mediump float tmpvar_98;
  tmpvar_98 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_99;
  tmpvar_99 = mix (tmpvar_89, cb1_7, vec4(tmpvar_98));
  c1_11 = tmpvar_99;
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb2_6, vec4(tmpvar_98));
  c2_10 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb3_5, vec4(tmpvar_98));
  c3_9 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb4_4, vec4(tmpvar_98));
  c4_8 = tmpvar_102;
  mediump vec3 tmpvar_103;
  tmpvar_103 = ((((tmpvar_99 * tmpvar_57.x) + (tmpvar_100 * tmpvar_57.y)) + (tmpvar_102 * tmpvar_58)) + (tmpvar_101 * tmpvar_57.z)).xyz;
  highp vec3 tmpvar_104;
  tmpvar_104 = (tmpvar_103 * _Color.xyz);
  tmpvar_2 = tmpvar_104;
  lowp float shadow_105;
  lowp float tmpvar_106;
  tmpvar_106 = shadow2DEXT (_ShadowMapTexture, xlv_TEXCOORD6.xyz);
  highp float tmpvar_107;
  tmpvar_107 = (_LightShadowData.x + (tmpvar_106 * (1.0 - _LightShadowData.x)));
  shadow_105 = tmpvar_107;
  lowp vec4 c_108;
  lowp float tmpvar_109;
  tmpvar_109 = max (0.0, dot (xlv_TEXCOORD3, _WorldSpaceLightPos0.xyz));
  highp vec3 tmpvar_110;
  tmpvar_110 = (((tmpvar_2 * _LightColor0.xyz) * tmpvar_109) * (shadow_105 * 2.0));
  c_108.xyz = tmpvar_110;
  c_108.w = 0.0;
  c_1.w = c_108.w;
  c_1.xyz = (c_108.xyz + (tmpvar_2 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 6
//   opengl - ALU: 109 to 115, TEX: 16 to 18
//   d3d9 - ALU: 116 to 121, TEX: 16 to 18
SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_TilingTop]
Float 3 [_TilingSides]
Float 4 [_TilingRed]
Float 5 [_TilingGreen]
Float 6 [_TilingBlue]
Float 7 [_TilingAlpha]
Vector 8 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 111 ALU, 16 TEX
PARAM c[11] = { program.local[0..8],
		{ 1.5, 0.1, 0, 0.25 },
		{ 5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[4];
MOV R0.y, c[3].x;
MUL R7.y, R0, c[9];
MUL R7.x, R0, c[9].y;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[5].x;
MUL R5.w, R0, c[9].y;
MUL R0.w, fragment.texcoord[2].x, c[9].x;
POW_SAT R6.w, R0.w, c[9].x;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[6].x;
MUL R3.w, R0, c[9].y;
MUL R0.w, fragment.texcoord[2].y, c[9].x;
POW_SAT R4.w, R0.w, c[9].x;
MOV R0.w, c[7].x;
MUL R1.w, R0, c[9].y;
MUL R0.w, fragment.texcoord[2].z, c[9].x;
POW_SAT R2.w, R0.w, c[9].x;
MUL R0.w, fragment.texcoord[2], c[9].x;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[2];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[9].x;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[9].y;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[9].z;
MUL R6.x, R6, c[9].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[10].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[9].z;
MUL R2.xyz, R2, c[9].w;
POW_SAT R2.x, R2.x, c[10].x;
POW_SAT R2.y, R2.y, c[10].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[10].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MAD R1.xyz, R0.w, R1, R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
MAD R0.xyz, R1, R2.z, R0;
MUL R0.xyz, R0, c[8];
DP3 R0.w, fragment.texcoord[3], c[0];
MAX R0.w, R0, c[9].z;
MUL R1.xyz, R0, c[1];
MUL R1.xyz, R1, R0.w;
MUL R1.xyz, R1, c[10].y;
MAD result.color.xyz, R0, fragment.texcoord[4], R1;
MOV result.color.w, c[9].z;
END
# 111 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_TilingTop]
Float 3 [_TilingSides]
Float 4 [_TilingRed]
Float 5 [_TilingGreen]
Float 6 [_TilingBlue]
Float 7 [_TilingAlpha]
Vector 8 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
"ps_3_0
; 119 ALU, 16 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c9, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c10, 5.00000000, 2.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
mul_pp r0.x, v2, c9
pow_pp_sat r2, r0.x, c9.x
mov r0.y, c9
mul r8.z, c3.x, r0.y
mov r0.x, c9.y
mul r8.y, c4.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c9.y
mul r7.w, c5.x, r0.x
mul_pp r1.w, v2.y, c9.x
pow_pp_sat r0, r1.w, c9.x
mov_pp r6.w, r0.x
mov r0.x, c9.y
mul r5.w, c6.x, r0.x
mul_pp r1.w, v2.z, c9.x
pow_pp_sat r0, r1.w, c9.x
mov_pp r4.w, r0.x
mov r0.x, c9.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c7.x, r0.x
mul_pp r1.w, v2, c9.x
pow_pp_sat r0, r1.w, c9.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c9
mul r0.x, c2, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c9.z
mul_pp r7.xyz, r4, c9.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c10.x
pow_pp_sat r2, r7.x, c10.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c9.z
mul_pp r2.x, r0.y, c9.w
pow_pp_sat r0, r2.x, c10.x
pow_pp_sat r2, r7.z, c10.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mad_pp r3.xyz, r0, r0.w, r3
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
dp3_pp r0.w, v3, c0
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r0.xyz, r0, r2.z, r3
mul r0.xyz, r0, c8
max_pp r0.w, r0, c9.z
mul_pp r1.xyz, r0, c1
mul_pp r1.xyz, r1, r0.w
mul r1.xyz, r1, c10.y
mad_pp oC0.xyz, r0, v4, r1
mov_pp oC0.w, c9.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 109 ALU, 17 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
MAD R1.xyz, R0.w, R1, R4;
MAD R1.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[3], texture[6], 2D;
MUL R1.xyz, R1, c[6];
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, R1;
MUL result.color.xyz, R0, c[8].y;
MOV result.color.w, c[7].x;
END
# 109 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [unity_Lightmap] 2D
"ps_3_0
; 116 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
mad_pp r3.xyz, r0, r0.w, r3
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r1.xyz, r0, r2.z, r3
texld r0, v3, s6
mul r1.xyz, r1, c6
mul_pp r0.xyz, r0.w, r0
mul_pp r0.xyz, r0, r1
mul_pp oC0.xyz, r0, c8.y
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 109 ALU, 17 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
MAD R1.xyz, R0.w, R1, R4;
MAD R1.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[3], texture[6], 2D;
MUL R1.xyz, R1, c[6];
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, R1;
MUL result.color.xyz, R0, c[8].y;
MOV result.color.w, c[7].x;
END
# 109 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [unity_Lightmap] 2D
"ps_3_0
; 116 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
mad_pp r3.xyz, r0, r0.w, r3
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r1.xyz, r0, r2.z, r3
texld r0, v3, s6
mul r1.xyz, r1, c6
mul_pp r0.xyz, r0.w, r0
mul_pp r0.xyz, r0, r1
mul_pp oC0.xyz, r0, c8.y
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_TilingTop]
Float 3 [_TilingSides]
Float 4 [_TilingRed]
Float 5 [_TilingGreen]
Float 6 [_TilingBlue]
Float 7 [_TilingAlpha]
Vector 8 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_ShadowMapTexture] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 113 ALU, 17 TEX
PARAM c[11] = { program.local[0..8],
		{ 1.5, 0.1, 0, 0.25 },
		{ 5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[4];
MOV R0.y, c[3].x;
MUL R7.y, R0, c[9];
MUL R7.x, R0, c[9].y;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[5].x;
MUL R5.w, R0, c[9].y;
MUL R0.w, fragment.texcoord[2].x, c[9].x;
POW_SAT R6.w, R0.w, c[9].x;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[6].x;
MUL R3.w, R0, c[9].y;
MUL R0.w, fragment.texcoord[2].y, c[9].x;
POW_SAT R4.w, R0.w, c[9].x;
MOV R0.w, c[7].x;
MUL R1.w, R0, c[9].y;
MUL R0.w, fragment.texcoord[2].z, c[9].x;
POW_SAT R2.w, R0.w, c[9].x;
MUL R0.w, fragment.texcoord[2], c[9].x;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[2];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[9].x;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[9].y;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[9].z;
MUL R6.x, R6, c[9].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[10].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[9].z;
MUL R2.xyz, R2, c[9].w;
POW_SAT R2.x, R2.x, c[10].x;
POW_SAT R2.y, R2.y, c[10].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[10].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R0.xyz, R1, R2.z, R0;
MUL R1.xyz, R0, c[8];
TXP R0.x, fragment.texcoord[6], texture[6], 2D;
DP3 R0.y, fragment.texcoord[3], c[0];
MUL R0.w, R0.x, c[10].y;
MUL R2.xyz, R1, c[1];
MAX R0.y, R0, c[9].z;
MUL R0.xyz, R2, R0.y;
MUL R0.xyz, R0, R0.w;
MAD result.color.xyz, R1, fragment.texcoord[4], R0;
MOV result.color.w, c[9].z;
END
# 113 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_TilingTop]
Float 3 [_TilingSides]
Float 4 [_TilingRed]
Float 5 [_TilingGreen]
Float 6 [_TilingBlue]
Float 7 [_TilingAlpha]
Vector 8 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_ShadowMapTexture] 2D
"ps_3_0
; 120 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c9, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c10, 5.00000000, 2.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
dcl_texcoord6 v6
mul_pp r0.x, v2, c9
pow_pp_sat r2, r0.x, c9.x
mov r0.y, c9
mul r8.z, c3.x, r0.y
mov r0.x, c9.y
mul r8.y, c4.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c9.y
mul r7.w, c5.x, r0.x
mul_pp r1.w, v2.y, c9.x
pow_pp_sat r0, r1.w, c9.x
mov_pp r6.w, r0.x
mov r0.x, c9.y
mul r5.w, c6.x, r0.x
mul_pp r1.w, v2.z, c9.x
pow_pp_sat r0, r1.w, c9.x
mov_pp r4.w, r0.x
mov r0.x, c9.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c7.x, r0.x
mul_pp r1.w, v2, c9.x
pow_pp_sat r0, r1.w, c9.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c9
mul r0.x, c2, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c9.z
mul_pp r7.xyz, r4, c9.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c10.x
pow_pp_sat r2, r7.x, c10.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c9.z
mul_pp r2.x, r0.y, c9.w
pow_pp_sat r0, r2.x, c10.x
pow_pp_sat r2, r7.z, c10.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
mad_pp r3.xyz, r0, r0.w, r3
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r0.xyz, r0, r2.z, r3
mul r1.xyz, r0, c8
texldp r0.x, v6, s6
dp3_pp r0.y, v3, c0
mul_pp r0.w, r0.x, c10.y
mul_pp r2.xyz, r1, c1
max_pp r0.y, r0, c9.z
mul_pp r0.xyz, r2, r0.y
mul r0.xyz, r0, r0.w
mad_pp oC0.xyz, r1, v4, r0
mov_pp oC0.w, c9.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_ShadowMapTexture] 2D
SetTexture 7 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 115 ALU, 18 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R2.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[3], texture[7], 2D;
TXP R1.x, fragment.texcoord[4], texture[6], 2D;
MUL R3.xyz, R0.w, R0;
MUL R4.xyz, R0, R1.x;
MUL R0.xyz, R3, c[8].y;
MUL R1.xyz, R0, R1.x;
MUL R3.xyz, R4, c[8].z;
MIN R0.xyz, R0, R3;
MAX R1.xyz, R0, R1;
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[7].x;
END
# 115 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_ShadowMapTexture] 2D
SetTexture 7 [unity_Lightmap] 2D
"ps_3_0
; 121 ALU, 18 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 8.00000000, 2.00000000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
dcl_texcoord4 v4
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r3.xyz, r0, r0.w, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r2.xyz, r0, r2.z, r3
texld r0, v3, s7
texldp r1.x, v4, s6
mul_pp r3.xyz, r0.w, r0
mul_pp r4.xyz, r0, r1.x
mul_pp r0.xyz, r3, c8.y
mul_pp r1.xyz, r0, r1.x
mul_pp r3.xyz, r4, c8.z
min_pp r0.xyz, r0, r3
max_pp r1.xyz, r0, r1
mul r0.xyz, r2, c6
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_ShadowMapTexture] 2D
SetTexture 7 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 115 ALU, 18 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R2.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[3], texture[7], 2D;
TXP R1.x, fragment.texcoord[5], texture[6], 2D;
MUL R3.xyz, R0.w, R0;
MUL R4.xyz, R0, R1.x;
MUL R0.xyz, R3, c[8].y;
MUL R1.xyz, R0, R1.x;
MUL R3.xyz, R4, c[8].z;
MIN R0.xyz, R0, R3;
MAX R1.xyz, R0, R1;
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[7].x;
END
# 115 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_ShadowMapTexture] 2D
SetTexture 7 [unity_Lightmap] 2D
"ps_3_0
; 121 ALU, 18 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 8.00000000, 2.00000000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
dcl_texcoord5 v5
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r3.xyz, r0, r0.w, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r2.xyz, r0, r2.z, r3
texld r0, v3, s7
texldp r1.x, v5, s6
mul_pp r3.xyz, r0.w, r0
mul_pp r4.xyz, r0, r1.x
mul_pp r0.xyz, r3, c8.y
mul_pp r1.xyz, r0, r1.x
mul_pp r3.xyz, r4, c8.z
min_pp r0.xyz, r0, r3
max_pp r1.xyz, r0, r1
mul r0.xyz, r2, c6
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES"
}

}
	}
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One Fog { Color (0,0,0,0) }
Program "vp" {
// Vertex combos: 5
//   opengl - ALU: 17 to 23
//   d3d9 - ALU: 17 to 23
SubProgram "opengl " {
Keywords { "POINT" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Vector 15 [unity_Scale]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 22 ALU
PARAM c[16] = { program.local[0],
		state.matrix.mvp,
		program.local[5..15] };
TEMP R0;
TEMP R1;
MUL R1.xyz, vertex.normal, c[15].w;
DP3 R0.z, R1, c[7];
DP3 R0.x, R1, c[5];
DP3 R0.y, R1, c[6];
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
DP4 R0.w, vertex.position, c[8];
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
MOV R0.xyz, R1;
MOV result.texcoord[2], vertex.color;
DP4 result.texcoord[6].z, R0, c[11];
DP4 result.texcoord[6].y, R0, c[10];
DP4 result.texcoord[6].x, R0, c[9];
MOV result.texcoord[0].xyz, R1;
ADD result.texcoord[4].xyz, -R1, c[14];
ADD result.texcoord[5].xyz, -R1, c[13];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 22 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 14 [unity_Scale]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 22 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_texcoord6 o7
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c14.w
dp3 r0.z, r1, c6
dp3 r0.x, r1, c4
dp3 r0.y, r1, c5
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp4 r0.w, v0, c7
mov o2.xyz, r0
mov o4.xyz, r0
mov r0.xyz, r1
mov o3, v2
dp4 o7.z, r0, c10
dp4 o7.y, r0, c9
dp4 o7.x, r0, c8
mov o1.xyz, r1
add o5.xyz, -r1, c13
add o6.xyz, -r1, c12
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "POINT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  mediump vec3 tmpvar_106;
  tmpvar_106 = normalize(xlv_TEXCOORD4);
  lightDir_2 = tmpvar_106;
  highp float tmpvar_107;
  tmpvar_107 = dot (xlv_TEXCOORD6, xlv_TEXCOORD6);
  lowp float atten_108;
  atten_108 = texture2D (_LightTexture0, vec2(tmpvar_107)).w;
  lowp vec4 c_109;
  lowp float tmpvar_110;
  tmpvar_110 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_111;
  tmpvar_111 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_110) * (atten_108 * 2.0));
  c_109.xyz = tmpvar_111;
  c_109.w = 0.0;
  c_1.xyz = c_109.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "POINT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  mediump vec3 tmpvar_106;
  tmpvar_106 = normalize(xlv_TEXCOORD4);
  lightDir_2 = tmpvar_106;
  highp float tmpvar_107;
  tmpvar_107 = dot (xlv_TEXCOORD6, xlv_TEXCOORD6);
  lowp float atten_108;
  atten_108 = texture2D (_LightTexture0, vec2(tmpvar_107)).w;
  lowp vec4 c_109;
  lowp float tmpvar_110;
  tmpvar_110 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_111;
  tmpvar_111 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_110) * (atten_108 * 2.0));
  c_109.xyz = tmpvar_111;
  c_109.w = 0.0;
  c_1.xyz = c_109.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_WorldSpaceCameraPos]
Vector 10 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Vector 11 [unity_Scale]
"3.0-!!ARBvp1.0
# 17 ALU
PARAM c[12] = { program.local[0],
		state.matrix.mvp,
		program.local[5..11] };
TEMP R0;
TEMP R1;
MUL R1.xyz, vertex.normal, c[11].w;
DP3 R0.z, R1, c[7];
DP3 R0.x, R1, c[5];
DP3 R0.y, R1, c[6];
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[0].xyz, R0;
MOV result.texcoord[4].xyz, c[10];
ADD result.texcoord[5].xyz, -R0, c[9];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 17 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 10 [unity_Scale]
"vs_3_0
; 17 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c10.w
dp3 r0.z, r1, c6
dp3 r0.x, r1, c4
dp3 r0.y, r1, c5
mov o2.xyz, r0
mov o4.xyz, r0
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mov o3, v2
mov o1.xyz, r0
mov o5.xyz, c9
add o6.xyz, -r0, c8
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = _WorldSpaceLightPos0.xyz;
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  lightDir_2 = xlv_TEXCOORD4;
  lowp vec4 c_106;
  lowp float tmpvar_107;
  tmpvar_107 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_108;
  tmpvar_108 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_107) * 2.0);
  c_106.xyz = tmpvar_108;
  c_106.w = 0.0;
  c_1.xyz = c_106.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = _WorldSpaceLightPos0.xyz;
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  lightDir_2 = xlv_TEXCOORD4;
  lowp vec4 c_106;
  lowp float tmpvar_107;
  tmpvar_107 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_108;
  tmpvar_108 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_107) * 2.0);
  c_106.xyz = tmpvar_108;
  c_106.w = 0.0;
  c_1.xyz = c_106.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "SPOT" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Vector 15 [unity_Scale]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 23 ALU
PARAM c[16] = { program.local[0],
		state.matrix.mvp,
		program.local[5..15] };
TEMP R0;
TEMP R1;
MUL R1.xyz, vertex.normal, c[15].w;
DP3 R0.z, R1, c[7];
DP3 R0.x, R1, c[5];
DP3 R0.y, R1, c[6];
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
DP4 R0.w, vertex.position, c[8];
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
MOV R0.xyz, R1;
MOV result.texcoord[2], vertex.color;
DP4 result.texcoord[6].w, R0, c[12];
DP4 result.texcoord[6].z, R0, c[11];
DP4 result.texcoord[6].y, R0, c[10];
DP4 result.texcoord[6].x, R0, c[9];
MOV result.texcoord[0].xyz, R1;
ADD result.texcoord[4].xyz, -R1, c[14];
ADD result.texcoord[5].xyz, -R1, c[13];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 23 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "SPOT" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 14 [unity_Scale]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 23 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_texcoord6 o7
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c14.w
dp3 r0.z, r1, c6
dp3 r0.x, r1, c4
dp3 r0.y, r1, c5
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp4 r0.w, v0, c7
mov o2.xyz, r0
mov o4.xyz, r0
mov r0.xyz, r1
mov o3, v2
dp4 o7.w, r0, c11
dp4 o7.z, r0, c10
dp4 o7.y, r0, c9
dp4 o7.x, r0, c8
mov o1.xyz, r1
add o5.xyz, -r1, c13
add o6.xyz, -r1, c12
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "SPOT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTextureB0;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  mediump vec3 tmpvar_106;
  tmpvar_106 = normalize(xlv_TEXCOORD4);
  lightDir_2 = tmpvar_106;
  highp vec2 P_107;
  P_107 = ((xlv_TEXCOORD6.xy / xlv_TEXCOORD6.w) + 0.5);
  highp float tmpvar_108;
  tmpvar_108 = dot (xlv_TEXCOORD6.xyz, xlv_TEXCOORD6.xyz);
  lowp float atten_109;
  atten_109 = ((float((xlv_TEXCOORD6.z > 0.0)) * texture2D (_LightTexture0, P_107).w) * texture2D (_LightTextureB0, vec2(tmpvar_108)).w);
  lowp vec4 c_110;
  lowp float tmpvar_111;
  tmpvar_111 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_112;
  tmpvar_112 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_111) * (atten_109 * 2.0));
  c_110.xyz = tmpvar_112;
  c_110.w = 0.0;
  c_1.xyz = c_110.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "SPOT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTextureB0;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  mediump vec3 tmpvar_106;
  tmpvar_106 = normalize(xlv_TEXCOORD4);
  lightDir_2 = tmpvar_106;
  highp vec2 P_107;
  P_107 = ((xlv_TEXCOORD6.xy / xlv_TEXCOORD6.w) + 0.5);
  highp float tmpvar_108;
  tmpvar_108 = dot (xlv_TEXCOORD6.xyz, xlv_TEXCOORD6.xyz);
  lowp float atten_109;
  atten_109 = ((float((xlv_TEXCOORD6.z > 0.0)) * texture2D (_LightTexture0, P_107).w) * texture2D (_LightTextureB0, vec2(tmpvar_108)).w);
  lowp vec4 c_110;
  lowp float tmpvar_111;
  tmpvar_111 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_112;
  tmpvar_112 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_111) * (atten_109 * 2.0));
  c_110.xyz = tmpvar_112;
  c_110.w = 0.0;
  c_1.xyz = c_110.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "POINT_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Vector 15 [unity_Scale]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 22 ALU
PARAM c[16] = { program.local[0],
		state.matrix.mvp,
		program.local[5..15] };
TEMP R0;
TEMP R1;
MUL R1.xyz, vertex.normal, c[15].w;
DP3 R0.z, R1, c[7];
DP3 R0.x, R1, c[5];
DP3 R0.y, R1, c[6];
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
DP4 R0.w, vertex.position, c[8];
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
MOV R0.xyz, R1;
MOV result.texcoord[2], vertex.color;
DP4 result.texcoord[6].z, R0, c[11];
DP4 result.texcoord[6].y, R0, c[10];
DP4 result.texcoord[6].x, R0, c[9];
MOV result.texcoord[0].xyz, R1;
ADD result.texcoord[4].xyz, -R1, c[14];
ADD result.texcoord[5].xyz, -R1, c[13];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 22 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 14 [unity_Scale]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 22 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_texcoord6 o7
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c14.w
dp3 r0.z, r1, c6
dp3 r0.x, r1, c4
dp3 r0.y, r1, c5
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp4 r0.w, v0, c7
mov o2.xyz, r0
mov o4.xyz, r0
mov r0.xyz, r1
mov o3, v2
dp4 o7.z, r0, c10
dp4 o7.y, r0, c9
dp4 o7.x, r0, c8
mov o1.xyz, r1
add o5.xyz, -r1, c13
add o6.xyz, -r1, c12
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "POINT_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTextureB0;
uniform samplerCube _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  mediump vec3 tmpvar_106;
  tmpvar_106 = normalize(xlv_TEXCOORD4);
  lightDir_2 = tmpvar_106;
  highp float tmpvar_107;
  tmpvar_107 = dot (xlv_TEXCOORD6, xlv_TEXCOORD6);
  lowp float atten_108;
  atten_108 = (texture2D (_LightTextureB0, vec2(tmpvar_107)).w * textureCube (_LightTexture0, xlv_TEXCOORD6).w);
  lowp vec4 c_109;
  lowp float tmpvar_110;
  tmpvar_110 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_111;
  tmpvar_111 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_110) * (atten_108 * 2.0));
  c_109.xyz = tmpvar_111;
  c_109.w = 0.0;
  c_1.xyz = c_109.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "POINT_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTextureB0;
uniform samplerCube _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  mediump vec3 tmpvar_106;
  tmpvar_106 = normalize(xlv_TEXCOORD4);
  lightDir_2 = tmpvar_106;
  highp float tmpvar_107;
  tmpvar_107 = dot (xlv_TEXCOORD6, xlv_TEXCOORD6);
  lowp float atten_108;
  atten_108 = (texture2D (_LightTextureB0, vec2(tmpvar_107)).w * textureCube (_LightTexture0, xlv_TEXCOORD6).w);
  lowp vec4 c_109;
  lowp float tmpvar_110;
  tmpvar_110 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_111;
  tmpvar_111 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_110) * (atten_108 * 2.0));
  c_109.xyz = tmpvar_111;
  c_109.w = 0.0;
  c_1.xyz = c_109.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Vector 15 [unity_Scale]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 21 ALU
PARAM c[16] = { program.local[0],
		state.matrix.mvp,
		program.local[5..15] };
TEMP R0;
TEMP R1;
MUL R1.xyz, vertex.normal, c[15].w;
DP3 R0.z, R1, c[7];
DP3 R0.x, R1, c[5];
DP3 R0.y, R1, c[6];
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
DP4 R0.w, vertex.position, c[8];
MOV result.texcoord[1].xyz, R0;
MOV result.texcoord[3].xyz, R0;
MOV R0.xyz, R1;
MOV result.texcoord[2], vertex.color;
DP4 result.texcoord[6].y, R0, c[10];
DP4 result.texcoord[6].x, R0, c[9];
MOV result.texcoord[0].xyz, R1;
MOV result.texcoord[4].xyz, c[14];
ADD result.texcoord[5].xyz, -R1, c[13];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 21 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 14 [unity_Scale]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 21 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
dcl_texcoord6 o7
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c14.w
dp3 r0.z, r1, c6
dp3 r0.x, r1, c4
dp3 r0.y, r1, c5
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp4 r0.w, v0, c7
mov o2.xyz, r0
mov o4.xyz, r0
mov r0.xyz, r1
mov o3, v2
dp4 o7.y, r0, c9
dp4 o7.x, r0, c8
mov o1.xyz, r1
mov o5.xyz, c13
add o6.xyz, -r1, c12
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = _WorldSpaceLightPos0.xyz;
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex)).xy;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  lightDir_2 = xlv_TEXCOORD4;
  lowp float atten_106;
  atten_106 = texture2D (_LightTexture0, xlv_TEXCOORD6).w;
  lowp vec4 c_107;
  lowp float tmpvar_108;
  tmpvar_108 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_109;
  tmpvar_109 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_108) * (atten_106 * 2.0));
  c_107.xyz = tmpvar_109;
  c_107.w = 0.0;
  c_1.xyz = c_107.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp mat4 _LightMatrix0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_7;
  highp vec3 tmpvar_8;
  tmpvar_8 = _WorldSpaceLightPos0.xyz;
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_5 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = tmpvar_2;
  xlv_TEXCOORD4 = tmpvar_3;
  xlv_TEXCOORD5 = tmpvar_4;
  xlv_TEXCOORD6 = (_LightMatrix0 * (_Object2World * _glesVertex)).xy;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 lightDir_2;
  lowp vec3 tmpvar_3;
  mediump float vertBlend_4;
  mediump vec4 cb4_5;
  mediump vec4 cb3_6;
  mediump vec4 cb2_7;
  mediump vec4 cb1_8;
  mediump vec4 c4_9;
  mediump vec4 c3_10;
  mediump vec4 c2_11;
  mediump vec4 c1_12;
  mediump float blendBottom_13;
  mediump vec3 blendWeights_14;
  mediump vec2 uv3Alpha_15;
  mediump vec2 uv2Alpha_16;
  mediump vec2 uv1Alpha_17;
  mediump vec2 uv3Blue_18;
  mediump vec2 uv2Blue_19;
  mediump vec2 uv1Blue_20;
  mediump vec2 uv3Green_21;
  mediump vec2 uv2Green_22;
  mediump vec2 uv1Green_23;
  mediump vec2 uv3Red_24;
  mediump vec2 uv2Red_25;
  mediump vec2 uv1Red_26;
  mediump vec2 uv3Sides_27;
  mediump vec2 uv2Sides_28;
  mediump vec2 uv1Sides_29;
  mediump vec2 uv2Top_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (_TilingTop / 10.0);
  tmpvar_31.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_32;
  tmpvar_32 = (tmpvar_31 * xlv_TEXCOORD0.xz);
  uv2Top_30 = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (_TilingSides / 10.0);
  tmpvar_33.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_33 * xlv_TEXCOORD0.zy);
  uv1Sides_29 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_33 * xlv_TEXCOORD0.xz);
  uv2Sides_28 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_33 * xlv_TEXCOORD0.xy);
  uv3Sides_27 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (_TilingRed / 10.0);
  tmpvar_37.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_37 * xlv_TEXCOORD0.zy);
  uv1Red_26 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_37 * xlv_TEXCOORD0.xz);
  uv2Red_25 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_37 * xlv_TEXCOORD0.xy);
  uv3Red_24 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (_TilingGreen / 10.0);
  tmpvar_41.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_41 * xlv_TEXCOORD0.zy);
  uv1Green_23 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_41 * xlv_TEXCOORD0.xz);
  uv2Green_22 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_41 * xlv_TEXCOORD0.xy);
  uv3Green_21 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45.x = (_TilingBlue / 10.0);
  tmpvar_45.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_45 * xlv_TEXCOORD0.zy);
  uv1Blue_20 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_45 * xlv_TEXCOORD0.xz);
  uv2Blue_19 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_45 * xlv_TEXCOORD0.xy);
  uv3Blue_18 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49.x = (_TilingAlpha / 10.0);
  tmpvar_49.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_49 * xlv_TEXCOORD0.zy);
  uv1Alpha_17 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_49 * xlv_TEXCOORD0.xz);
  uv2Alpha_16 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_49 * xlv_TEXCOORD0.xy);
  uv3Alpha_15 = tmpvar_52;
  blendWeights_14.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_53;
  tmpvar_53 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_14.y = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_13 = tmpvar_54;
  mediump vec3 tmpvar_55;
  tmpvar_55 = clamp (pow ((blendWeights_14 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_56;
  tmpvar_56 = clamp (pow ((blendBottom_13 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_57;
  tmpvar_57 = vec3((1.0/((((tmpvar_55.x + tmpvar_55.y) + tmpvar_55.z) + tmpvar_56))));
  mediump vec3 tmpvar_58;
  tmpvar_58 = (tmpvar_55 * tmpvar_57);
  blendWeights_14 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_57.x);
  blendBottom_13 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv1Sides_29);
  c1_12 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex, uv2Top_30);
  c2_11 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex2, uv3Sides_27);
  c3_10 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv2Sides_28);
  c4_9 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv1Red_26);
  cb1_8 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv2Red_25);
  cb2_7 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv3Red_24);
  cb3_6 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv2Red_25);
  cb4_5 = tmpvar_67;
  highp float tmpvar_68;
  tmpvar_68 = xlv_TEXCOORD2.x;
  vertBlend_4 = tmpvar_68;
  mediump float tmpvar_69;
  tmpvar_69 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c1_12, cb1_8, vec4(tmpvar_69));
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c2_11, cb2_7, vec4(tmpvar_69));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c3_10, cb3_6, vec4(tmpvar_69));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c4_9, cb4_5, vec4(tmpvar_69));
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv1Green_23);
  cb1_8 = tmpvar_74;
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv2Green_22);
  cb2_7 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv3Green_21);
  cb3_6 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv2Green_22);
  cb4_5 = tmpvar_77;
  highp float tmpvar_78;
  tmpvar_78 = xlv_TEXCOORD2.y;
  vertBlend_4 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb1_8, vec4(tmpvar_79));
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb2_7, vec4(tmpvar_79));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb3_6, vec4(tmpvar_79));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb4_5, vec4(tmpvar_79));
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv1Blue_20);
  cb1_8 = tmpvar_84;
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv2Blue_19);
  cb2_7 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv3Blue_18);
  cb3_6 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv2Blue_19);
  cb4_5 = tmpvar_87;
  highp float tmpvar_88;
  tmpvar_88 = xlv_TEXCOORD2.z;
  vertBlend_4 = tmpvar_88;
  mediump float tmpvar_89;
  tmpvar_89 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb1_8, vec4(tmpvar_89));
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb2_7, vec4(tmpvar_89));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb3_6, vec4(tmpvar_89));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb4_5, vec4(tmpvar_89));
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv1Alpha_17);
  cb1_8 = tmpvar_94;
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv2Alpha_16);
  cb2_7 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv3Alpha_15);
  cb3_6 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv2Alpha_16);
  cb4_5 = tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = xlv_TEXCOORD2.w;
  vertBlend_4 = tmpvar_98;
  mediump float tmpvar_99;
  tmpvar_99 = clamp (pow ((1.5 * vertBlend_4), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_100;
  tmpvar_100 = mix (tmpvar_90, cb1_8, vec4(tmpvar_99));
  c1_12 = tmpvar_100;
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb2_7, vec4(tmpvar_99));
  c2_11 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb3_6, vec4(tmpvar_99));
  c3_10 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb4_5, vec4(tmpvar_99));
  c4_9 = tmpvar_103;
  mediump vec3 tmpvar_104;
  tmpvar_104 = ((((tmpvar_100 * tmpvar_58.x) + (tmpvar_101 * tmpvar_58.y)) + (tmpvar_103 * tmpvar_59)) + (tmpvar_102 * tmpvar_58.z)).xyz;
  highp vec3 tmpvar_105;
  tmpvar_105 = (tmpvar_104 * _Color.xyz);
  tmpvar_3 = tmpvar_105;
  lightDir_2 = xlv_TEXCOORD4;
  lowp float atten_106;
  atten_106 = texture2D (_LightTexture0, xlv_TEXCOORD6).w;
  lowp vec4 c_107;
  lowp float tmpvar_108;
  tmpvar_108 = max (0.0, dot (xlv_TEXCOORD3, lightDir_2));
  highp vec3 tmpvar_109;
  tmpvar_109 = (((tmpvar_3 * _LightColor0.xyz) * tmpvar_108) * (atten_106 * 2.0));
  c_107.xyz = tmpvar_109;
  c_107.w = 0.0;
  c_1.xyz = c_107.xyz;
  c_1.w = 0.0;
  gl_FragData[0] = c_1;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 5
//   opengl - ALU: 111 to 122, TEX: 16 to 18
//   d3d9 - ALU: 119 to 128, TEX: 16 to 18
SubProgram "opengl " {
Keywords { "POINT" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTexture0] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 116 ALU, 17 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[3];
MOV R0.y, c[2].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[4].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[5].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[6].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[1];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R1, R2.z, R0;
DP3 R0.w, fragment.texcoord[4], fragment.texcoord[4];
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, fragment.texcoord[4];
DP3 R0.w, fragment.texcoord[3], R1;
MUL R0.xyz, R0, c[7];
DP3 R1.w, fragment.texcoord[6], fragment.texcoord[6];
TEX R1.w, R1.w, texture[6], 2D;
MUL R0.xyz, R0, c[0];
MAX R0.w, R0, c[8].x;
MUL R1.x, R1.w, c[9].y;
MUL R0.xyz, R0, R0.w;
MUL result.color.xyz, R0, R1.x;
MOV result.color.w, c[8].x;
END
# 116 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTexture0] 2D
"ps_3_0
; 123 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 2.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
dcl_texcoord6 v6.xyz
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c2.x, r0.y
mov r0.x, c8.y
mul r8.y, c3.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c4.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c5.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c6.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c1, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mad_pp r3.xyz, r0, r0.w, r3
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
dp3_pp r0.w, v4, v4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r0.xyz, r0, r2.z, r3
mul r0.xyz, r0, c7
mul_pp r1.xyz, r0, c0
rsq_pp r0.w, r0.w
mul_pp r2.xyz, r0.w, v4
dp3 r0.x, v6, v6
texld r0.x, r0.x, s6
dp3_pp r0.y, v3, r2
mul_pp r0.w, r0.x, c9.y
max_pp r0.y, r0, c8.z
mul_pp r0.xyz, r1, r0.y
mul oC0.xyz, r0, r0.w
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "POINT" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "POINT" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 111 ALU, 16 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[3];
MOV R0.y, c[2].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[4].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[5].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[6].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[1];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
MAD R1.xyz, R0.w, R1, R4;
MOV R3.xyz, fragment.texcoord[4];
MAD R0.xyz, R1, R2.z, R0;
DP3 R0.w, fragment.texcoord[3], R3;
MUL R0.xyz, R0, c[7];
MAX R0.w, R0, c[8].x;
MUL R0.xyz, R0, c[0];
MUL R0.xyz, R0, R0.w;
MUL result.color.xyz, R0, c[9].y;
MOV result.color.w, c[8].x;
END
# 111 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
"ps_3_0
; 119 ALU, 16 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 2.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c2.x, r0.y
mov r0.x, c8.y
mul r8.y, c3.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c4.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c5.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c6.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c1, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
rcp_pp r2.w, r2.y
mad_pp r0.xyz, r1.w, r1, r0
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mad_pp r0.xyz, r0, r0.w, r3
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mov_pp r3.xyz, v4
dp3_pp r0.w, v3, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r1.xyz, r1.w, r4, r1
mad_pp r0.xyz, r1, r2.z, r0
mul r0.xyz, r0, c7
max_pp r0.w, r0, c8.z
mul_pp r0.xyz, r0, c0
mul_pp r0.xyz, r0, r0.w
mul oC0.xyz, r0, c9.y
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "SPOT" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTexture0] 2D
SetTexture 7 [_LightTextureB0] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 122 ALU, 18 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 0.5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[3];
MOV R0.y, c[2].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[4].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[5].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[6].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[1];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
MUL R1.w, R6.y, R6.x;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R0.xyz, R1, R2.z, R0;
DP3 R0.w, fragment.texcoord[4], fragment.texcoord[4];
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, fragment.texcoord[4];
DP3 R1.x, fragment.texcoord[3], R1;
RCP R0.w, fragment.texcoord[6].w;
MAD R1.zw, fragment.texcoord[6].xyxy, R0.w, c[9].y;
MUL R0.xyz, R0, c[7];
DP3 R1.y, fragment.texcoord[6], fragment.texcoord[6];
TEX R0.w, R1.zwzw, texture[6], 2D;
TEX R1.w, R1.y, texture[7], 2D;
SLT R1.y, c[8].x, fragment.texcoord[6].z;
MUL R0.w, R1.y, R0;
MUL R1.y, R0.w, R1.w;
MAX R0.w, R1.x, c[8].x;
MUL R0.xyz, R0, c[0];
MUL R1.x, R1.y, c[9].z;
MUL R0.xyz, R0, R0.w;
MUL result.color.xyz, R0, R1.x;
MOV result.color.w, c[8].x;
END
# 122 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "SPOT" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTexture0] 2D
SetTexture 7 [_LightTextureB0] 2D
"ps_3_0
; 128 ALU, 18 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 0.00000000, 1.00000000, 0.50000000
def c10, 2.00000000, 0, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
dcl_texcoord6 v6
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c2.x, r0.y
mov r0.x, c8.y
mul r8.y, c3.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c4.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c5.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c6.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c1, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mad_pp r3.xyz, r0, r0.w, r3
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
dp3_pp r0.w, v4, v4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r0.xyz, r0, r2.z, r3
mul r0.xyz, r0, c7
rsq_pp r0.w, r0.w
mul_pp r2.xyz, r0, c0
mul_pp r0.xyz, r0.w, v4
dp3_pp r0.y, v3, r0
rcp r0.w, v6.w
mad r1.xy, v6, r0.w, c9.w
dp3 r0.x, v6, v6
texld r0.w, r1, s6
cmp r0.z, -v6, c9.y, c9
mul_pp r0.z, r0, r0.w
texld r0.x, r0.x, s7
mul_pp r0.z, r0, r0.x
mul_pp r0.w, r0.z, c10.x
max_pp r0.x, r0.y, c8.z
mul_pp r0.xyz, r2, r0.x
mul oC0.xyz, r0, r0.w
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "SPOT" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "SPOT" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "POINT_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTextureB0] 2D
SetTexture 7 [_LightTexture0] CUBE
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 118 ALU, 18 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[3];
MOV R0.y, c[2].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[4].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[5].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[6].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[1];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
MUL R1.w, R6.y, R6.x;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R0.xyz, R1, R2.z, R0;
DP3 R0.w, fragment.texcoord[4], fragment.texcoord[4];
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, fragment.texcoord[4];
DP3 R1.x, fragment.texcoord[3], R1;
DP3 R1.y, fragment.texcoord[6], fragment.texcoord[6];
MUL R0.xyz, R0, c[7];
TEX R0.w, fragment.texcoord[6], texture[7], CUBE;
TEX R1.w, R1.y, texture[6], 2D;
MUL R1.y, R1.w, R0.w;
MAX R0.w, R1.x, c[8].x;
MUL R0.xyz, R0, c[0];
MUL R1.x, R1.y, c[9].y;
MUL R0.xyz, R0, R0.w;
MUL result.color.xyz, R0, R1.x;
MOV result.color.w, c[8].x;
END
# 118 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTextureB0] 2D
SetTexture 7 [_LightTexture0] CUBE
"ps_3_0
; 124 ALU, 18 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_cube s7
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 2.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
dcl_texcoord6 v6.xyz
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c2.x, r0.y
mov r0.x, c8.y
mul r8.y, c3.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c4.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c5.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c6.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c1, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
rcp_pp r2.w, r2.y
mad_pp r0.xyz, r1.w, r1, r0
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mad_pp r0.xyz, r0, r0.w, r3
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
dp3_pp r0.w, v4, v4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r1.xyz, r1.w, r4, r1
mad_pp r0.xyz, r1, r2.z, r0
mul r0.xyz, r0, c7
mul_pp r1.xyz, r0, c0
rsq_pp r0.w, r0.w
mul_pp r2.xyz, r0.w, v4
dp3 r0.x, v6, v6
dp3_pp r0.y, v3, r2
texld r0.w, v6, s7
texld r0.x, r0.x, s6
mul r0.z, r0.x, r0.w
mul_pp r0.w, r0.z, c9.y
max_pp r0.x, r0.y, c8.z
mul_pp r0.xyz, r1, r0.x
mul oC0.xyz, r0, r0.w
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "POINT_COOKIE" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "POINT_COOKIE" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTexture0] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 113 ALU, 17 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[3];
MOV R0.y, c[2].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[4].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[5].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[6].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[1];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R1, R2.z, R0;
MOV R1.xyz, fragment.texcoord[4];
DP3 R0.w, fragment.texcoord[3], R1;
MUL R0.xyz, R0, c[7];
TEX R1.w, fragment.texcoord[6], texture[6], 2D;
MUL R0.xyz, R0, c[0];
MAX R0.w, R0, c[8].x;
MUL R1.x, R1.w, c[9].y;
MUL R0.xyz, R0, R0.w;
MUL result.color.xyz, R0, R1.x;
MOV result.color.w, c[8].x;
END
# 113 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_TilingTop]
Float 2 [_TilingSides]
Float 3 [_TilingRed]
Float 4 [_TilingGreen]
Float 5 [_TilingBlue]
Float 6 [_TilingAlpha]
Vector 7 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightTexture0] 2D
"ps_3_0
; 120 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 2.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
dcl_texcoord6 v6.xy
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c2.x, r0.y
mov r0.x, c8.y
mul r8.y, c3.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c4.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c5.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c6.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
mov_pp r1.w, r0.x
add_pp r2.xyz, r2, -r1
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c1, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
mad_pp r3.xyz, r0, r0.w, r3
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mov_pp r1.xyz, v4
dp3_pp r0.w, v3, r1
mad_pp r0.xyz, r0, r2.z, r3
mul r0.xyz, r0, c7
texld r1.w, v6, s6
mul_pp r0.xyz, r0, c0
max_pp r0.w, r0, c8.z
mul_pp r1.x, r1.w, c9.y
mul_pp r0.xyz, r0, r0.w
mul oC0.xyz, r0, r1.x
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES"
}

}
	}
	Pass {
		Name "PREPASS"
		Tags { "LightMode" = "PrePassBase" }
		Fog {Mode Off}
Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 11 to 11
//   d3d9 - ALU: 11 to 11
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 5 [_Object2World]
Vector 9 [unity_Scale]
"3.0-!!ARBvp1.0
# 11 ALU
PARAM c[10] = { program.local[0],
		state.matrix.mvp,
		program.local[5..9] };
TEMP R0;
TEMP R1;
MUL R1.xyz, vertex.normal, c[9].w;
DP3 R0.z, R1, c[7];
DP3 R0.x, R1, c[5];
DP3 R0.y, R1, c[6];
MOV result.texcoord[0].xyz, R0;
MOV result.texcoord[2].xyz, R0;
MOV result.texcoord[1], vertex.color;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 11 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [_Object2World]
Vector 8 [unity_Scale]
"vs_3_0
; 11 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c8.w
dp3 r0.z, r1, c6
dp3 r0.x, r1, c4
dp3 r0.y, r1, c5
mov o1.xyz, r0
mov o3.xyz, r0
mov o2, v2
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD2;
varying highp vec4 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_5;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_3 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD1 = _glesColor;
  xlv_TEXCOORD2 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD2;
varying highp vec4 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 res_1;
  highp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * tmpvar_2.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * tmpvar_2.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * tmpvar_2.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * tmpvar_2.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * tmpvar_2.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * tmpvar_2.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * tmpvar_2.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * tmpvar_2.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * tmpvar_2.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * tmpvar_2.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * tmpvar_2.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * tmpvar_2.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * tmpvar_2.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * tmpvar_2.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * tmpvar_2.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * tmpvar_2.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD0.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD0.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD0.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  blendWeights_13 = (tmpvar_54 * tmpvar_56);
  blendBottom_12 = (tmpvar_55 * tmpvar_56.x);
  lowp vec4 tmpvar_57;
  tmpvar_57 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_57;
  lowp vec4 tmpvar_58;
  tmpvar_58 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_64;
  highp float tmpvar_65;
  tmpvar_65 = xlv_TEXCOORD1.x;
  vertBlend_3 = tmpvar_65;
  mediump float tmpvar_66;
  tmpvar_66 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_67;
  tmpvar_67 = mix (c1_11, cb1_7, vec4(tmpvar_66));
  mediump vec4 tmpvar_68;
  tmpvar_68 = mix (c2_10, cb2_6, vec4(tmpvar_66));
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c3_9, cb3_5, vec4(tmpvar_66));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c4_8, cb4_4, vec4(tmpvar_66));
  lowp vec4 tmpvar_71;
  tmpvar_71 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_71;
  lowp vec4 tmpvar_72;
  tmpvar_72 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_72;
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_74;
  highp float tmpvar_75;
  tmpvar_75 = xlv_TEXCOORD1.y;
  vertBlend_3 = tmpvar_75;
  mediump float tmpvar_76;
  tmpvar_76 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_77;
  tmpvar_77 = mix (tmpvar_67, cb1_7, vec4(tmpvar_76));
  mediump vec4 tmpvar_78;
  tmpvar_78 = mix (tmpvar_68, cb2_6, vec4(tmpvar_76));
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb3_5, vec4(tmpvar_76));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb4_4, vec4(tmpvar_76));
  lowp vec4 tmpvar_81;
  tmpvar_81 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_81;
  lowp vec4 tmpvar_82;
  tmpvar_82 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_82;
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_84;
  highp float tmpvar_85;
  tmpvar_85 = xlv_TEXCOORD1.z;
  vertBlend_3 = tmpvar_85;
  mediump float tmpvar_86;
  tmpvar_86 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_87;
  tmpvar_87 = mix (tmpvar_77, cb1_7, vec4(tmpvar_86));
  mediump vec4 tmpvar_88;
  tmpvar_88 = mix (tmpvar_78, cb2_6, vec4(tmpvar_86));
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb3_5, vec4(tmpvar_86));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb4_4, vec4(tmpvar_86));
  lowp vec4 tmpvar_91;
  tmpvar_91 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_91;
  lowp vec4 tmpvar_92;
  tmpvar_92 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_92;
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_94;
  highp float tmpvar_95;
  tmpvar_95 = xlv_TEXCOORD1.w;
  vertBlend_3 = tmpvar_95;
  mediump float tmpvar_96;
  tmpvar_96 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  c1_11 = mix (tmpvar_87, cb1_7, vec4(tmpvar_96));
  c2_10 = mix (tmpvar_88, cb2_6, vec4(tmpvar_96));
  c3_9 = mix (tmpvar_89, cb3_5, vec4(tmpvar_96));
  c4_8 = mix (tmpvar_90, cb4_4, vec4(tmpvar_96));
  res_1.xyz = ((xlv_TEXCOORD2 * 0.5) + 0.5);
  res_1.w = 0.0;
  gl_FragData[0] = res_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD2;
varying highp vec4 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  lowp vec3 tmpvar_2;
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * (tmpvar_1 * unity_Scale.w));
  tmpvar_2 = tmpvar_5;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_3 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD1 = _glesColor;
  xlv_TEXCOORD2 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD2;
varying highp vec4 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 res_1;
  highp vec3 tmpvar_2;
  mediump float vertBlend_3;
  mediump vec4 cb4_4;
  mediump vec4 cb3_5;
  mediump vec4 cb2_6;
  mediump vec4 cb1_7;
  mediump vec4 c4_8;
  mediump vec4 c3_9;
  mediump vec4 c2_10;
  mediump vec4 c1_11;
  mediump float blendBottom_12;
  mediump vec3 blendWeights_13;
  mediump vec2 uv3Alpha_14;
  mediump vec2 uv2Alpha_15;
  mediump vec2 uv1Alpha_16;
  mediump vec2 uv3Blue_17;
  mediump vec2 uv2Blue_18;
  mediump vec2 uv1Blue_19;
  mediump vec2 uv3Green_20;
  mediump vec2 uv2Green_21;
  mediump vec2 uv1Green_22;
  mediump vec2 uv3Red_23;
  mediump vec2 uv2Red_24;
  mediump vec2 uv1Red_25;
  mediump vec2 uv3Sides_26;
  mediump vec2 uv2Sides_27;
  mediump vec2 uv1Sides_28;
  mediump vec2 uv2Top_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (_TilingTop / 10.0);
  tmpvar_30.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_31;
  tmpvar_31 = (tmpvar_30 * tmpvar_2.xz);
  uv2Top_29 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingSides / 10.0);
  tmpvar_32.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * tmpvar_2.zy);
  uv1Sides_28 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34 = (tmpvar_32 * tmpvar_2.xz);
  uv2Sides_27 = tmpvar_34;
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_32 * tmpvar_2.xy);
  uv3Sides_26 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingRed / 10.0);
  tmpvar_36.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * tmpvar_2.zy);
  uv1Red_25 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * tmpvar_2.xz);
  uv2Red_24 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * tmpvar_2.xy);
  uv3Red_23 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingGreen / 10.0);
  tmpvar_40.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * tmpvar_2.zy);
  uv1Green_22 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * tmpvar_2.xz);
  uv2Green_21 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * tmpvar_2.xy);
  uv3Green_20 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingBlue / 10.0);
  tmpvar_44.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * tmpvar_2.zy);
  uv1Blue_19 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * tmpvar_2.xz);
  uv2Blue_18 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * tmpvar_2.xy);
  uv3Blue_17 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingAlpha / 10.0);
  tmpvar_48.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * tmpvar_2.zy);
  uv1Alpha_16 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * tmpvar_2.xz);
  uv2Alpha_15 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * tmpvar_2.xy);
  uv3Alpha_14 = tmpvar_51;
  blendWeights_13.xz = xlv_TEXCOORD0.xz;
  highp float tmpvar_52;
  tmpvar_52 = max (xlv_TEXCOORD0.y, 0.0);
  blendWeights_13.y = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = min (xlv_TEXCOORD0.y, 0.0);
  blendBottom_12 = tmpvar_53;
  mediump vec3 tmpvar_54;
  tmpvar_54 = clamp (pow ((blendWeights_13 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_55;
  tmpvar_55 = clamp (pow ((blendBottom_12 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_56;
  tmpvar_56 = vec3((1.0/((((tmpvar_54.x + tmpvar_54.y) + tmpvar_54.z) + tmpvar_55))));
  blendWeights_13 = (tmpvar_54 * tmpvar_56);
  blendBottom_12 = (tmpvar_55 * tmpvar_56.x);
  lowp vec4 tmpvar_57;
  tmpvar_57 = texture2D (_MainTex2, uv1Sides_28);
  c1_11 = tmpvar_57;
  lowp vec4 tmpvar_58;
  tmpvar_58 = texture2D (_MainTex, uv2Top_29);
  c2_10 = tmpvar_58;
  lowp vec4 tmpvar_59;
  tmpvar_59 = texture2D (_MainTex2, uv3Sides_26);
  c3_9 = tmpvar_59;
  lowp vec4 tmpvar_60;
  tmpvar_60 = texture2D (_MainTex2, uv2Sides_27);
  c4_8 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_BlendTex1, uv1Red_25);
  cb1_7 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_BlendTex1, uv2Red_24);
  cb2_6 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_BlendTex1, uv3Red_23);
  cb3_5 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_BlendTex1, uv2Red_24);
  cb4_4 = tmpvar_64;
  highp float tmpvar_65;
  tmpvar_65 = xlv_TEXCOORD1.x;
  vertBlend_3 = tmpvar_65;
  mediump float tmpvar_66;
  tmpvar_66 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_67;
  tmpvar_67 = mix (c1_11, cb1_7, vec4(tmpvar_66));
  mediump vec4 tmpvar_68;
  tmpvar_68 = mix (c2_10, cb2_6, vec4(tmpvar_66));
  mediump vec4 tmpvar_69;
  tmpvar_69 = mix (c3_9, cb3_5, vec4(tmpvar_66));
  mediump vec4 tmpvar_70;
  tmpvar_70 = mix (c4_8, cb4_4, vec4(tmpvar_66));
  lowp vec4 tmpvar_71;
  tmpvar_71 = texture2D (_BlendTex2, uv1Green_22);
  cb1_7 = tmpvar_71;
  lowp vec4 tmpvar_72;
  tmpvar_72 = texture2D (_BlendTex2, uv2Green_21);
  cb2_6 = tmpvar_72;
  lowp vec4 tmpvar_73;
  tmpvar_73 = texture2D (_BlendTex2, uv3Green_20);
  cb3_5 = tmpvar_73;
  lowp vec4 tmpvar_74;
  tmpvar_74 = texture2D (_BlendTex2, uv2Green_21);
  cb4_4 = tmpvar_74;
  highp float tmpvar_75;
  tmpvar_75 = xlv_TEXCOORD1.y;
  vertBlend_3 = tmpvar_75;
  mediump float tmpvar_76;
  tmpvar_76 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_77;
  tmpvar_77 = mix (tmpvar_67, cb1_7, vec4(tmpvar_76));
  mediump vec4 tmpvar_78;
  tmpvar_78 = mix (tmpvar_68, cb2_6, vec4(tmpvar_76));
  mediump vec4 tmpvar_79;
  tmpvar_79 = mix (tmpvar_69, cb3_5, vec4(tmpvar_76));
  mediump vec4 tmpvar_80;
  tmpvar_80 = mix (tmpvar_70, cb4_4, vec4(tmpvar_76));
  lowp vec4 tmpvar_81;
  tmpvar_81 = texture2D (_BlendTex3, uv1Blue_19);
  cb1_7 = tmpvar_81;
  lowp vec4 tmpvar_82;
  tmpvar_82 = texture2D (_BlendTex3, uv2Blue_18);
  cb2_6 = tmpvar_82;
  lowp vec4 tmpvar_83;
  tmpvar_83 = texture2D (_BlendTex3, uv3Blue_17);
  cb3_5 = tmpvar_83;
  lowp vec4 tmpvar_84;
  tmpvar_84 = texture2D (_BlendTex3, uv2Blue_18);
  cb4_4 = tmpvar_84;
  highp float tmpvar_85;
  tmpvar_85 = xlv_TEXCOORD1.z;
  vertBlend_3 = tmpvar_85;
  mediump float tmpvar_86;
  tmpvar_86 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_87;
  tmpvar_87 = mix (tmpvar_77, cb1_7, vec4(tmpvar_86));
  mediump vec4 tmpvar_88;
  tmpvar_88 = mix (tmpvar_78, cb2_6, vec4(tmpvar_86));
  mediump vec4 tmpvar_89;
  tmpvar_89 = mix (tmpvar_79, cb3_5, vec4(tmpvar_86));
  mediump vec4 tmpvar_90;
  tmpvar_90 = mix (tmpvar_80, cb4_4, vec4(tmpvar_86));
  lowp vec4 tmpvar_91;
  tmpvar_91 = texture2D (_BlendTex4, uv1Alpha_16);
  cb1_7 = tmpvar_91;
  lowp vec4 tmpvar_92;
  tmpvar_92 = texture2D (_BlendTex4, uv2Alpha_15);
  cb2_6 = tmpvar_92;
  lowp vec4 tmpvar_93;
  tmpvar_93 = texture2D (_BlendTex4, uv3Alpha_14);
  cb3_5 = tmpvar_93;
  lowp vec4 tmpvar_94;
  tmpvar_94 = texture2D (_BlendTex4, uv2Alpha_15);
  cb4_4 = tmpvar_94;
  highp float tmpvar_95;
  tmpvar_95 = xlv_TEXCOORD1.w;
  vertBlend_3 = tmpvar_95;
  mediump float tmpvar_96;
  tmpvar_96 = clamp (pow ((1.5 * vertBlend_3), 1.5), 0.0, 1.0);
  c1_11 = mix (tmpvar_87, cb1_7, vec4(tmpvar_96));
  c2_10 = mix (tmpvar_88, cb2_6, vec4(tmpvar_96));
  c3_9 = mix (tmpvar_89, cb3_5, vec4(tmpvar_96));
  c4_8 = mix (tmpvar_90, cb4_4, vec4(tmpvar_96));
  res_1.xyz = ((xlv_TEXCOORD2 * 0.5) + 0.5);
  res_1.w = 0.0;
  gl_FragData[0] = res_1;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 2 to 2, TEX: 0 to 0
//   d3d9 - ALU: 2 to 2
SubProgram "opengl " {
Keywords { }
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 2 ALU, 0 TEX
PARAM c[1] = { { 0, 0.5 } };
MAD result.color.xyz, fragment.texcoord[2], c[0].y, c[0].y;
MOV result.color.w, c[0].x;
END
# 2 instructions, 0 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
"ps_3_0
; 2 ALU
def c0, 0.50000000, 0.00000000, 0, 0
dcl_texcoord2 v1.xyz
mad_pp oC0.xyz, v1, c0.x, c0.x
mov_pp oC0.w, c0.y
"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

}
	}
	Pass {
		Name "PREPASS"
		Tags { "LightMode" = "PrePassFinal" }
		ZWrite Off
Program "vp" {
// Vertex combos: 6
//   opengl - ALU: 25 to 34
//   d3d9 - ALU: 25 to 34
SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_ProjectionParams]
Vector 10 [unity_SHAr]
Vector 11 [unity_SHAg]
Vector 12 [unity_SHAb]
Vector 13 [unity_SHBr]
Vector 14 [unity_SHBg]
Vector 15 [unity_SHBb]
Vector 16 [unity_SHC]
Matrix 5 [_Object2World]
Vector 17 [unity_Scale]
"3.0-!!ARBvp1.0
# 34 ALU
PARAM c[18] = { { 0.5, 1 },
		state.matrix.mvp,
		program.local[5..17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MUL R1.xyz, vertex.normal, c[17].w;
DP3 R0.zw, R1, c[6];
DP3 R4.x, R1, c[5];
DP3 R4.z, R1, c[7];
MOV R4.y, R0.z;
MUL R1, R4.xyzz, R4.yzzx;
MOV R4.w, c[0].y;
MUL R0.x, R0.z, R0.z;
DP4 R3.z, R1, c[15];
DP4 R3.y, R1, c[14];
DP4 R3.x, R1, c[13];
DP4 R1.w, vertex.position, c[4];
DP4 R1.z, vertex.position, c[3];
DP4 R2.z, R4, c[12];
DP4 R2.y, R4, c[11];
DP4 R2.x, R4, c[10];
MAD R0.x, R4, R4, -R0;
ADD R3.xyz, R2, R3;
MUL R2.xyz, R0.x, c[16];
DP4 R1.x, vertex.position, c[1];
DP4 R1.y, vertex.position, c[2];
MUL R0.xyz, R1.xyww, c[0].x;
MUL R0.y, R0, c[9].x;
ADD result.texcoord[4].xyz, R3, R2;
ADD result.texcoord[3].xy, R0, R0.z;
MOV result.position, R1;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[3].zw, R1;
MOV result.texcoord[1].z, R4;
MOV result.texcoord[1].y, R0.w;
MOV result.texcoord[1].x, R4;
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 34 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Vector 10 [unity_SHAr]
Vector 11 [unity_SHAg]
Vector 12 [unity_SHAb]
Vector 13 [unity_SHBr]
Vector 14 [unity_SHBg]
Vector 15 [unity_SHBb]
Vector 16 [unity_SHC]
Matrix 4 [_Object2World]
Vector 17 [unity_Scale]
"vs_3_0
; 34 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c18, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c17.w
dp3 r0.zw, r1, c5
dp3 r4.x, r1, c4
dp3 r4.z, r1, c6
mov r4.y, r0.z
mul r1, r4.xyzz, r4.yzzx
mov r4.w, c18.y
mul r0.x, r0.z, r0.z
dp4 r3.z, r1, c15
dp4 r3.y, r1, c14
dp4 r3.x, r1, c13
dp4 r1.w, v0, c3
dp4 r1.z, v0, c2
dp4 r2.z, r4, c12
dp4 r2.y, r4, c11
dp4 r2.x, r4, c10
mad r0.x, r4, r4, -r0
add r3.xyz, r2, r3
mul r2.xyz, r0.x, c16
dp4 r1.x, v0, c0
dp4 r1.y, v0, c1
mul r0.xyz, r1.xyww, c18.x
mul r0.y, r0, c8.x
add o5.xyz, r3, r2
mad o4.xy, r0.z, c9.zwzw, r0
mov o0, r1
mov o3, v2
mov o4.zw, r1
mov o2.z, r4
mov o2.y, r0.w
mov o2.x, r4
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 _ProjectionParams;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 tmpvar_2;
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  mediump vec3 tmpvar_10;
  mediump vec4 normal_11;
  normal_11 = tmpvar_9;
  highp float vC_12;
  mediump vec3 x3_13;
  mediump vec3 x2_14;
  mediump vec3 x1_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAr, normal_11);
  x1_15.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAg, normal_11);
  x1_15.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHAb, normal_11);
  x1_15.z = tmpvar_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = (normal_11.xyzz * normal_11.yzzx);
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBr, tmpvar_19);
  x2_14.x = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBg, tmpvar_19);
  x2_14.y = tmpvar_21;
  highp float tmpvar_22;
  tmpvar_22 = dot (unity_SHBb, tmpvar_19);
  x2_14.z = tmpvar_22;
  mediump float tmpvar_23;
  tmpvar_23 = ((normal_11.x * normal_11.x) - (normal_11.y * normal_11.y));
  vC_12 = tmpvar_23;
  highp vec3 tmpvar_24;
  tmpvar_24 = (unity_SHC.xyz * vC_12);
  x3_13 = tmpvar_24;
  tmpvar_10 = ((x1_15 + x2_14) + x3_13);
  tmpvar_2 = tmpvar_10;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  mediump vec4 tmpvar_108;
  tmpvar_108 = -(log2(max (light_3, vec4(0.001, 0.001, 0.001, 0.001))));
  light_3.w = tmpvar_108.w;
  highp vec3 tmpvar_109;
  tmpvar_109 = (tmpvar_108.xyz + xlv_TEXCOORD4);
  light_3.xyz = tmpvar_109;
  lowp vec4 c_110;
  mediump vec3 tmpvar_111;
  tmpvar_111 = (tmpvar_4 * light_3.xyz);
  c_110.xyz = tmpvar_111;
  c_110.w = 0.0;
  c_2 = c_110;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 _ProjectionParams;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 tmpvar_2;
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  mediump vec3 tmpvar_10;
  mediump vec4 normal_11;
  normal_11 = tmpvar_9;
  highp float vC_12;
  mediump vec3 x3_13;
  mediump vec3 x2_14;
  mediump vec3 x1_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAr, normal_11);
  x1_15.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAg, normal_11);
  x1_15.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHAb, normal_11);
  x1_15.z = tmpvar_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = (normal_11.xyzz * normal_11.yzzx);
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBr, tmpvar_19);
  x2_14.x = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBg, tmpvar_19);
  x2_14.y = tmpvar_21;
  highp float tmpvar_22;
  tmpvar_22 = dot (unity_SHBb, tmpvar_19);
  x2_14.z = tmpvar_22;
  mediump float tmpvar_23;
  tmpvar_23 = ((normal_11.x * normal_11.x) - (normal_11.y * normal_11.y));
  vC_12 = tmpvar_23;
  highp vec3 tmpvar_24;
  tmpvar_24 = (unity_SHC.xyz * vC_12);
  x3_13 = tmpvar_24;
  tmpvar_10 = ((x1_15 + x2_14) + x3_13);
  tmpvar_2 = tmpvar_10;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  mediump vec4 tmpvar_108;
  tmpvar_108 = -(log2(max (light_3, vec4(0.001, 0.001, 0.001, 0.001))));
  light_3.w = tmpvar_108.w;
  highp vec3 tmpvar_109;
  tmpvar_109 = (tmpvar_108.xyz + xlv_TEXCOORD4);
  light_3.xyz = tmpvar_109;
  lowp vec4 c_110;
  mediump vec3 tmpvar_111;
  tmpvar_111 = (tmpvar_4 * light_3.xyz);
  c_110.xyz = tmpvar_111;
  c_110.w = 0.0;
  c_2 = c_110;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 13 [_ProjectionParams]
Vector 14 [unity_ShadowFadeCenterAndType]
Matrix 9 [_Object2World]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 25 ALU
PARAM c[17] = { { 0.5, 1 },
		state.matrix.modelview[0],
		state.matrix.mvp,
		program.local[9..16] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[8];
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
MUL R1.xyz, R0.xyww, c[0].x;
MOV result.position, R0;
MUL R1.y, R1, c[13].x;
ADD result.texcoord[3].xy, R1, R1.z;
MUL R1.xyz, vertex.normal, c[15].w;
MOV result.texcoord[3].zw, R0;
DP4 R0.z, vertex.position, c[11];
DP4 R0.x, vertex.position, c[9];
DP4 R0.y, vertex.position, c[10];
MOV result.texcoord[0].xyz, R0;
ADD R0.xyz, R0, -c[14];
MUL result.texcoord[5].xyz, R0, c[14].w;
MOV R0.x, c[0].y;
ADD R0.y, R0.x, -c[14].w;
DP4 R0.x, vertex.position, c[3];
MOV result.texcoord[2], vertex.color;
DP3 result.texcoord[1].z, R1, c[11];
DP3 result.texcoord[1].y, R1, c[10];
DP3 result.texcoord[1].x, R1, c[9];
MAD result.texcoord[4].xy, vertex.texcoord[1], c[16], c[16].zwzw;
MUL result.texcoord[5].w, -R0.x, R0.y;
END
# 25 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_modelview0]
Matrix 4 [glstate_matrix_mvp]
Vector 12 [_ProjectionParams]
Vector 13 [_ScreenParams]
Vector 14 [unity_ShadowFadeCenterAndType]
Matrix 8 [_Object2World]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"vs_3_0
; 25 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c17, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dcl_color0 v3
dp4 r0.w, v0, c7
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mul r1.xyz, r0.xyww, c17.x
mov o0, r0
mul r1.y, r1, c12.x
mad o4.xy, r1.z, c13.zwzw, r1
mul r1.xyz, v1, c15.w
mov o4.zw, r0
dp4 r0.z, v0, c10
dp4 r0.x, v0, c8
dp4 r0.y, v0, c9
mov o1.xyz, r0
add r0.xyz, r0, -c14
mul o6.xyz, r0, c14.w
mov r0.x, c14.w
add r0.y, c17, -r0.x
dp4 r0.x, v0, c2
mov o3, v3
dp3 o2.z, r1, c10
dp3 o2.y, r1, c9
dp3 o2.x, r1, c8
mad o5.xy, v2, c16, c16.zwzw
mul o6.w, -r0.x, r0.y
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;


uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 _ProjectionParams;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_3 * 0.5);
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_4.xy = (tmpvar_6 + tmpvar_5.w);
  o_4.zw = tmpvar_3.zw;
  tmpvar_1.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_1.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_2 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_4;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec3 lmIndirect_3;
  mediump vec3 lmFull_4;
  mediump vec4 light_5;
  lowp vec3 tmpvar_6;
  mediump float vertBlend_7;
  mediump vec4 cb4_8;
  mediump vec4 cb3_9;
  mediump vec4 cb2_10;
  mediump vec4 cb1_11;
  mediump vec4 c4_12;
  mediump vec4 c3_13;
  mediump vec4 c2_14;
  mediump vec4 c1_15;
  mediump float blendBottom_16;
  mediump vec3 blendWeights_17;
  mediump vec2 uv3Alpha_18;
  mediump vec2 uv2Alpha_19;
  mediump vec2 uv1Alpha_20;
  mediump vec2 uv3Blue_21;
  mediump vec2 uv2Blue_22;
  mediump vec2 uv1Blue_23;
  mediump vec2 uv3Green_24;
  mediump vec2 uv2Green_25;
  mediump vec2 uv1Green_26;
  mediump vec2 uv3Red_27;
  mediump vec2 uv2Red_28;
  mediump vec2 uv1Red_29;
  mediump vec2 uv3Sides_30;
  mediump vec2 uv2Sides_31;
  mediump vec2 uv1Sides_32;
  mediump vec2 uv2Top_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingTop / 10.0);
  tmpvar_34.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Top_33 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingSides / 10.0);
  tmpvar_36.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Sides_32 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Sides_31 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Sides_30 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingRed / 10.0);
  tmpvar_40.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Red_29 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Red_28 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Red_27 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingGreen / 10.0);
  tmpvar_44.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Green_26 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Green_25 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Green_24 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingBlue / 10.0);
  tmpvar_48.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Blue_23 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Blue_22 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Blue_21 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52.x = (_TilingAlpha / 10.0);
  tmpvar_52.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_52 * xlv_TEXCOORD0.zy);
  uv1Alpha_20 = tmpvar_53;
  highp vec2 tmpvar_54;
  tmpvar_54 = (tmpvar_52 * xlv_TEXCOORD0.xz);
  uv2Alpha_19 = tmpvar_54;
  highp vec2 tmpvar_55;
  tmpvar_55 = (tmpvar_52 * xlv_TEXCOORD0.xy);
  uv3Alpha_18 = tmpvar_55;
  blendWeights_17.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_56;
  tmpvar_56 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_17.y = tmpvar_56;
  highp float tmpvar_57;
  tmpvar_57 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_16 = tmpvar_57;
  mediump vec3 tmpvar_58;
  tmpvar_58 = clamp (pow ((blendWeights_17 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_59;
  tmpvar_59 = clamp (pow ((blendBottom_16 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_60;
  tmpvar_60 = vec3((1.0/((((tmpvar_58.x + tmpvar_58.y) + tmpvar_58.z) + tmpvar_59))));
  mediump vec3 tmpvar_61;
  tmpvar_61 = (tmpvar_58 * tmpvar_60);
  blendWeights_17 = tmpvar_61;
  mediump float tmpvar_62;
  tmpvar_62 = (tmpvar_59 * tmpvar_60.x);
  blendBottom_16 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv1Sides_32);
  c1_15 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex, uv2Top_33);
  c2_14 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_MainTex2, uv3Sides_30);
  c3_13 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_MainTex2, uv2Sides_31);
  c4_12 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv1Red_29);
  cb1_11 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_28);
  cb2_10 = tmpvar_68;
  lowp vec4 tmpvar_69;
  tmpvar_69 = texture2D (_BlendTex1, uv3Red_27);
  cb3_9 = tmpvar_69;
  lowp vec4 tmpvar_70;
  tmpvar_70 = texture2D (_BlendTex1, uv2Red_28);
  cb4_8 = tmpvar_70;
  highp float tmpvar_71;
  tmpvar_71 = xlv_TEXCOORD2.x;
  vertBlend_7 = tmpvar_71;
  mediump float tmpvar_72;
  tmpvar_72 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c1_15, cb1_11, vec4(tmpvar_72));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c2_14, cb2_10, vec4(tmpvar_72));
  mediump vec4 tmpvar_75;
  tmpvar_75 = mix (c3_13, cb3_9, vec4(tmpvar_72));
  mediump vec4 tmpvar_76;
  tmpvar_76 = mix (c4_12, cb4_8, vec4(tmpvar_72));
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv1Green_26);
  cb1_11 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_25);
  cb2_10 = tmpvar_78;
  lowp vec4 tmpvar_79;
  tmpvar_79 = texture2D (_BlendTex2, uv3Green_24);
  cb3_9 = tmpvar_79;
  lowp vec4 tmpvar_80;
  tmpvar_80 = texture2D (_BlendTex2, uv2Green_25);
  cb4_8 = tmpvar_80;
  highp float tmpvar_81;
  tmpvar_81 = xlv_TEXCOORD2.y;
  vertBlend_7 = tmpvar_81;
  mediump float tmpvar_82;
  tmpvar_82 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb1_11, vec4(tmpvar_82));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb2_10, vec4(tmpvar_82));
  mediump vec4 tmpvar_85;
  tmpvar_85 = mix (tmpvar_75, cb3_9, vec4(tmpvar_82));
  mediump vec4 tmpvar_86;
  tmpvar_86 = mix (tmpvar_76, cb4_8, vec4(tmpvar_82));
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv1Blue_23);
  cb1_11 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_22);
  cb2_10 = tmpvar_88;
  lowp vec4 tmpvar_89;
  tmpvar_89 = texture2D (_BlendTex3, uv3Blue_21);
  cb3_9 = tmpvar_89;
  lowp vec4 tmpvar_90;
  tmpvar_90 = texture2D (_BlendTex3, uv2Blue_22);
  cb4_8 = tmpvar_90;
  highp float tmpvar_91;
  tmpvar_91 = xlv_TEXCOORD2.z;
  vertBlend_7 = tmpvar_91;
  mediump float tmpvar_92;
  tmpvar_92 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb1_11, vec4(tmpvar_92));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb2_10, vec4(tmpvar_92));
  mediump vec4 tmpvar_95;
  tmpvar_95 = mix (tmpvar_85, cb3_9, vec4(tmpvar_92));
  mediump vec4 tmpvar_96;
  tmpvar_96 = mix (tmpvar_86, cb4_8, vec4(tmpvar_92));
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv1Alpha_20);
  cb1_11 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_19);
  cb2_10 = tmpvar_98;
  lowp vec4 tmpvar_99;
  tmpvar_99 = texture2D (_BlendTex4, uv3Alpha_18);
  cb3_9 = tmpvar_99;
  lowp vec4 tmpvar_100;
  tmpvar_100 = texture2D (_BlendTex4, uv2Alpha_19);
  cb4_8 = tmpvar_100;
  highp float tmpvar_101;
  tmpvar_101 = xlv_TEXCOORD2.w;
  vertBlend_7 = tmpvar_101;
  mediump float tmpvar_102;
  tmpvar_102 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb1_11, vec4(tmpvar_102));
  c1_15 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb2_10, vec4(tmpvar_102));
  c2_14 = tmpvar_104;
  mediump vec4 tmpvar_105;
  tmpvar_105 = mix (tmpvar_95, cb3_9, vec4(tmpvar_102));
  c3_13 = tmpvar_105;
  mediump vec4 tmpvar_106;
  tmpvar_106 = mix (tmpvar_96, cb4_8, vec4(tmpvar_102));
  c4_12 = tmpvar_106;
  mediump vec3 tmpvar_107;
  tmpvar_107 = ((((tmpvar_103 * tmpvar_61.x) + (tmpvar_104 * tmpvar_61.y)) + (tmpvar_106 * tmpvar_62)) + (tmpvar_105 * tmpvar_61.z)).xyz;
  highp vec3 tmpvar_108;
  tmpvar_108 = (tmpvar_107 * _Color.xyz);
  tmpvar_6 = tmpvar_108;
  lowp vec4 tmpvar_109;
  tmpvar_109 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_5 = tmpvar_109;
  mediump vec4 tmpvar_110;
  tmpvar_110 = -(log2(max (light_5, vec4(0.001, 0.001, 0.001, 0.001))));
  light_5.w = tmpvar_110.w;
  lowp vec3 tmpvar_111;
  tmpvar_111 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD4).xyz);
  lmFull_4 = tmpvar_111;
  lowp vec3 tmpvar_112;
  tmpvar_112 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD4).xyz);
  lmIndirect_3 = tmpvar_112;
  highp float tmpvar_113;
  tmpvar_113 = clamp (((sqrt(dot (xlv_TEXCOORD5, xlv_TEXCOORD5)) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0);
  light_5.xyz = (tmpvar_110.xyz + mix (lmIndirect_3, lmFull_4, vec3(tmpvar_113)));
  lowp vec4 c_114;
  mediump vec3 tmpvar_115;
  tmpvar_115 = (tmpvar_6 * light_5.xyz);
  c_114.xyz = tmpvar_115;
  c_114.w = 0.0;
  c_2 = c_114;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;


uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 _ProjectionParams;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_3 * 0.5);
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_4.xy = (tmpvar_6 + tmpvar_5.w);
  o_4.zw = tmpvar_3.zw;
  tmpvar_1.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_1.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_2 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_4;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec3 lmIndirect_3;
  mediump vec3 lmFull_4;
  mediump vec4 light_5;
  lowp vec3 tmpvar_6;
  mediump float vertBlend_7;
  mediump vec4 cb4_8;
  mediump vec4 cb3_9;
  mediump vec4 cb2_10;
  mediump vec4 cb1_11;
  mediump vec4 c4_12;
  mediump vec4 c3_13;
  mediump vec4 c2_14;
  mediump vec4 c1_15;
  mediump float blendBottom_16;
  mediump vec3 blendWeights_17;
  mediump vec2 uv3Alpha_18;
  mediump vec2 uv2Alpha_19;
  mediump vec2 uv1Alpha_20;
  mediump vec2 uv3Blue_21;
  mediump vec2 uv2Blue_22;
  mediump vec2 uv1Blue_23;
  mediump vec2 uv3Green_24;
  mediump vec2 uv2Green_25;
  mediump vec2 uv1Green_26;
  mediump vec2 uv3Red_27;
  mediump vec2 uv2Red_28;
  mediump vec2 uv1Red_29;
  mediump vec2 uv3Sides_30;
  mediump vec2 uv2Sides_31;
  mediump vec2 uv1Sides_32;
  mediump vec2 uv2Top_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingTop / 10.0);
  tmpvar_34.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Top_33 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingSides / 10.0);
  tmpvar_36.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Sides_32 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Sides_31 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Sides_30 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingRed / 10.0);
  tmpvar_40.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Red_29 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Red_28 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Red_27 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingGreen / 10.0);
  tmpvar_44.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Green_26 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Green_25 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Green_24 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingBlue / 10.0);
  tmpvar_48.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Blue_23 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Blue_22 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Blue_21 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52.x = (_TilingAlpha / 10.0);
  tmpvar_52.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_52 * xlv_TEXCOORD0.zy);
  uv1Alpha_20 = tmpvar_53;
  highp vec2 tmpvar_54;
  tmpvar_54 = (tmpvar_52 * xlv_TEXCOORD0.xz);
  uv2Alpha_19 = tmpvar_54;
  highp vec2 tmpvar_55;
  tmpvar_55 = (tmpvar_52 * xlv_TEXCOORD0.xy);
  uv3Alpha_18 = tmpvar_55;
  blendWeights_17.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_56;
  tmpvar_56 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_17.y = tmpvar_56;
  highp float tmpvar_57;
  tmpvar_57 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_16 = tmpvar_57;
  mediump vec3 tmpvar_58;
  tmpvar_58 = clamp (pow ((blendWeights_17 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_59;
  tmpvar_59 = clamp (pow ((blendBottom_16 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_60;
  tmpvar_60 = vec3((1.0/((((tmpvar_58.x + tmpvar_58.y) + tmpvar_58.z) + tmpvar_59))));
  mediump vec3 tmpvar_61;
  tmpvar_61 = (tmpvar_58 * tmpvar_60);
  blendWeights_17 = tmpvar_61;
  mediump float tmpvar_62;
  tmpvar_62 = (tmpvar_59 * tmpvar_60.x);
  blendBottom_16 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv1Sides_32);
  c1_15 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex, uv2Top_33);
  c2_14 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_MainTex2, uv3Sides_30);
  c3_13 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_MainTex2, uv2Sides_31);
  c4_12 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv1Red_29);
  cb1_11 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_28);
  cb2_10 = tmpvar_68;
  lowp vec4 tmpvar_69;
  tmpvar_69 = texture2D (_BlendTex1, uv3Red_27);
  cb3_9 = tmpvar_69;
  lowp vec4 tmpvar_70;
  tmpvar_70 = texture2D (_BlendTex1, uv2Red_28);
  cb4_8 = tmpvar_70;
  highp float tmpvar_71;
  tmpvar_71 = xlv_TEXCOORD2.x;
  vertBlend_7 = tmpvar_71;
  mediump float tmpvar_72;
  tmpvar_72 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c1_15, cb1_11, vec4(tmpvar_72));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c2_14, cb2_10, vec4(tmpvar_72));
  mediump vec4 tmpvar_75;
  tmpvar_75 = mix (c3_13, cb3_9, vec4(tmpvar_72));
  mediump vec4 tmpvar_76;
  tmpvar_76 = mix (c4_12, cb4_8, vec4(tmpvar_72));
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv1Green_26);
  cb1_11 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_25);
  cb2_10 = tmpvar_78;
  lowp vec4 tmpvar_79;
  tmpvar_79 = texture2D (_BlendTex2, uv3Green_24);
  cb3_9 = tmpvar_79;
  lowp vec4 tmpvar_80;
  tmpvar_80 = texture2D (_BlendTex2, uv2Green_25);
  cb4_8 = tmpvar_80;
  highp float tmpvar_81;
  tmpvar_81 = xlv_TEXCOORD2.y;
  vertBlend_7 = tmpvar_81;
  mediump float tmpvar_82;
  tmpvar_82 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb1_11, vec4(tmpvar_82));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb2_10, vec4(tmpvar_82));
  mediump vec4 tmpvar_85;
  tmpvar_85 = mix (tmpvar_75, cb3_9, vec4(tmpvar_82));
  mediump vec4 tmpvar_86;
  tmpvar_86 = mix (tmpvar_76, cb4_8, vec4(tmpvar_82));
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv1Blue_23);
  cb1_11 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_22);
  cb2_10 = tmpvar_88;
  lowp vec4 tmpvar_89;
  tmpvar_89 = texture2D (_BlendTex3, uv3Blue_21);
  cb3_9 = tmpvar_89;
  lowp vec4 tmpvar_90;
  tmpvar_90 = texture2D (_BlendTex3, uv2Blue_22);
  cb4_8 = tmpvar_90;
  highp float tmpvar_91;
  tmpvar_91 = xlv_TEXCOORD2.z;
  vertBlend_7 = tmpvar_91;
  mediump float tmpvar_92;
  tmpvar_92 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb1_11, vec4(tmpvar_92));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb2_10, vec4(tmpvar_92));
  mediump vec4 tmpvar_95;
  tmpvar_95 = mix (tmpvar_85, cb3_9, vec4(tmpvar_92));
  mediump vec4 tmpvar_96;
  tmpvar_96 = mix (tmpvar_86, cb4_8, vec4(tmpvar_92));
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv1Alpha_20);
  cb1_11 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_19);
  cb2_10 = tmpvar_98;
  lowp vec4 tmpvar_99;
  tmpvar_99 = texture2D (_BlendTex4, uv3Alpha_18);
  cb3_9 = tmpvar_99;
  lowp vec4 tmpvar_100;
  tmpvar_100 = texture2D (_BlendTex4, uv2Alpha_19);
  cb4_8 = tmpvar_100;
  highp float tmpvar_101;
  tmpvar_101 = xlv_TEXCOORD2.w;
  vertBlend_7 = tmpvar_101;
  mediump float tmpvar_102;
  tmpvar_102 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb1_11, vec4(tmpvar_102));
  c1_15 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb2_10, vec4(tmpvar_102));
  c2_14 = tmpvar_104;
  mediump vec4 tmpvar_105;
  tmpvar_105 = mix (tmpvar_95, cb3_9, vec4(tmpvar_102));
  c3_13 = tmpvar_105;
  mediump vec4 tmpvar_106;
  tmpvar_106 = mix (tmpvar_96, cb4_8, vec4(tmpvar_102));
  c4_12 = tmpvar_106;
  mediump vec3 tmpvar_107;
  tmpvar_107 = ((((tmpvar_103 * tmpvar_61.x) + (tmpvar_104 * tmpvar_61.y)) + (tmpvar_106 * tmpvar_62)) + (tmpvar_105 * tmpvar_61.z)).xyz;
  highp vec3 tmpvar_108;
  tmpvar_108 = (tmpvar_107 * _Color.xyz);
  tmpvar_6 = tmpvar_108;
  lowp vec4 tmpvar_109;
  tmpvar_109 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_5 = tmpvar_109;
  mediump vec4 tmpvar_110;
  tmpvar_110 = -(log2(max (light_5, vec4(0.001, 0.001, 0.001, 0.001))));
  light_5.w = tmpvar_110.w;
  lowp vec4 tmpvar_111;
  tmpvar_111 = texture2D (unity_Lightmap, xlv_TEXCOORD4);
  lowp vec3 tmpvar_112;
  tmpvar_112 = ((8.0 * tmpvar_111.w) * tmpvar_111.xyz);
  lmFull_4 = tmpvar_112;
  lowp vec4 tmpvar_113;
  tmpvar_113 = texture2D (unity_LightmapInd, xlv_TEXCOORD4);
  lowp vec3 tmpvar_114;
  tmpvar_114 = ((8.0 * tmpvar_113.w) * tmpvar_113.xyz);
  lmIndirect_3 = tmpvar_114;
  highp float tmpvar_115;
  tmpvar_115 = clamp (((sqrt(dot (xlv_TEXCOORD5, xlv_TEXCOORD5)) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0);
  light_5.xyz = (tmpvar_110.xyz + mix (lmIndirect_3, lmFull_4, vec3(tmpvar_115)));
  lowp vec4 c_116;
  mediump vec3 tmpvar_117;
  tmpvar_117 = (tmpvar_6 * light_5.xyz);
  c_116.xyz = tmpvar_117;
  c_116.w = 0.0;
  c_2 = c_116;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_ProjectionParams]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 31 ALU
PARAM c[17] = { { 0.5, 1 },
		state.matrix.mvp,
		program.local[5..16] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R3.xyz, R0, vertex.attrib[14].w;
MOV R1.xyz, c[13];
MOV R1.w, c[0].y;
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R1.xyz, R2, c[15].w, -vertex.position;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R2.xyz, R0.xyww, c[0].x;
MUL R2.y, R2, c[14].x;
DP3 result.texcoord[5].y, R1, R3;
DP3 result.texcoord[5].z, vertex.normal, R1;
DP3 result.texcoord[5].x, R1, vertex.attrib[14];
MUL R1.xyz, vertex.normal, c[15].w;
ADD result.texcoord[3].xy, R2, R2.z;
MOV result.position, R0;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[3].zw, R0;
DP3 result.texcoord[1].z, R1, c[7];
DP3 result.texcoord[1].y, R1, c[6];
DP3 result.texcoord[1].x, R1, c[5];
MAD result.texcoord[4].xy, vertex.texcoord[1], c[16], c[16].zwzw;
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 31 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_ProjectionParams]
Vector 14 [_ScreenParams]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"vs_3_0
; 32 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c17, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord1 v3
dcl_color0 v4
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r3.xyz, r0, v1.w
mov r1.xyz, c12
mov r1.w, c17.y
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r1.xyz, r2, c15.w, -v0
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c17.x
mul r2.y, r2, c13.x
dp3 o6.y, r1, r3
dp3 o6.z, v2, r1
dp3 o6.x, r1, v1
mul r1.xyz, v2, c15.w
mad o4.xy, r2.z, c14.zwzw, r2
mov o0, r0
mov o3, v4
mov o4.zw, r0
dp3 o2.z, r1, c6
dp3 o2.y, r1, c5
dp3 o2.x, r1, c4
mad o5.xy, v3, c16, c16.zwzw
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  highp vec3 tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_8 = tmpvar_1.xyz;
  tmpvar_9 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_10;
  tmpvar_10[0].x = tmpvar_8.x;
  tmpvar_10[0].y = tmpvar_9.x;
  tmpvar_10[0].z = tmpvar_2.x;
  tmpvar_10[1].x = tmpvar_8.y;
  tmpvar_10[1].y = tmpvar_9.y;
  tmpvar_10[1].z = tmpvar_2.y;
  tmpvar_10[2].x = tmpvar_8.z;
  tmpvar_10[2].y = tmpvar_9.z;
  tmpvar_10[2].z = tmpvar_2.z;
  highp vec4 tmpvar_11;
  tmpvar_11.w = 1.0;
  tmpvar_11.xyz = _WorldSpaceCameraPos;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = (tmpvar_10 * (((_World2Object * tmpvar_11).xyz * unity_Scale.w) - _glesVertex.xyz));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  highp vec3 tmpvar_108;
  tmpvar_108 = normalize(xlv_TEXCOORD5);
  mediump vec4 tmpvar_109;
  mediump vec3 viewDir_110;
  viewDir_110 = tmpvar_108;
  highp float nh_111;
  mediump vec3 scalePerBasisVector_112;
  mediump vec3 lm_113;
  lowp vec3 tmpvar_114;
  tmpvar_114 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD4).xyz);
  lm_113 = tmpvar_114;
  lowp vec3 tmpvar_115;
  tmpvar_115 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD4).xyz);
  scalePerBasisVector_112 = tmpvar_115;
  mediump float tmpvar_116;
  tmpvar_116 = max (0.0, normalize((normalize((((scalePerBasisVector_112.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_112.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_112.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_110)).z);
  nh_111 = tmpvar_116;
  highp vec4 tmpvar_117;
  tmpvar_117.xyz = lm_113;
  tmpvar_117.w = pow (nh_111, 0.0);
  tmpvar_109 = tmpvar_117;
  mediump vec4 tmpvar_118;
  tmpvar_118 = (-(log2(max (light_3, vec4(0.001, 0.001, 0.001, 0.001)))) + tmpvar_109);
  light_3 = tmpvar_118;
  lowp vec4 c_119;
  mediump vec3 tmpvar_120;
  tmpvar_120 = (tmpvar_4 * tmpvar_118.xyz);
  c_119.xyz = tmpvar_120;
  c_119.w = 0.0;
  c_2 = c_119;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  highp vec3 tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_8 = tmpvar_1.xyz;
  tmpvar_9 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_10;
  tmpvar_10[0].x = tmpvar_8.x;
  tmpvar_10[0].y = tmpvar_9.x;
  tmpvar_10[0].z = tmpvar_2.x;
  tmpvar_10[1].x = tmpvar_8.y;
  tmpvar_10[1].y = tmpvar_9.y;
  tmpvar_10[1].z = tmpvar_2.y;
  tmpvar_10[2].x = tmpvar_8.z;
  tmpvar_10[2].y = tmpvar_9.z;
  tmpvar_10[2].z = tmpvar_2.z;
  highp vec4 tmpvar_11;
  tmpvar_11.w = 1.0;
  tmpvar_11.xyz = _WorldSpaceCameraPos;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = (tmpvar_10 * (((_World2Object * tmpvar_11).xyz * unity_Scale.w) - _glesVertex.xyz));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  lowp vec4 tmpvar_108;
  tmpvar_108 = texture2D (unity_Lightmap, xlv_TEXCOORD4);
  lowp vec4 tmpvar_109;
  tmpvar_109 = texture2D (unity_LightmapInd, xlv_TEXCOORD4);
  highp vec3 tmpvar_110;
  tmpvar_110 = normalize(xlv_TEXCOORD5);
  mediump vec4 tmpvar_111;
  mediump vec3 viewDir_112;
  viewDir_112 = tmpvar_110;
  highp float nh_113;
  mediump vec3 scalePerBasisVector_114;
  mediump vec3 lm_115;
  lowp vec3 tmpvar_116;
  tmpvar_116 = ((8.0 * tmpvar_108.w) * tmpvar_108.xyz);
  lm_115 = tmpvar_116;
  lowp vec3 tmpvar_117;
  tmpvar_117 = ((8.0 * tmpvar_109.w) * tmpvar_109.xyz);
  scalePerBasisVector_114 = tmpvar_117;
  mediump float tmpvar_118;
  tmpvar_118 = max (0.0, normalize((normalize((((scalePerBasisVector_114.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_114.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_114.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_112)).z);
  nh_113 = tmpvar_118;
  highp vec4 tmpvar_119;
  tmpvar_119.xyz = lm_115;
  tmpvar_119.w = pow (nh_113, 0.0);
  tmpvar_111 = tmpvar_119;
  mediump vec4 tmpvar_120;
  tmpvar_120 = (-(log2(max (light_3, vec4(0.001, 0.001, 0.001, 0.001)))) + tmpvar_111);
  light_3 = tmpvar_120;
  lowp vec4 c_121;
  mediump vec3 tmpvar_122;
  tmpvar_122 = (tmpvar_4 * tmpvar_120.xyz);
  c_121.xyz = tmpvar_122;
  c_121.w = 0.0;
  c_2 = c_121;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Vector 9 [_ProjectionParams]
Vector 10 [unity_SHAr]
Vector 11 [unity_SHAg]
Vector 12 [unity_SHAb]
Vector 13 [unity_SHBr]
Vector 14 [unity_SHBg]
Vector 15 [unity_SHBb]
Vector 16 [unity_SHC]
Matrix 5 [_Object2World]
Vector 17 [unity_Scale]
"3.0-!!ARBvp1.0
# 34 ALU
PARAM c[18] = { { 0.5, 1 },
		state.matrix.mvp,
		program.local[5..17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MUL R1.xyz, vertex.normal, c[17].w;
DP3 R0.zw, R1, c[6];
DP3 R4.x, R1, c[5];
DP3 R4.z, R1, c[7];
MOV R4.y, R0.z;
MUL R1, R4.xyzz, R4.yzzx;
MOV R4.w, c[0].y;
MUL R0.x, R0.z, R0.z;
DP4 R3.z, R1, c[15];
DP4 R3.y, R1, c[14];
DP4 R3.x, R1, c[13];
DP4 R1.w, vertex.position, c[4];
DP4 R1.z, vertex.position, c[3];
DP4 R2.z, R4, c[12];
DP4 R2.y, R4, c[11];
DP4 R2.x, R4, c[10];
MAD R0.x, R4, R4, -R0;
ADD R3.xyz, R2, R3;
MUL R2.xyz, R0.x, c[16];
DP4 R1.x, vertex.position, c[1];
DP4 R1.y, vertex.position, c[2];
MUL R0.xyz, R1.xyww, c[0].x;
MUL R0.y, R0, c[9].x;
ADD result.texcoord[4].xyz, R3, R2;
ADD result.texcoord[3].xy, R0, R0.z;
MOV result.position, R1;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[3].zw, R1;
MOV result.texcoord[1].z, R4;
MOV result.texcoord[1].y, R0.w;
MOV result.texcoord[1].x, R4;
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 34 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Vector 10 [unity_SHAr]
Vector 11 [unity_SHAg]
Vector 12 [unity_SHAb]
Vector 13 [unity_SHBr]
Vector 14 [unity_SHBg]
Vector 15 [unity_SHBb]
Vector 16 [unity_SHC]
Matrix 4 [_Object2World]
Vector 17 [unity_Scale]
"vs_3_0
; 34 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c18, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_color0 v2
mul r1.xyz, v1, c17.w
dp3 r0.zw, r1, c5
dp3 r4.x, r1, c4
dp3 r4.z, r1, c6
mov r4.y, r0.z
mul r1, r4.xyzz, r4.yzzx
mov r4.w, c18.y
mul r0.x, r0.z, r0.z
dp4 r3.z, r1, c15
dp4 r3.y, r1, c14
dp4 r3.x, r1, c13
dp4 r1.w, v0, c3
dp4 r1.z, v0, c2
dp4 r2.z, r4, c12
dp4 r2.y, r4, c11
dp4 r2.x, r4, c10
mad r0.x, r4, r4, -r0
add r3.xyz, r2, r3
mul r2.xyz, r0.x, c16
dp4 r1.x, v0, c0
dp4 r1.y, v0, c1
mul r0.xyz, r1.xyww, c18.x
mul r0.y, r0, c8.x
add o5.xyz, r3, r2
mad o4.xy, r0.z, c9.zwzw, r0
mov o0, r1
mov o3, v2
mov o4.zw, r1
mov o2.z, r4
mov o2.y, r0.w
mov o2.x, r4
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 _ProjectionParams;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 tmpvar_2;
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  mediump vec3 tmpvar_10;
  mediump vec4 normal_11;
  normal_11 = tmpvar_9;
  highp float vC_12;
  mediump vec3 x3_13;
  mediump vec3 x2_14;
  mediump vec3 x1_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAr, normal_11);
  x1_15.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAg, normal_11);
  x1_15.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHAb, normal_11);
  x1_15.z = tmpvar_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = (normal_11.xyzz * normal_11.yzzx);
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBr, tmpvar_19);
  x2_14.x = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBg, tmpvar_19);
  x2_14.y = tmpvar_21;
  highp float tmpvar_22;
  tmpvar_22 = dot (unity_SHBb, tmpvar_19);
  x2_14.z = tmpvar_22;
  mediump float tmpvar_23;
  tmpvar_23 = ((normal_11.x * normal_11.x) - (normal_11.y * normal_11.y));
  vC_12 = tmpvar_23;
  highp vec3 tmpvar_24;
  tmpvar_24 = (unity_SHC.xyz * vC_12);
  x3_13 = tmpvar_24;
  tmpvar_10 = ((x1_15 + x2_14) + x3_13);
  tmpvar_2 = tmpvar_10;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  mediump vec4 tmpvar_108;
  tmpvar_108 = max (light_3, vec4(0.001, 0.001, 0.001, 0.001));
  light_3.w = tmpvar_108.w;
  highp vec3 tmpvar_109;
  tmpvar_109 = (tmpvar_108.xyz + xlv_TEXCOORD4);
  light_3.xyz = tmpvar_109;
  lowp vec4 c_110;
  mediump vec3 tmpvar_111;
  tmpvar_111 = (tmpvar_4 * light_3.xyz);
  c_110.xyz = tmpvar_111;
  c_110.w = 0.0;
  c_2 = c_110;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;

uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAr;
uniform highp vec4 _ProjectionParams;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize(_glesNormal);
  highp vec3 tmpvar_2;
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  mediump vec3 tmpvar_10;
  mediump vec4 normal_11;
  normal_11 = tmpvar_9;
  highp float vC_12;
  mediump vec3 x3_13;
  mediump vec3 x2_14;
  mediump vec3 x1_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHAr, normal_11);
  x1_15.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHAg, normal_11);
  x1_15.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHAb, normal_11);
  x1_15.z = tmpvar_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = (normal_11.xyzz * normal_11.yzzx);
  highp float tmpvar_20;
  tmpvar_20 = dot (unity_SHBr, tmpvar_19);
  x2_14.x = tmpvar_20;
  highp float tmpvar_21;
  tmpvar_21 = dot (unity_SHBg, tmpvar_19);
  x2_14.y = tmpvar_21;
  highp float tmpvar_22;
  tmpvar_22 = dot (unity_SHBb, tmpvar_19);
  x2_14.z = tmpvar_22;
  mediump float tmpvar_23;
  tmpvar_23 = ((normal_11.x * normal_11.x) - (normal_11.y * normal_11.y));
  vC_12 = tmpvar_23;
  highp vec3 tmpvar_24;
  tmpvar_24 = (unity_SHC.xyz * vC_12);
  x3_13 = tmpvar_24;
  tmpvar_10 = ((x1_15 + x2_14) + x3_13);
  tmpvar_2 = tmpvar_10;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_1 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  mediump vec4 tmpvar_108;
  tmpvar_108 = max (light_3, vec4(0.001, 0.001, 0.001, 0.001));
  light_3.w = tmpvar_108.w;
  highp vec3 tmpvar_109;
  tmpvar_109 = (tmpvar_108.xyz + xlv_TEXCOORD4);
  light_3.xyz = tmpvar_109;
  lowp vec4 c_110;
  mediump vec3 tmpvar_111;
  tmpvar_111 = (tmpvar_4 * light_3.xyz);
  c_110.xyz = tmpvar_111;
  c_110.w = 0.0;
  c_2 = c_110;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 13 [_ProjectionParams]
Vector 14 [unity_ShadowFadeCenterAndType]
Matrix 9 [_Object2World]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 25 ALU
PARAM c[17] = { { 0.5, 1 },
		state.matrix.modelview[0],
		state.matrix.mvp,
		program.local[9..16] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[8];
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
MUL R1.xyz, R0.xyww, c[0].x;
MOV result.position, R0;
MUL R1.y, R1, c[13].x;
ADD result.texcoord[3].xy, R1, R1.z;
MUL R1.xyz, vertex.normal, c[15].w;
MOV result.texcoord[3].zw, R0;
DP4 R0.z, vertex.position, c[11];
DP4 R0.x, vertex.position, c[9];
DP4 R0.y, vertex.position, c[10];
MOV result.texcoord[0].xyz, R0;
ADD R0.xyz, R0, -c[14];
MUL result.texcoord[5].xyz, R0, c[14].w;
MOV R0.x, c[0].y;
ADD R0.y, R0.x, -c[14].w;
DP4 R0.x, vertex.position, c[3];
MOV result.texcoord[2], vertex.color;
DP3 result.texcoord[1].z, R1, c[11];
DP3 result.texcoord[1].y, R1, c[10];
DP3 result.texcoord[1].x, R1, c[9];
MAD result.texcoord[4].xy, vertex.texcoord[1], c[16], c[16].zwzw;
MUL result.texcoord[5].w, -R0.x, R0.y;
END
# 25 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_modelview0]
Matrix 4 [glstate_matrix_mvp]
Vector 12 [_ProjectionParams]
Vector 13 [_ScreenParams]
Vector 14 [unity_ShadowFadeCenterAndType]
Matrix 8 [_Object2World]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"vs_3_0
; 25 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c17, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dcl_color0 v3
dp4 r0.w, v0, c7
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mul r1.xyz, r0.xyww, c17.x
mov o0, r0
mul r1.y, r1, c12.x
mad o4.xy, r1.z, c13.zwzw, r1
mul r1.xyz, v1, c15.w
mov o4.zw, r0
dp4 r0.z, v0, c10
dp4 r0.x, v0, c8
dp4 r0.y, v0, c9
mov o1.xyz, r0
add r0.xyz, r0, -c14
mul o6.xyz, r0, c14.w
mov r0.x, c14.w
add r0.y, c17, -r0.x
dp4 r0.x, v0, c2
mov o3, v3
dp3 o2.z, r1, c10
dp3 o2.y, r1, c9
dp3 o2.x, r1, c8
mad o5.xy, v2, c16, c16.zwzw
mul o6.w, -r0.x, r0.y
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;


uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 _ProjectionParams;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_3 * 0.5);
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_4.xy = (tmpvar_6 + tmpvar_5.w);
  o_4.zw = tmpvar_3.zw;
  tmpvar_1.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_1.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_2 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_4;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec3 lmIndirect_3;
  mediump vec3 lmFull_4;
  mediump vec4 light_5;
  lowp vec3 tmpvar_6;
  mediump float vertBlend_7;
  mediump vec4 cb4_8;
  mediump vec4 cb3_9;
  mediump vec4 cb2_10;
  mediump vec4 cb1_11;
  mediump vec4 c4_12;
  mediump vec4 c3_13;
  mediump vec4 c2_14;
  mediump vec4 c1_15;
  mediump float blendBottom_16;
  mediump vec3 blendWeights_17;
  mediump vec2 uv3Alpha_18;
  mediump vec2 uv2Alpha_19;
  mediump vec2 uv1Alpha_20;
  mediump vec2 uv3Blue_21;
  mediump vec2 uv2Blue_22;
  mediump vec2 uv1Blue_23;
  mediump vec2 uv3Green_24;
  mediump vec2 uv2Green_25;
  mediump vec2 uv1Green_26;
  mediump vec2 uv3Red_27;
  mediump vec2 uv2Red_28;
  mediump vec2 uv1Red_29;
  mediump vec2 uv3Sides_30;
  mediump vec2 uv2Sides_31;
  mediump vec2 uv1Sides_32;
  mediump vec2 uv2Top_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingTop / 10.0);
  tmpvar_34.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Top_33 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingSides / 10.0);
  tmpvar_36.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Sides_32 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Sides_31 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Sides_30 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingRed / 10.0);
  tmpvar_40.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Red_29 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Red_28 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Red_27 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingGreen / 10.0);
  tmpvar_44.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Green_26 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Green_25 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Green_24 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingBlue / 10.0);
  tmpvar_48.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Blue_23 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Blue_22 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Blue_21 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52.x = (_TilingAlpha / 10.0);
  tmpvar_52.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_52 * xlv_TEXCOORD0.zy);
  uv1Alpha_20 = tmpvar_53;
  highp vec2 tmpvar_54;
  tmpvar_54 = (tmpvar_52 * xlv_TEXCOORD0.xz);
  uv2Alpha_19 = tmpvar_54;
  highp vec2 tmpvar_55;
  tmpvar_55 = (tmpvar_52 * xlv_TEXCOORD0.xy);
  uv3Alpha_18 = tmpvar_55;
  blendWeights_17.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_56;
  tmpvar_56 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_17.y = tmpvar_56;
  highp float tmpvar_57;
  tmpvar_57 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_16 = tmpvar_57;
  mediump vec3 tmpvar_58;
  tmpvar_58 = clamp (pow ((blendWeights_17 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_59;
  tmpvar_59 = clamp (pow ((blendBottom_16 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_60;
  tmpvar_60 = vec3((1.0/((((tmpvar_58.x + tmpvar_58.y) + tmpvar_58.z) + tmpvar_59))));
  mediump vec3 tmpvar_61;
  tmpvar_61 = (tmpvar_58 * tmpvar_60);
  blendWeights_17 = tmpvar_61;
  mediump float tmpvar_62;
  tmpvar_62 = (tmpvar_59 * tmpvar_60.x);
  blendBottom_16 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv1Sides_32);
  c1_15 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex, uv2Top_33);
  c2_14 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_MainTex2, uv3Sides_30);
  c3_13 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_MainTex2, uv2Sides_31);
  c4_12 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv1Red_29);
  cb1_11 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_28);
  cb2_10 = tmpvar_68;
  lowp vec4 tmpvar_69;
  tmpvar_69 = texture2D (_BlendTex1, uv3Red_27);
  cb3_9 = tmpvar_69;
  lowp vec4 tmpvar_70;
  tmpvar_70 = texture2D (_BlendTex1, uv2Red_28);
  cb4_8 = tmpvar_70;
  highp float tmpvar_71;
  tmpvar_71 = xlv_TEXCOORD2.x;
  vertBlend_7 = tmpvar_71;
  mediump float tmpvar_72;
  tmpvar_72 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c1_15, cb1_11, vec4(tmpvar_72));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c2_14, cb2_10, vec4(tmpvar_72));
  mediump vec4 tmpvar_75;
  tmpvar_75 = mix (c3_13, cb3_9, vec4(tmpvar_72));
  mediump vec4 tmpvar_76;
  tmpvar_76 = mix (c4_12, cb4_8, vec4(tmpvar_72));
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv1Green_26);
  cb1_11 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_25);
  cb2_10 = tmpvar_78;
  lowp vec4 tmpvar_79;
  tmpvar_79 = texture2D (_BlendTex2, uv3Green_24);
  cb3_9 = tmpvar_79;
  lowp vec4 tmpvar_80;
  tmpvar_80 = texture2D (_BlendTex2, uv2Green_25);
  cb4_8 = tmpvar_80;
  highp float tmpvar_81;
  tmpvar_81 = xlv_TEXCOORD2.y;
  vertBlend_7 = tmpvar_81;
  mediump float tmpvar_82;
  tmpvar_82 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb1_11, vec4(tmpvar_82));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb2_10, vec4(tmpvar_82));
  mediump vec4 tmpvar_85;
  tmpvar_85 = mix (tmpvar_75, cb3_9, vec4(tmpvar_82));
  mediump vec4 tmpvar_86;
  tmpvar_86 = mix (tmpvar_76, cb4_8, vec4(tmpvar_82));
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv1Blue_23);
  cb1_11 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_22);
  cb2_10 = tmpvar_88;
  lowp vec4 tmpvar_89;
  tmpvar_89 = texture2D (_BlendTex3, uv3Blue_21);
  cb3_9 = tmpvar_89;
  lowp vec4 tmpvar_90;
  tmpvar_90 = texture2D (_BlendTex3, uv2Blue_22);
  cb4_8 = tmpvar_90;
  highp float tmpvar_91;
  tmpvar_91 = xlv_TEXCOORD2.z;
  vertBlend_7 = tmpvar_91;
  mediump float tmpvar_92;
  tmpvar_92 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb1_11, vec4(tmpvar_92));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb2_10, vec4(tmpvar_92));
  mediump vec4 tmpvar_95;
  tmpvar_95 = mix (tmpvar_85, cb3_9, vec4(tmpvar_92));
  mediump vec4 tmpvar_96;
  tmpvar_96 = mix (tmpvar_86, cb4_8, vec4(tmpvar_92));
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv1Alpha_20);
  cb1_11 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_19);
  cb2_10 = tmpvar_98;
  lowp vec4 tmpvar_99;
  tmpvar_99 = texture2D (_BlendTex4, uv3Alpha_18);
  cb3_9 = tmpvar_99;
  lowp vec4 tmpvar_100;
  tmpvar_100 = texture2D (_BlendTex4, uv2Alpha_19);
  cb4_8 = tmpvar_100;
  highp float tmpvar_101;
  tmpvar_101 = xlv_TEXCOORD2.w;
  vertBlend_7 = tmpvar_101;
  mediump float tmpvar_102;
  tmpvar_102 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb1_11, vec4(tmpvar_102));
  c1_15 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb2_10, vec4(tmpvar_102));
  c2_14 = tmpvar_104;
  mediump vec4 tmpvar_105;
  tmpvar_105 = mix (tmpvar_95, cb3_9, vec4(tmpvar_102));
  c3_13 = tmpvar_105;
  mediump vec4 tmpvar_106;
  tmpvar_106 = mix (tmpvar_96, cb4_8, vec4(tmpvar_102));
  c4_12 = tmpvar_106;
  mediump vec3 tmpvar_107;
  tmpvar_107 = ((((tmpvar_103 * tmpvar_61.x) + (tmpvar_104 * tmpvar_61.y)) + (tmpvar_106 * tmpvar_62)) + (tmpvar_105 * tmpvar_61.z)).xyz;
  highp vec3 tmpvar_108;
  tmpvar_108 = (tmpvar_107 * _Color.xyz);
  tmpvar_6 = tmpvar_108;
  lowp vec4 tmpvar_109;
  tmpvar_109 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_5 = tmpvar_109;
  mediump vec4 tmpvar_110;
  tmpvar_110 = max (light_5, vec4(0.001, 0.001, 0.001, 0.001));
  light_5.w = tmpvar_110.w;
  lowp vec3 tmpvar_111;
  tmpvar_111 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD4).xyz);
  lmFull_4 = tmpvar_111;
  lowp vec3 tmpvar_112;
  tmpvar_112 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD4).xyz);
  lmIndirect_3 = tmpvar_112;
  highp float tmpvar_113;
  tmpvar_113 = clamp (((sqrt(dot (xlv_TEXCOORD5, xlv_TEXCOORD5)) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0);
  light_5.xyz = (tmpvar_110.xyz + mix (lmIndirect_3, lmFull_4, vec3(tmpvar_113)));
  lowp vec4 c_114;
  mediump vec3 tmpvar_115;
  tmpvar_115 = (tmpvar_6 * light_5.xyz);
  c_114.xyz = tmpvar_115;
  c_114.w = 0.0;
  c_2 = c_114;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;


uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 _ProjectionParams;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_3 * 0.5);
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_4.xy = (tmpvar_6 + tmpvar_5.w);
  o_4.zw = tmpvar_3.zw;
  tmpvar_1.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_1.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_2 * (normalize(_glesNormal) * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_4;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec3 lmIndirect_3;
  mediump vec3 lmFull_4;
  mediump vec4 light_5;
  lowp vec3 tmpvar_6;
  mediump float vertBlend_7;
  mediump vec4 cb4_8;
  mediump vec4 cb3_9;
  mediump vec4 cb2_10;
  mediump vec4 cb1_11;
  mediump vec4 c4_12;
  mediump vec4 c3_13;
  mediump vec4 c2_14;
  mediump vec4 c1_15;
  mediump float blendBottom_16;
  mediump vec3 blendWeights_17;
  mediump vec2 uv3Alpha_18;
  mediump vec2 uv2Alpha_19;
  mediump vec2 uv1Alpha_20;
  mediump vec2 uv3Blue_21;
  mediump vec2 uv2Blue_22;
  mediump vec2 uv1Blue_23;
  mediump vec2 uv3Green_24;
  mediump vec2 uv2Green_25;
  mediump vec2 uv1Green_26;
  mediump vec2 uv3Red_27;
  mediump vec2 uv2Red_28;
  mediump vec2 uv1Red_29;
  mediump vec2 uv3Sides_30;
  mediump vec2 uv2Sides_31;
  mediump vec2 uv1Sides_32;
  mediump vec2 uv2Top_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingTop / 10.0);
  tmpvar_34.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Top_33 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36.x = (_TilingSides / 10.0);
  tmpvar_36.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_36 * xlv_TEXCOORD0.zy);
  uv1Sides_32 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38 = (tmpvar_36 * xlv_TEXCOORD0.xz);
  uv2Sides_31 = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_36 * xlv_TEXCOORD0.xy);
  uv3Sides_30 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (_TilingRed / 10.0);
  tmpvar_40.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_40 * xlv_TEXCOORD0.zy);
  uv1Red_29 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42 = (tmpvar_40 * xlv_TEXCOORD0.xz);
  uv2Red_28 = tmpvar_42;
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_40 * xlv_TEXCOORD0.xy);
  uv3Red_27 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44.x = (_TilingGreen / 10.0);
  tmpvar_44.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_44 * xlv_TEXCOORD0.zy);
  uv1Green_26 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46 = (tmpvar_44 * xlv_TEXCOORD0.xz);
  uv2Green_25 = tmpvar_46;
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_44 * xlv_TEXCOORD0.xy);
  uv3Green_24 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48.x = (_TilingBlue / 10.0);
  tmpvar_48.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_48 * xlv_TEXCOORD0.zy);
  uv1Blue_23 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = (tmpvar_48 * xlv_TEXCOORD0.xz);
  uv2Blue_22 = tmpvar_50;
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_48 * xlv_TEXCOORD0.xy);
  uv3Blue_21 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52.x = (_TilingAlpha / 10.0);
  tmpvar_52.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_52 * xlv_TEXCOORD0.zy);
  uv1Alpha_20 = tmpvar_53;
  highp vec2 tmpvar_54;
  tmpvar_54 = (tmpvar_52 * xlv_TEXCOORD0.xz);
  uv2Alpha_19 = tmpvar_54;
  highp vec2 tmpvar_55;
  tmpvar_55 = (tmpvar_52 * xlv_TEXCOORD0.xy);
  uv3Alpha_18 = tmpvar_55;
  blendWeights_17.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_56;
  tmpvar_56 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_17.y = tmpvar_56;
  highp float tmpvar_57;
  tmpvar_57 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_16 = tmpvar_57;
  mediump vec3 tmpvar_58;
  tmpvar_58 = clamp (pow ((blendWeights_17 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_59;
  tmpvar_59 = clamp (pow ((blendBottom_16 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_60;
  tmpvar_60 = vec3((1.0/((((tmpvar_58.x + tmpvar_58.y) + tmpvar_58.z) + tmpvar_59))));
  mediump vec3 tmpvar_61;
  tmpvar_61 = (tmpvar_58 * tmpvar_60);
  blendWeights_17 = tmpvar_61;
  mediump float tmpvar_62;
  tmpvar_62 = (tmpvar_59 * tmpvar_60.x);
  blendBottom_16 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv1Sides_32);
  c1_15 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex, uv2Top_33);
  c2_14 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_MainTex2, uv3Sides_30);
  c3_13 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_MainTex2, uv2Sides_31);
  c4_12 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv1Red_29);
  cb1_11 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_28);
  cb2_10 = tmpvar_68;
  lowp vec4 tmpvar_69;
  tmpvar_69 = texture2D (_BlendTex1, uv3Red_27);
  cb3_9 = tmpvar_69;
  lowp vec4 tmpvar_70;
  tmpvar_70 = texture2D (_BlendTex1, uv2Red_28);
  cb4_8 = tmpvar_70;
  highp float tmpvar_71;
  tmpvar_71 = xlv_TEXCOORD2.x;
  vertBlend_7 = tmpvar_71;
  mediump float tmpvar_72;
  tmpvar_72 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c1_15, cb1_11, vec4(tmpvar_72));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c2_14, cb2_10, vec4(tmpvar_72));
  mediump vec4 tmpvar_75;
  tmpvar_75 = mix (c3_13, cb3_9, vec4(tmpvar_72));
  mediump vec4 tmpvar_76;
  tmpvar_76 = mix (c4_12, cb4_8, vec4(tmpvar_72));
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv1Green_26);
  cb1_11 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_25);
  cb2_10 = tmpvar_78;
  lowp vec4 tmpvar_79;
  tmpvar_79 = texture2D (_BlendTex2, uv3Green_24);
  cb3_9 = tmpvar_79;
  lowp vec4 tmpvar_80;
  tmpvar_80 = texture2D (_BlendTex2, uv2Green_25);
  cb4_8 = tmpvar_80;
  highp float tmpvar_81;
  tmpvar_81 = xlv_TEXCOORD2.y;
  vertBlend_7 = tmpvar_81;
  mediump float tmpvar_82;
  tmpvar_82 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb1_11, vec4(tmpvar_82));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb2_10, vec4(tmpvar_82));
  mediump vec4 tmpvar_85;
  tmpvar_85 = mix (tmpvar_75, cb3_9, vec4(tmpvar_82));
  mediump vec4 tmpvar_86;
  tmpvar_86 = mix (tmpvar_76, cb4_8, vec4(tmpvar_82));
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv1Blue_23);
  cb1_11 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_22);
  cb2_10 = tmpvar_88;
  lowp vec4 tmpvar_89;
  tmpvar_89 = texture2D (_BlendTex3, uv3Blue_21);
  cb3_9 = tmpvar_89;
  lowp vec4 tmpvar_90;
  tmpvar_90 = texture2D (_BlendTex3, uv2Blue_22);
  cb4_8 = tmpvar_90;
  highp float tmpvar_91;
  tmpvar_91 = xlv_TEXCOORD2.z;
  vertBlend_7 = tmpvar_91;
  mediump float tmpvar_92;
  tmpvar_92 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb1_11, vec4(tmpvar_92));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb2_10, vec4(tmpvar_92));
  mediump vec4 tmpvar_95;
  tmpvar_95 = mix (tmpvar_85, cb3_9, vec4(tmpvar_92));
  mediump vec4 tmpvar_96;
  tmpvar_96 = mix (tmpvar_86, cb4_8, vec4(tmpvar_92));
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv1Alpha_20);
  cb1_11 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_19);
  cb2_10 = tmpvar_98;
  lowp vec4 tmpvar_99;
  tmpvar_99 = texture2D (_BlendTex4, uv3Alpha_18);
  cb3_9 = tmpvar_99;
  lowp vec4 tmpvar_100;
  tmpvar_100 = texture2D (_BlendTex4, uv2Alpha_19);
  cb4_8 = tmpvar_100;
  highp float tmpvar_101;
  tmpvar_101 = xlv_TEXCOORD2.w;
  vertBlend_7 = tmpvar_101;
  mediump float tmpvar_102;
  tmpvar_102 = clamp (pow ((1.5 * vertBlend_7), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb1_11, vec4(tmpvar_102));
  c1_15 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb2_10, vec4(tmpvar_102));
  c2_14 = tmpvar_104;
  mediump vec4 tmpvar_105;
  tmpvar_105 = mix (tmpvar_95, cb3_9, vec4(tmpvar_102));
  c3_13 = tmpvar_105;
  mediump vec4 tmpvar_106;
  tmpvar_106 = mix (tmpvar_96, cb4_8, vec4(tmpvar_102));
  c4_12 = tmpvar_106;
  mediump vec3 tmpvar_107;
  tmpvar_107 = ((((tmpvar_103 * tmpvar_61.x) + (tmpvar_104 * tmpvar_61.y)) + (tmpvar_106 * tmpvar_62)) + (tmpvar_105 * tmpvar_61.z)).xyz;
  highp vec3 tmpvar_108;
  tmpvar_108 = (tmpvar_107 * _Color.xyz);
  tmpvar_6 = tmpvar_108;
  lowp vec4 tmpvar_109;
  tmpvar_109 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_5 = tmpvar_109;
  mediump vec4 tmpvar_110;
  tmpvar_110 = max (light_5, vec4(0.001, 0.001, 0.001, 0.001));
  light_5.w = tmpvar_110.w;
  lowp vec4 tmpvar_111;
  tmpvar_111 = texture2D (unity_Lightmap, xlv_TEXCOORD4);
  lowp vec3 tmpvar_112;
  tmpvar_112 = ((8.0 * tmpvar_111.w) * tmpvar_111.xyz);
  lmFull_4 = tmpvar_112;
  lowp vec4 tmpvar_113;
  tmpvar_113 = texture2D (unity_LightmapInd, xlv_TEXCOORD4);
  lowp vec3 tmpvar_114;
  tmpvar_114 = ((8.0 * tmpvar_113.w) * tmpvar_113.xyz);
  lmIndirect_3 = tmpvar_114;
  highp float tmpvar_115;
  tmpvar_115 = clamp (((sqrt(dot (xlv_TEXCOORD5, xlv_TEXCOORD5)) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0);
  light_5.xyz = (tmpvar_110.xyz + mix (lmIndirect_3, lmFull_4, vec3(tmpvar_115)));
  lowp vec4 c_116;
  mediump vec3 tmpvar_117;
  tmpvar_117 = (tmpvar_6 * light_5.xyz);
  c_116.xyz = tmpvar_117;
  c_116.w = 0.0;
  c_2 = c_116;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_ProjectionParams]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 31 ALU
PARAM c[17] = { { 0.5, 1 },
		state.matrix.mvp,
		program.local[5..16] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R3.xyz, R0, vertex.attrib[14].w;
MOV R1.xyz, c[13];
MOV R1.w, c[0].y;
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R1.xyz, R2, c[15].w, -vertex.position;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R2.xyz, R0.xyww, c[0].x;
MUL R2.y, R2, c[14].x;
DP3 result.texcoord[5].y, R1, R3;
DP3 result.texcoord[5].z, vertex.normal, R1;
DP3 result.texcoord[5].x, R1, vertex.attrib[14];
MUL R1.xyz, vertex.normal, c[15].w;
ADD result.texcoord[3].xy, R2, R2.z;
MOV result.position, R0;
MOV result.texcoord[2], vertex.color;
MOV result.texcoord[3].zw, R0;
DP3 result.texcoord[1].z, R1, c[7];
DP3 result.texcoord[1].y, R1, c[6];
DP3 result.texcoord[1].x, R1, c[5];
MAD result.texcoord[4].xy, vertex.texcoord[1], c[16], c[16].zwzw;
DP4 result.texcoord[0].z, vertex.position, c[7];
DP4 result.texcoord[0].y, vertex.position, c[6];
DP4 result.texcoord[0].x, vertex.position, c[5];
END
# 31 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Vector 13 [_ProjectionParams]
Vector 14 [_ScreenParams]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 15 [unity_Scale]
Vector 16 [unity_LightmapST]
"vs_3_0
; 32 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c17, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord1 v3
dcl_color0 v4
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r3.xyz, r0, v1.w
mov r1.xyz, c12
mov r1.w, c17.y
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r1.xyz, r2, c15.w, -v0
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c17.x
mul r2.y, r2, c13.x
dp3 o6.y, r1, r3
dp3 o6.z, v2, r1
dp3 o6.x, r1, v1
mul r1.xyz, v2, c15.w
mad o4.xy, r2.z, c14.zwzw, r2
mov o0, r0
mov o3, v4
mov o4.zw, r0
dp3 o2.z, r1, c6
dp3 o2.y, r1, c5
dp3 o2.x, r1, c4
mad o5.xy, v3, c16, c16.zwzw
dp4 o1.z, v0, c6
dp4 o1.y, v0, c5
dp4 o1.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  highp vec3 tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_8 = tmpvar_1.xyz;
  tmpvar_9 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_10;
  tmpvar_10[0].x = tmpvar_8.x;
  tmpvar_10[0].y = tmpvar_9.x;
  tmpvar_10[0].z = tmpvar_2.x;
  tmpvar_10[1].x = tmpvar_8.y;
  tmpvar_10[1].y = tmpvar_9.y;
  tmpvar_10[1].z = tmpvar_2.y;
  tmpvar_10[2].x = tmpvar_8.z;
  tmpvar_10[2].y = tmpvar_9.z;
  tmpvar_10[2].z = tmpvar_2.z;
  highp vec4 tmpvar_11;
  tmpvar_11.w = 1.0;
  tmpvar_11.xyz = _WorldSpaceCameraPos;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = (tmpvar_10 * (((_World2Object * tmpvar_11).xyz * unity_Scale.w) - _glesVertex.xyz));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  highp vec3 tmpvar_108;
  tmpvar_108 = normalize(xlv_TEXCOORD5);
  mediump vec4 tmpvar_109;
  mediump vec3 viewDir_110;
  viewDir_110 = tmpvar_108;
  highp float nh_111;
  mediump vec3 scalePerBasisVector_112;
  mediump vec3 lm_113;
  lowp vec3 tmpvar_114;
  tmpvar_114 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD4).xyz);
  lm_113 = tmpvar_114;
  lowp vec3 tmpvar_115;
  tmpvar_115 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD4).xyz);
  scalePerBasisVector_112 = tmpvar_115;
  mediump float tmpvar_116;
  tmpvar_116 = max (0.0, normalize((normalize((((scalePerBasisVector_112.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_112.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_112.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_110)).z);
  nh_111 = tmpvar_116;
  highp vec4 tmpvar_117;
  tmpvar_117.xyz = lm_113;
  tmpvar_117.w = pow (nh_111, 0.0);
  tmpvar_109 = tmpvar_117;
  mediump vec4 tmpvar_118;
  tmpvar_118 = (max (light_3, vec4(0.001, 0.001, 0.001, 0.001)) + tmpvar_109);
  light_3 = tmpvar_118;
  lowp vec4 c_119;
  mediump vec3 tmpvar_120;
  tmpvar_120 = (tmpvar_4 * tmpvar_118.xyz);
  c_119.xyz = tmpvar_120;
  c_119.w = 0.0;
  c_2 = c_119;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;

uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec4 tmpvar_4;
  tmpvar_4 = (gl_ModelViewProjectionMatrix * _glesVertex);
  highp vec4 o_5;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_4 * 0.5);
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_5.xy = (tmpvar_7 + tmpvar_6.w);
  o_5.zw = tmpvar_4.zw;
  highp vec3 tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_8 = tmpvar_1.xyz;
  tmpvar_9 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_10;
  tmpvar_10[0].x = tmpvar_8.x;
  tmpvar_10[0].y = tmpvar_9.x;
  tmpvar_10[0].z = tmpvar_2.x;
  tmpvar_10[1].x = tmpvar_8.y;
  tmpvar_10[1].y = tmpvar_9.y;
  tmpvar_10[1].z = tmpvar_2.y;
  tmpvar_10[2].x = tmpvar_8.z;
  tmpvar_10[2].y = tmpvar_9.z;
  tmpvar_10[2].z = tmpvar_2.z;
  highp vec4 tmpvar_11;
  tmpvar_11.w = 1.0;
  tmpvar_11.xyz = _WorldSpaceCameraPos;
  gl_Position = tmpvar_4;
  xlv_TEXCOORD0 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD1 = (tmpvar_3 * (tmpvar_2 * unity_Scale.w));
  xlv_TEXCOORD2 = _glesColor;
  xlv_TEXCOORD3 = o_5;
  xlv_TEXCOORD4 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD5 = (tmpvar_10 * (((_World2Object * tmpvar_11).xyz * unity_Scale.w) - _glesVertex.xyz));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD5;
varying highp vec2 xlv_TEXCOORD4;
varying highp vec4 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform sampler2D unity_Lightmap;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _TilingAlpha;
uniform highp float _TilingBlue;
uniform highp float _TilingGreen;
uniform highp float _TilingRed;
uniform highp float _TilingSides;
uniform highp float _TilingTop;
uniform sampler2D _BlendTex4;
uniform sampler2D _BlendTex3;
uniform sampler2D _BlendTex2;
uniform sampler2D _BlendTex1;
uniform sampler2D _MainTex2;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c_2;
  mediump vec4 light_3;
  lowp vec3 tmpvar_4;
  mediump float vertBlend_5;
  mediump vec4 cb4_6;
  mediump vec4 cb3_7;
  mediump vec4 cb2_8;
  mediump vec4 cb1_9;
  mediump vec4 c4_10;
  mediump vec4 c3_11;
  mediump vec4 c2_12;
  mediump vec4 c1_13;
  mediump float blendBottom_14;
  mediump vec3 blendWeights_15;
  mediump vec2 uv3Alpha_16;
  mediump vec2 uv2Alpha_17;
  mediump vec2 uv1Alpha_18;
  mediump vec2 uv3Blue_19;
  mediump vec2 uv2Blue_20;
  mediump vec2 uv1Blue_21;
  mediump vec2 uv3Green_22;
  mediump vec2 uv2Green_23;
  mediump vec2 uv1Green_24;
  mediump vec2 uv3Red_25;
  mediump vec2 uv2Red_26;
  mediump vec2 uv1Red_27;
  mediump vec2 uv3Sides_28;
  mediump vec2 uv2Sides_29;
  mediump vec2 uv1Sides_30;
  mediump vec2 uv2Top_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (_TilingTop / 10.0);
  tmpvar_32.y = (_TilingTop / 10.0);
  highp vec2 tmpvar_33;
  tmpvar_33 = (tmpvar_32 * xlv_TEXCOORD0.xz);
  uv2Top_31 = tmpvar_33;
  highp vec2 tmpvar_34;
  tmpvar_34.x = (_TilingSides / 10.0);
  tmpvar_34.y = (_TilingSides / 10.0);
  highp vec2 tmpvar_35;
  tmpvar_35 = (tmpvar_34 * xlv_TEXCOORD0.zy);
  uv1Sides_30 = tmpvar_35;
  highp vec2 tmpvar_36;
  tmpvar_36 = (tmpvar_34 * xlv_TEXCOORD0.xz);
  uv2Sides_29 = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37 = (tmpvar_34 * xlv_TEXCOORD0.xy);
  uv3Sides_28 = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (_TilingRed / 10.0);
  tmpvar_38.y = (_TilingRed / 10.0);
  highp vec2 tmpvar_39;
  tmpvar_39 = (tmpvar_38 * xlv_TEXCOORD0.zy);
  uv1Red_27 = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40 = (tmpvar_38 * xlv_TEXCOORD0.xz);
  uv2Red_26 = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41 = (tmpvar_38 * xlv_TEXCOORD0.xy);
  uv3Red_25 = tmpvar_41;
  highp vec2 tmpvar_42;
  tmpvar_42.x = (_TilingGreen / 10.0);
  tmpvar_42.y = (_TilingGreen / 10.0);
  highp vec2 tmpvar_43;
  tmpvar_43 = (tmpvar_42 * xlv_TEXCOORD0.zy);
  uv1Green_24 = tmpvar_43;
  highp vec2 tmpvar_44;
  tmpvar_44 = (tmpvar_42 * xlv_TEXCOORD0.xz);
  uv2Green_23 = tmpvar_44;
  highp vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_42 * xlv_TEXCOORD0.xy);
  uv3Green_22 = tmpvar_45;
  highp vec2 tmpvar_46;
  tmpvar_46.x = (_TilingBlue / 10.0);
  tmpvar_46.y = (_TilingBlue / 10.0);
  highp vec2 tmpvar_47;
  tmpvar_47 = (tmpvar_46 * xlv_TEXCOORD0.zy);
  uv1Blue_21 = tmpvar_47;
  highp vec2 tmpvar_48;
  tmpvar_48 = (tmpvar_46 * xlv_TEXCOORD0.xz);
  uv2Blue_20 = tmpvar_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = (tmpvar_46 * xlv_TEXCOORD0.xy);
  uv3Blue_19 = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50.x = (_TilingAlpha / 10.0);
  tmpvar_50.y = (_TilingAlpha / 10.0);
  highp vec2 tmpvar_51;
  tmpvar_51 = (tmpvar_50 * xlv_TEXCOORD0.zy);
  uv1Alpha_18 = tmpvar_51;
  highp vec2 tmpvar_52;
  tmpvar_52 = (tmpvar_50 * xlv_TEXCOORD0.xz);
  uv2Alpha_17 = tmpvar_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = (tmpvar_50 * xlv_TEXCOORD0.xy);
  uv3Alpha_16 = tmpvar_53;
  blendWeights_15.xz = xlv_TEXCOORD1.xz;
  highp float tmpvar_54;
  tmpvar_54 = max (xlv_TEXCOORD1.y, 0.0);
  blendWeights_15.y = tmpvar_54;
  highp float tmpvar_55;
  tmpvar_55 = min (xlv_TEXCOORD1.y, 0.0);
  blendBottom_14 = tmpvar_55;
  mediump vec3 tmpvar_56;
  tmpvar_56 = clamp (pow ((blendWeights_15 * 0.25), vec3(5.0, 5.0, 5.0)), 0.0, 1.0);
  mediump float tmpvar_57;
  tmpvar_57 = clamp (pow ((blendBottom_14 * 0.25), 5.0), 0.0, 1.0);
  mediump vec3 tmpvar_58;
  tmpvar_58 = vec3((1.0/((((tmpvar_56.x + tmpvar_56.y) + tmpvar_56.z) + tmpvar_57))));
  mediump vec3 tmpvar_59;
  tmpvar_59 = (tmpvar_56 * tmpvar_58);
  blendWeights_15 = tmpvar_59;
  mediump float tmpvar_60;
  tmpvar_60 = (tmpvar_57 * tmpvar_58.x);
  blendBottom_14 = tmpvar_60;
  lowp vec4 tmpvar_61;
  tmpvar_61 = texture2D (_MainTex2, uv1Sides_30);
  c1_13 = tmpvar_61;
  lowp vec4 tmpvar_62;
  tmpvar_62 = texture2D (_MainTex, uv2Top_31);
  c2_12 = tmpvar_62;
  lowp vec4 tmpvar_63;
  tmpvar_63 = texture2D (_MainTex2, uv3Sides_28);
  c3_11 = tmpvar_63;
  lowp vec4 tmpvar_64;
  tmpvar_64 = texture2D (_MainTex2, uv2Sides_29);
  c4_10 = tmpvar_64;
  lowp vec4 tmpvar_65;
  tmpvar_65 = texture2D (_BlendTex1, uv1Red_27);
  cb1_9 = tmpvar_65;
  lowp vec4 tmpvar_66;
  tmpvar_66 = texture2D (_BlendTex1, uv2Red_26);
  cb2_8 = tmpvar_66;
  lowp vec4 tmpvar_67;
  tmpvar_67 = texture2D (_BlendTex1, uv3Red_25);
  cb3_7 = tmpvar_67;
  lowp vec4 tmpvar_68;
  tmpvar_68 = texture2D (_BlendTex1, uv2Red_26);
  cb4_6 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = xlv_TEXCOORD2.x;
  vertBlend_5 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_71;
  tmpvar_71 = mix (c1_13, cb1_9, vec4(tmpvar_70));
  mediump vec4 tmpvar_72;
  tmpvar_72 = mix (c2_12, cb2_8, vec4(tmpvar_70));
  mediump vec4 tmpvar_73;
  tmpvar_73 = mix (c3_11, cb3_7, vec4(tmpvar_70));
  mediump vec4 tmpvar_74;
  tmpvar_74 = mix (c4_10, cb4_6, vec4(tmpvar_70));
  lowp vec4 tmpvar_75;
  tmpvar_75 = texture2D (_BlendTex2, uv1Green_24);
  cb1_9 = tmpvar_75;
  lowp vec4 tmpvar_76;
  tmpvar_76 = texture2D (_BlendTex2, uv2Green_23);
  cb2_8 = tmpvar_76;
  lowp vec4 tmpvar_77;
  tmpvar_77 = texture2D (_BlendTex2, uv3Green_22);
  cb3_7 = tmpvar_77;
  lowp vec4 tmpvar_78;
  tmpvar_78 = texture2D (_BlendTex2, uv2Green_23);
  cb4_6 = tmpvar_78;
  highp float tmpvar_79;
  tmpvar_79 = xlv_TEXCOORD2.y;
  vertBlend_5 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_81;
  tmpvar_81 = mix (tmpvar_71, cb1_9, vec4(tmpvar_80));
  mediump vec4 tmpvar_82;
  tmpvar_82 = mix (tmpvar_72, cb2_8, vec4(tmpvar_80));
  mediump vec4 tmpvar_83;
  tmpvar_83 = mix (tmpvar_73, cb3_7, vec4(tmpvar_80));
  mediump vec4 tmpvar_84;
  tmpvar_84 = mix (tmpvar_74, cb4_6, vec4(tmpvar_80));
  lowp vec4 tmpvar_85;
  tmpvar_85 = texture2D (_BlendTex3, uv1Blue_21);
  cb1_9 = tmpvar_85;
  lowp vec4 tmpvar_86;
  tmpvar_86 = texture2D (_BlendTex3, uv2Blue_20);
  cb2_8 = tmpvar_86;
  lowp vec4 tmpvar_87;
  tmpvar_87 = texture2D (_BlendTex3, uv3Blue_19);
  cb3_7 = tmpvar_87;
  lowp vec4 tmpvar_88;
  tmpvar_88 = texture2D (_BlendTex3, uv2Blue_20);
  cb4_6 = tmpvar_88;
  highp float tmpvar_89;
  tmpvar_89 = xlv_TEXCOORD2.z;
  vertBlend_5 = tmpvar_89;
  mediump float tmpvar_90;
  tmpvar_90 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_91;
  tmpvar_91 = mix (tmpvar_81, cb1_9, vec4(tmpvar_90));
  mediump vec4 tmpvar_92;
  tmpvar_92 = mix (tmpvar_82, cb2_8, vec4(tmpvar_90));
  mediump vec4 tmpvar_93;
  tmpvar_93 = mix (tmpvar_83, cb3_7, vec4(tmpvar_90));
  mediump vec4 tmpvar_94;
  tmpvar_94 = mix (tmpvar_84, cb4_6, vec4(tmpvar_90));
  lowp vec4 tmpvar_95;
  tmpvar_95 = texture2D (_BlendTex4, uv1Alpha_18);
  cb1_9 = tmpvar_95;
  lowp vec4 tmpvar_96;
  tmpvar_96 = texture2D (_BlendTex4, uv2Alpha_17);
  cb2_8 = tmpvar_96;
  lowp vec4 tmpvar_97;
  tmpvar_97 = texture2D (_BlendTex4, uv3Alpha_16);
  cb3_7 = tmpvar_97;
  lowp vec4 tmpvar_98;
  tmpvar_98 = texture2D (_BlendTex4, uv2Alpha_17);
  cb4_6 = tmpvar_98;
  highp float tmpvar_99;
  tmpvar_99 = xlv_TEXCOORD2.w;
  vertBlend_5 = tmpvar_99;
  mediump float tmpvar_100;
  tmpvar_100 = clamp (pow ((1.5 * vertBlend_5), 1.5), 0.0, 1.0);
  mediump vec4 tmpvar_101;
  tmpvar_101 = mix (tmpvar_91, cb1_9, vec4(tmpvar_100));
  c1_13 = tmpvar_101;
  mediump vec4 tmpvar_102;
  tmpvar_102 = mix (tmpvar_92, cb2_8, vec4(tmpvar_100));
  c2_12 = tmpvar_102;
  mediump vec4 tmpvar_103;
  tmpvar_103 = mix (tmpvar_93, cb3_7, vec4(tmpvar_100));
  c3_11 = tmpvar_103;
  mediump vec4 tmpvar_104;
  tmpvar_104 = mix (tmpvar_94, cb4_6, vec4(tmpvar_100));
  c4_10 = tmpvar_104;
  mediump vec3 tmpvar_105;
  tmpvar_105 = ((((tmpvar_101 * tmpvar_59.x) + (tmpvar_102 * tmpvar_59.y)) + (tmpvar_104 * tmpvar_60)) + (tmpvar_103 * tmpvar_59.z)).xyz;
  highp vec3 tmpvar_106;
  tmpvar_106 = (tmpvar_105 * _Color.xyz);
  tmpvar_4 = tmpvar_106;
  lowp vec4 tmpvar_107;
  tmpvar_107 = texture2DProj (_LightBuffer, xlv_TEXCOORD3);
  light_3 = tmpvar_107;
  lowp vec4 tmpvar_108;
  tmpvar_108 = texture2D (unity_Lightmap, xlv_TEXCOORD4);
  lowp vec4 tmpvar_109;
  tmpvar_109 = texture2D (unity_LightmapInd, xlv_TEXCOORD4);
  highp vec3 tmpvar_110;
  tmpvar_110 = normalize(xlv_TEXCOORD5);
  mediump vec4 tmpvar_111;
  mediump vec3 viewDir_112;
  viewDir_112 = tmpvar_110;
  highp float nh_113;
  mediump vec3 scalePerBasisVector_114;
  mediump vec3 lm_115;
  lowp vec3 tmpvar_116;
  tmpvar_116 = ((8.0 * tmpvar_108.w) * tmpvar_108.xyz);
  lm_115 = tmpvar_116;
  lowp vec3 tmpvar_117;
  tmpvar_117 = ((8.0 * tmpvar_109.w) * tmpvar_109.xyz);
  scalePerBasisVector_114 = tmpvar_117;
  mediump float tmpvar_118;
  tmpvar_118 = max (0.0, normalize((normalize((((scalePerBasisVector_114.x * vec3(0.816497, 0.0, 0.57735)) + (scalePerBasisVector_114.y * vec3(-0.408248, 0.707107, 0.57735))) + (scalePerBasisVector_114.z * vec3(-0.408248, -0.707107, 0.57735)))) + viewDir_112)).z);
  nh_113 = tmpvar_118;
  highp vec4 tmpvar_119;
  tmpvar_119.xyz = lm_115;
  tmpvar_119.w = pow (nh_113, 0.0);
  tmpvar_111 = tmpvar_119;
  mediump vec4 tmpvar_120;
  tmpvar_120 = (max (light_3, vec4(0.001, 0.001, 0.001, 0.001)) + tmpvar_111);
  light_3 = tmpvar_120;
  lowp vec4 c_121;
  mediump vec3 tmpvar_122;
  tmpvar_122 = (tmpvar_4 * tmpvar_120.xyz);
  c_121.xyz = tmpvar_122;
  c_121.w = 0.0;
  c_2 = c_121;
  tmpvar_1 = c_2;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 6
//   opengl - ALU: 108 to 122, TEX: 17 to 19
//   d3d9 - ALU: 115 to 127, TEX: 17 to 19
SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 111 ALU, 17 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
ADD R1.xyz, R1, -R4;
MAD R3.xyz, R0.w, R1, R4;
TXP R1.xyz, fragment.texcoord[3], texture[6], 2D;
MAD R2.xyz, R3, R2.z, R0;
LG2 R0.x, R1.x;
LG2 R0.z, R1.z;
LG2 R0.y, R1.y;
ADD R1.xyz, -R0, fragment.texcoord[4];
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[7].x;
END
# 111 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
"ps_3_0
; 118 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 0, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3
dcl_texcoord4 v4.xyz
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mul_pp r0.w, r2, r0
mad_pp r3.xyz, r0, r0.w, r3
texldp r0.xyz, v3, s6
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r1.xyz, r1.w, r4, r1
mad_pp r1.xyz, r1, r2.z, r3
log_pp r0.x, r0.x
log_pp r0.z, r0.z
log_pp r0.y, r0.y
add_pp r2.xyz, -r0, v4
mul r0.xyz, r1, c6
mul_pp oC0.xyz, r0, r2
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
Vector 7 [unity_LightmapFade]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
SetTexture 8 [unity_LightmapInd] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 122 ALU, 19 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
MUL R1.w, R6.y, R6.x;
ADD R1.xyz, R1, -R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R1.xyz, R0.w, R1, R4;
MAD R2.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[4], texture[7], 2D;
MUL R0.xyz, R0.w, R0;
TEX R1, fragment.texcoord[4], texture[8], 2D;
MUL R1.xyz, R1.w, R1;
MUL R1.xyz, R1, c[9].y;
MAD R3.xyz, R0, c[9].y, -R1;
TXP R0.xyz, fragment.texcoord[3], texture[6], 2D;
DP4 R0.w, fragment.texcoord[5], fragment.texcoord[5];
RSQ R0.w, R0.w;
RCP R0.w, R0.w;
MAD_SAT R0.w, R0, c[7].z, c[7];
LG2 R0.x, R0.x;
LG2 R0.y, R0.y;
LG2 R0.z, R0.z;
MAD R1.xyz, R0.w, R3, R1;
ADD R1.xyz, -R0, R1;
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[8].x;
END
# 122 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
Vector 7 [unity_LightmapFade]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
SetTexture 8 [unity_LightmapInd] 2D
"ps_3_0
; 127 ALU, 19 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
dcl_2d s8
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3
dcl_texcoord4 v4.xy
dcl_texcoord5 v5
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c1.x, r0.y
mov r0.x, c8.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
mov_pp r1.w, r0.x
add_pp r2.xyz, r2, -r1
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r3.xyz, r0, r0.w, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r2.xyz, r0, r2.z, r3
texld r0, v4, s7
mul_pp r0.xyz, r0.w, r0
texld r1, v4, s8
mul_pp r1.xyz, r1.w, r1
mul_pp r1.xyz, r1, c9.y
mad_pp r3.xyz, r0, c9.y, -r1
texldp r0.xyz, v3, s6
dp4 r0.w, v5, v5
rsq r0.w, r0.w
rcp r0.w, r0.w
mad_sat r0.w, r0, c7.z, c7
log_pp r0.x, r0.x
log_pp r0.y, r0.y
log_pp r0.z, r0.z
mad_pp r1.xyz, r0.w, r3, r1
add_pp r1.xyz, -r0, r1
mul r0.xyz, r2, c6
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 113 ALU, 18 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
MAD R1.xyz, R0.w, R1, R4;
MAD R2.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[4], texture[7], 2D;
TXP R1.xyz, fragment.texcoord[3], texture[6], 2D;
MUL R3.xyz, R0.w, R0;
LG2 R0.x, R1.x;
LG2 R0.z, R1.z;
LG2 R0.y, R1.y;
MAD R1.xyz, R3, c[8].y, -R0;
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[7].x;
END
# 113 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
"ps_3_0
; 119 ALU, 18 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3
dcl_texcoord4 v4.xy
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r3.xyz, r0, r0.w, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r2.xyz, r0, r2.z, r3
texld r0, v4, s7
texldp r1.xyz, v3, s6
mul_pp r3.xyz, r0.w, r0
log_pp r0.x, r1.x
log_pp r0.z, r1.z
log_pp r0.y, r1.y
mad_pp r1.xyz, r3, c8.y, -r0
mul r0.xyz, r2, c6
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 108 ALU, 17 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
ADD R1.xyz, R1, -R4;
MAD R3.xyz, R0.w, R1, R4;
TXP R1.xyz, fragment.texcoord[3], texture[6], 2D;
MAD R0.xyz, R3, R2.z, R0;
ADD R1.xyz, R1, fragment.texcoord[4];
MUL R0.xyz, R0, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[7].x;
END
# 108 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
"ps_3_0
; 115 ALU, 17 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 0, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3
dcl_texcoord4 v4.xyz
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mul_pp r0.w, r2, r0
mad_pp r3.xyz, r0, r0.w, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r1.xyz, r1.w, r4, r1
texldp r0.xyz, v3, s6
mad_pp r1.xyz, r1, r2.z, r3
add_pp r2.xyz, r0, v4
mul r0.xyz, r1, c6
mul_pp oC0.xyz, r0, r2
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
Vector 7 [unity_LightmapFade]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
SetTexture 8 [unity_LightmapInd] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 119 ALU, 19 TEX
PARAM c[10] = { program.local[0..7],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[8].z;
MUL R7.x, R0, c[8].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].x, c[8].y;
POW_SAT R6.w, R0.w, c[8].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].y, c[8].y;
POW_SAT R4.w, R0.w, c[8].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[8].z;
MUL R0.w, fragment.texcoord[2].z, c[8].y;
POW_SAT R2.w, R0.w, c[8].y;
MUL R0.w, fragment.texcoord[2], c[8].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[8].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[8].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[8];
MUL R6.x, R6, c[8].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[9].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[8].x;
MUL R2.xyz, R2, c[8].w;
POW_SAT R2.x, R2.x, c[9].x;
POW_SAT R2.y, R2.y, c[9].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[9].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
MUL R1.w, R6.y, R6.x;
MAD R0.xyz, R0, R1.w, R3;
ADD R1.xyz, R1, -R4;
MAD R3.xyz, R0.w, R1, R4;
TEX R1, fragment.texcoord[4], texture[7], 2D;
MAD R2.xyz, R3, R2.z, R0;
MUL R1.xyz, R1.w, R1;
TEX R0, fragment.texcoord[4], texture[8], 2D;
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, c[9].y;
DP4 R1.w, fragment.texcoord[5], fragment.texcoord[5];
RSQ R0.w, R1.w;
RCP R0.w, R0.w;
MAD R1.xyz, R1, c[9].y, -R0;
MAD_SAT R0.w, R0, c[7].z, c[7];
MAD R1.xyz, R0.w, R1, R0;
TXP R0.xyz, fragment.texcoord[3], texture[6], 2D;
ADD R1.xyz, R0, R1;
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[8].x;
END
# 119 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
Vector 7 [unity_LightmapFade]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
SetTexture 8 [unity_LightmapInd] 2D
"ps_3_0
; 124 ALU, 19 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
dcl_2d s8
def c8, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c9, 5.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3
dcl_texcoord4 v4.xy
dcl_texcoord5 v5
mul_pp r0.x, v2, c8
pow_pp_sat r2, r0.x, c8.x
mov r0.y, c8
mul r8.z, c1.x, r0.y
mov r0.x, c8.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c8.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r6.w, r0.x
mov r0.x, c8.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c8.x
pow_pp_sat r0, r1.w, c8.x
mov_pp r4.w, r0.x
mov r0.x, c8.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c8.x
pow_pp_sat r0, r1.w, c8.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
mov_pp r1.w, r0.x
add_pp r2.xyz, r2, -r1
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c8
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c8.z
mul_pp r7.xyz, r4, c8.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c9.x
pow_pp_sat r2, r7.x, c9.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c8.z
mul_pp r2.x, r0.y, c8.w
pow_pp_sat r0, r2.x, c9.x
pow_pp_sat r2, r7.z, c9.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r0.xyz, r0, r0.w, r3
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
add_pp r4.xyz, r4, -r1
mad_pp r3.xyz, r1.w, r4, r1
texld r1, v4, s7
mad_pp r2.xyz, r3, r2.z, r0
mul_pp r1.xyz, r1.w, r1
texld r0, v4, s8
mul_pp r0.xyz, r0.w, r0
mul_pp r0.xyz, r0, c9.y
dp4 r1.w, v5, v5
rsq r0.w, r1.w
rcp r0.w, r0.w
mad_pp r1.xyz, r1, c9.y, -r0
mad_sat r0.w, r0, c7.z, c7
mad_pp r1.xyz, r0.w, r1, r0
texldp r0.xyz, v3, s6
add_pp r1.xyz, r0, r1
mul r0.xyz, r2, c6
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, c8.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 110 ALU, 18 TEX
PARAM c[9] = { program.local[0..6],
		{ 0, 1.5, 0.1, 0.25 },
		{ 5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
MOV R0.x, c[2];
MOV R0.y, c[1].x;
MUL R7.y, R0, c[7].z;
MUL R7.x, R0, c[7].z;
MUL R0.xy, fragment.texcoord[0].zyzw, R7.x;
MUL R0.zw, fragment.texcoord[0].xyzy, R7.y;
TEX R1.xyz, R0, texture[2], 2D;
TEX R0.xyz, R0.zwzw, texture[0], 2D;
MOV R0.w, c[3].x;
MUL R5.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].x, c[7].y;
POW_SAT R6.w, R0.w, c[7].y;
ADD R1.xyz, R1, -R0;
MOV R0.w, c[4].x;
MUL R3.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].y, c[7].y;
POW_SAT R4.w, R0.w, c[7].y;
MOV R0.w, c[5].x;
MUL R1.w, R0, c[7].z;
MUL R0.w, fragment.texcoord[2].z, c[7].y;
POW_SAT R2.w, R0.w, c[7].y;
MUL R0.w, fragment.texcoord[2], c[7].y;
MAD R1.xyz, R6.w, R1, R0;
MUL R2.xy, fragment.texcoord[0].zyzw, R5.w;
TEX R0.xyz, R2, texture[3], 2D;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R4.w, R0, R1;
MUL R2.xy, fragment.texcoord[0].zyzw, R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R0;
MAD R1.xyz, R2.w, R1, R0;
MUL R2.xy, R1.w, fragment.texcoord[0].zyzw;
TEX R0.xyz, R2, texture[5], 2D;
MOV R2.x, c[0];
ADD R0.xyz, R0, -R1;
POW_SAT R0.w, R0.w, c[7].y;
MAD R4.xyz, R0.w, R0, R1;
MUL R2.x, R2, c[7].z;
MUL R1.xy, fragment.texcoord[0].xzzw, R2.x;
MUL R0.xy, fragment.texcoord[0].xzzw, R7.x;
TEX R1.xyz, R1, texture[1], 2D;
TEX R0.xyz, R0, texture[2], 2D;
ADD R2.xyz, R0, -R1;
MAD R1.xyz, R6.w, R2, R1;
MUL R3.xy, fragment.texcoord[0].xzzw, R5.w;
TEX R2.xyz, R3, texture[3], 2D;
ADD R3.xyz, R2, -R1;
MAD R5.xyz, R4.w, R3, R1;
MUL R6.xy, fragment.texcoord[0].xzzw, R3.w;
TEX R1.xyz, R6, texture[4], 2D;
ADD R6.xyz, R1, -R5;
MAD R5.xyz, R2.w, R6, R5;
MUL R3.xy, fragment.texcoord[0].xzzw, R7.y;
TEX R3.xyz, R3, texture[0], 2D;
ADD R0.xyz, R0, -R3;
MAD R3.xyz, R6.w, R0, R3;
ADD R2.xyz, R2, -R3;
MAD R3.xyz, R4.w, R2, R3;
MUL R6.xy, R1.w, fragment.texcoord[0].xzzw;
TEX R0.xyz, R6, texture[5], 2D;
ADD R6.xyz, R0, -R5;
MAD R5.xyz, R0.w, R6, R5;
ADD R1.xyz, R1, -R3;
MAD R1.xyz, R2.w, R1, R3;
ADD R0.xyz, R0, -R1;
MAD R0.xyz, R0.w, R0, R1;
MIN R6.x, fragment.texcoord[1].y, c[7];
MUL R6.x, R6, c[7].w;
MUL R1.xy, fragment.texcoord[0], R7.x;
POW_SAT R6.x, R6.x, c[8].x;
MOV R2.xz, fragment.texcoord[1];
MAX R2.y, fragment.texcoord[1], c[7].x;
MUL R2.xyz, R2, c[7].w;
POW_SAT R2.x, R2.x, c[8].x;
POW_SAT R2.y, R2.y, c[8].x;
ADD R6.y, R2.x, R2;
POW_SAT R2.z, R2.z, c[8].x;
ADD R6.y, R2.z, R6;
ADD R6.y, R6, R6.x;
RCP R6.y, R6.y;
MUL R2.xyz, R2, R6.y;
MUL R3.xyz, R2.y, R5;
MAD R3.xyz, R2.x, R4, R3;
MUL R2.xy, fragment.texcoord[0], R7.y;
TEX R4.xyz, R2, texture[0], 2D;
TEX R1.xyz, R1, texture[2], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R6.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R5.w;
TEX R1.xyz, R2, texture[3], 2D;
ADD R1.xyz, R1, -R4;
MAD R4.xyz, R4.w, R1, R4;
MUL R2.xy, fragment.texcoord[0], R3.w;
TEX R1.xyz, R2, texture[4], 2D;
ADD R1.xyz, R1, -R4;
MUL R2.xy, R1.w, fragment.texcoord[0];
MAD R4.xyz, R2.w, R1, R4;
TEX R1.xyz, R2, texture[5], 2D;
ADD R1.xyz, R1, -R4;
MUL R1.w, R6.y, R6.x;
MAD R1.xyz, R0.w, R1, R4;
MAD R0.xyz, R0, R1.w, R3;
MAD R2.xyz, R1, R2.z, R0;
TEX R0, fragment.texcoord[4], texture[7], 2D;
MUL R0.xyz, R0.w, R0;
TXP R1.xyz, fragment.texcoord[3], texture[6], 2D;
MAD R1.xyz, R0, c[8].y, R1;
MUL R0.xyz, R2, c[6];
MUL result.color.xyz, R0, R1;
MOV result.color.w, c[7].x;
END
# 110 instructions, 8 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_TilingTop]
Float 1 [_TilingSides]
Float 2 [_TilingRed]
Float 3 [_TilingGreen]
Float 4 [_TilingBlue]
Float 5 [_TilingAlpha]
Vector 6 [_Color]
SetTexture 0 [_MainTex2] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_BlendTex1] 2D
SetTexture 3 [_BlendTex2] 2D
SetTexture 4 [_BlendTex3] 2D
SetTexture 5 [_BlendTex4] 2D
SetTexture 6 [_LightBuffer] 2D
SetTexture 7 [unity_Lightmap] 2D
"ps_3_0
; 116 ALU, 18 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c7, 1.50000000, 0.10000000, 0.00000000, 0.25000000
def c8, 5.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3
dcl_texcoord4 v4.xy
mul_pp r0.x, v2, c7
pow_pp_sat r2, r0.x, c7.x
mov r0.y, c7
mul r8.z, c1.x, r0.y
mov r0.x, c7.y
mul r8.y, c2.x, r0.x
mul r0.xy, v0.zyzw, r8.z
mul r1.xy, v0.zyzw, r8.y
texld r0.xyz, r0, s0
texld r1.xyz, r1, s2
mov_pp r8.x, r2
add_pp r1.xyz, r1, -r0
mad_pp r1.xyz, r8.x, r1, r0
mov r0.x, c7.y
mul r7.w, c3.x, r0.x
mul_pp r1.w, v2.y, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r6.w, r0.x
mov r0.x, c7.y
mul r5.w, c4.x, r0.x
mul_pp r1.w, v2.z, c7.x
pow_pp_sat r0, r1.w, c7.x
mov_pp r4.w, r0.x
mov r0.x, c7.y
mul r2.xy, v0.zyzw, r7.w
texld r2.xyz, r2, s3
add_pp r2.xyz, r2, -r1
mad_pp r1.xyz, r6.w, r2, r1
mul r2.xy, v0.zyzw, r5.w
texld r2.xyz, r2, s4
add_pp r2.xyz, r2, -r1
mul r3.xy, v0.xzzw, r7.w
mad_pp r1.xyz, r4.w, r2, r1
mul r3.w, c5.x, r0.x
mul_pp r1.w, v2, c7.x
pow_pp_sat r0, r1.w, c7.x
mul r2.xy, r3.w, v0.zyzw
texld r2.xyz, r2, s5
add_pp r2.xyz, r2, -r1
mov_pp r1.w, r0.x
mad_pp r5.xyz, r1.w, r2, r1
mov r0.y, c7
mul r0.x, c0, r0.y
mul r0.xy, v0.xzzw, r0.x
mul r1.xy, v0.xzzw, r8.y
texld r1.xyz, r1, s2
texld r0.xyz, r0, s1
add_pp r2.xyz, r1, -r0
mad_pp r0.xyz, r8.x, r2, r0
texld r3.xyz, r3, s3
add_pp r2.xyz, r3, -r0
mad_pp r2.xyz, r6.w, r2, r0
mul r4.xy, v0.xzzw, r5.w
texld r0.xyz, r4, s4
add_pp r4.xyz, r0, -r2
mad_pp r4.xyz, r4.w, r4, r2
mul r6.xy, v0.xzzw, r8.z
texld r2.xyz, r6, s0
add_pp r7.xyz, r1, -r2
mad_pp r2.xyz, r8.x, r7, r2
add_pp r3.xyz, r3, -r2
mul r6.xy, r3.w, v0.xzzw
texld r1.xyz, r6, s5
add_pp r6.xyz, r1, -r4
mad_pp r6.xyz, r1.w, r6, r4
mad_pp r3.xyz, r6.w, r3, r2
mov_pp r4.xz, v1
max r4.y, v1, c7.z
mul_pp r7.xyz, r4, c7.w
add_pp r4.xyz, r0, -r3
pow_pp_sat r0, r7.y, c8.x
pow_pp_sat r2, r7.x, c8.x
mov_pp r7.x, r2
mov_pp r7.y, r0.x
min r0.y, v1, c7.z
mul_pp r2.x, r0.y, c7.w
pow_pp_sat r0, r2.x, c8.x
pow_pp_sat r2, r7.z, c8.x
mov_pp r0.w, r0.x
add_pp r8.w, r7.x, r7.y
add_pp r0.x, r2, r8.w
add_pp r2.y, r0.x, r0.w
mad_pp r0.xyz, r4.w, r4, r3
add_pp r1.xyz, r1, -r0
mad_pp r0.xyz, r1.w, r1, r0
rcp_pp r2.w, r2.y
mov_pp r7.z, r2.x
mul_pp r2.xyz, r7, r2.w
mul_pp r3.xyz, r2.y, r6
mad_pp r3.xyz, r2.x, r5, r3
mul r2.xy, v0, r8.z
texld r4.xyz, r2, s0
mul_pp r0.w, r2, r0
mul r1.xy, v0, r8.y
texld r1.xyz, r1, s2
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r8.x, r1, r4
mul r2.xy, v0, r7.w
texld r1.xyz, r2, s3
add_pp r1.xyz, r1, -r4
mad_pp r4.xyz, r6.w, r1, r4
mul r2.xy, v0, r5.w
texld r1.xyz, r2, s4
add_pp r1.xyz, r1, -r4
mad_pp r1.xyz, r4.w, r1, r4
mul r2.xy, r3.w, v0
texld r4.xyz, r2, s5
mad_pp r3.xyz, r0, r0.w, r3
add_pp r4.xyz, r4, -r1
mad_pp r0.xyz, r1.w, r4, r1
mad_pp r2.xyz, r0, r2.z, r3
texld r0, v4, s7
mul_pp r0.xyz, r0.w, r0
texldp r1.xyz, v3, s6
mad_pp r1.xyz, r0, c8.y, r1
mul r0.xyz, r2, c6
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, c7.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

}
	}

#LINE 170

	} 
	Fallback "Diffuse"
}