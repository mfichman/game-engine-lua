/*
 * Copyright (c) 2014 Matt Fichman
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

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
} vec_Transform;


