/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/
 
#version 330
#pragma include "shader/Mesh.vert"

uniform mat4 viewProjectionMatrix;
uniform mat4 viewMatrix;

layout(location=4) in vec4 rotation;
layout(location=5) in vec3 origin;

out vec3 normal;
out vec3 tangent;
out vec2 texCoord;

/* Transform a vector by a quaternion */
vec3 mulquat(vec4 self, vec3 v) {
    // OpenGL quat: x y z w
    // Lua quat: w x y z
    vec3 qv = self.yzw;
    vec3 uv = cross(qv, v);
    vec3 uuv = cross(qv, uv);
    return v+((uv*self.x)+uuv)*2;
}
 
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
	texCoord = texCoordIn;
}
