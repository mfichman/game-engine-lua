/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330 
#pragma include "shader/Mesh.vert"

uniform mat4 worldViewProjectionMatrix;

/* Very fast simple solid-color shader for rendering to depth */
void main() {
	// Transform the vertex to get the clip-space position of the vertex
	gl_Position = worldViewProjectionMatrix * vec4(positionIn, 1);
}
