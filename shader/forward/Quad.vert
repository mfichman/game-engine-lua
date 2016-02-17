/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330
#pragma include "shader/Mesh.vert"
#pragma include "shader/Transform.vert"

out vec2 texcoord;

/* Particle shader */
void main() {
    gl_Position = worldViewProjectionMatrix * vec4(positionIn, 1);
    texcoord = texcoordIn;
}
