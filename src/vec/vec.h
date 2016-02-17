/* ========================================================================== --
--                                                                            --
-- Copyright (c) 2014 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== */

typedef float vec_Scalar;

typedef struct vec_Mat3x3 {
    vec_Scalar d00, d01, d02;
    vec_Scalar d03, d04, d05;
    vec_Scalar d06, d07, d08;
} vec_Mat3x3;

typedef struct vec_Mat4x4 {
    vec_Scalar d00, d01, d02, d03;
    vec_Scalar d04, d05, d06, d07;
    vec_Scalar d08, d09, d10, d11;
    vec_Scalar d12, d13, d14, d15;
} vec_Mat4x4;

typedef struct vec_Quat {
    vec_Scalar w;
    vec_Scalar x;
    vec_Scalar y;
    vec_Scalar z;
} vec_Quat;

typedef struct vec_Vec2 {
    union { vec_Scalar x; vec_Scalar u; vec_Scalar w; vec_Scalar width; };
    union { vec_Scalar y; vec_Scalar v; vec_Scalar h; vec_Scalar height; };
} vec_Vec2;

typedef struct vec_Vec3 {
    vec_Scalar x;
    vec_Scalar y;
    vec_Scalar z;
} vec_Vec3;

typedef struct vec_Vec4 {
    vec_Scalar x;
    vec_Scalar y;
    vec_Scalar z;
    vec_Scalar w;
} vec_Vec4;

typedef struct vec_Color {
    vec_Scalar r;
    vec_Scalar g;
    vec_Scalar b;
    vec_Scalar a;
} vec_Color;

typedef struct vec_Transform {
    vec_Vec3 origin;
    vec_Quat rotation;
    vec_Scalar scale;
} vec_Transform;


