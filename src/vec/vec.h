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
    vec_Scalar data[16];
} vec_Mat3x3;

typedef struct vec_Mat4x4 {
    vec_Scalar data[16];
} vec_Mat4x4;

typedef struct vec_Quat {
    union {
        struct {
            union { vec_Scalar w; };
            union { vec_Scalar x; };
            union { vec_Scalar y; };
            union { vec_Scalar z; };
        };
        vec_Scalar data[4];
    };
} vec_Quat;

typedef struct vec_Vec3 {
    union {
        struct {
            union { vec_Scalar x; vec_Scalar r; vec_Scalar red; };
            union { vec_Scalar y; vec_Scalar g; vec_Scalar green; };
            union { vec_Scalar z; vec_Scalar b; vec_Scalar blue; };
        };
        vec_Scalar data[3];
    };
} vec_Vec3;

typedef struct vec_Vec4 {
    union {
        struct {
            union { vec_Scalar x; vec_Scalar r; vec_Scalar red; };
            union { vec_Scalar y; vec_Scalar g; vec_Scalar green; };
            union { vec_Scalar z; vec_Scalar b; vec_Scalar blue; };
            union { vec_Scalar w; vec_Scalar a; vec_Scalar alpha; };
        };
        vec_Scalar data[4];
    };
} vec_Vec4;

typedef struct vec_Transform {
    vec_Vec3 origin;
    vec_Quat rotation;
} vec_Transform;

typedef struct vec_Vec2 {
    union {
        struct {
            union { vec_Scalar x; vec_Scalar u; vec_Scalar w; vec_Scalar width; };
            union { vec_Scalar y; vec_Scalar v; vec_Scalar h; vec_Scalar height; };
        };
        vec_Scalar data[2];
    };
} vec_Vec2;

