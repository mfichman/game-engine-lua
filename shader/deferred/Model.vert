/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/
 
#version 330
#pragma include "shader/Mesh.vert"

uniform mat4 transform;
uniform mat3 normalMatrix;

out vec3 normal;
out vec3 tangent;
out vec2 texCoord;
 
/* Deferred render shader with normal, specular, and diffuse mapping */
void main() {
	// Transform the vertex to get the clip-space position of the vertex
	gl_Position = transform * vec4(positionIn, 1);

	// Transform the normal and tangent by the normal matrix
	normal = normalMatrix * normalIn;
	tangent = normalMatrix * tangentIn;

	// Simply copy the texture coordinates over to the fragment shader
	texCoord = texCoordIn;
}
