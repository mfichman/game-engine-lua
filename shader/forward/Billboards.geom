/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330
#pragma include "shader/Transform.vert"

layout (points) in;
layout (triangle_strip) out;
layout (max_vertices = 4) out;

in Vertex {
    vec3 position;
    vec3 forward;
    vec3 right;
    vec4 color;
    float width;
    float height;
} vertex[];

out vec2 texcoord;
out vec4 color;

void main() {
    vec3 pos = vertex[0].position;
    vec3 f = vertex[0].forward * vertex[0].width / 2;
    vec3 r = vertex[0].right * vertex[0].height / 2;

    color = vertex[0].color;

    gl_Position = worldViewProjectionMatrix * vec4(pos - f + r, 1);
    texcoord = vec2(0, 1);
    EmitVertex();

    gl_Position = worldViewProjectionMatrix * vec4(pos - f - r, 1);
    texcoord = vec2(0, 0);
    EmitVertex();

    gl_Position = worldViewProjectionMatrix * vec4(pos + f + r, 1);
    texcoord = vec2(1, 1);
    EmitVertex();

    gl_Position = worldViewProjectionMatrix * vec4(pos + f - r, 1);
    texcoord = vec2(1, 0);
    EmitVertex();
}
