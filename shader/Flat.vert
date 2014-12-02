/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330 
#pragma include "shader/Mesh.vert"

// FIXME: Uncomment to calculate transform on CPU instead
//uniform mat4 transform;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 worldMatrix;

/* Very fast simple solid-color shader for rendering to depth */
void main() {
	// Transform the vertex to get the clip-space position of the vertex
    mat4 transform = projectionMatrix * viewMatrix * worldMatrix;
	gl_Position = transform * vec4(positionIn, 1);
}
