/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330

uniform mat4 worldViewProjectionMatrix;

layout(location=0) in vec2 positionIn;
layout(location=1) in vec2 texCoordIn;

out vec2 texCoord;

/* Text shader */
void main() {
    gl_Position = worldViewProjectionMatrix * vec4(positionIn, 0, 1);
    texCoord = texCoordIn;
}
