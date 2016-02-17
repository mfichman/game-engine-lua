/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330 
#pragma include "shader/Transform.vert"

layout(location=0) in vec3 positionIn;

void main() {
    gl_Position = worldViewProjectionMatrix * vec4(positionIn, 1);
}
