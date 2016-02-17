/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/
 
#version 330
#pragma include "shader/Mesh.vert"
#pragma include "shader/Camera.vert"
#pragma include "shader/Instance.vert"

out vec3 normal;
out vec3 tangent;
out vec2 texcoord;

/* Deferred render shader with normal, specular, and diffuse mapping */
void main() {
	// Transform the vertex to get the clip-space position of the vertex
    vec3 positionWorld = mulquat(rotation, positionIn) + origin;
    vec3 normalWorld = mulquat(rotation, normalIn);
    vec3 tangentWorld = mulquat(rotation, tangentIn);

	gl_Position = viewProjectionMatrix * vec4(positionWorld, 1);

	// Transform the normal and tangent by the normal matrix
	normal = mat3(viewMatrix) * normalWorld;
	tangent = mat3(viewMatrix) * tangentWorld;

	// Simply copy the texture coordinates over to the fragment shader
	texcoord = texcoordIn;
}
