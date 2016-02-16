/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330
#pragma include "shader/Material.vert";

in vec3 normal;
in vec3 tangent;
in vec2 texcoord;

layout(location=0) out vec3 diffuseOut;
layout(location=1) out vec4 specularOut;
layout(location=2) out vec3 normalOut;
layout(location=3) out vec3 emissiveOut;

/* Deferred render shader with normal, specular, and diffuse mapping */
void main() {
    vec3 Kd = diffuseColor.rgb;
    vec3 Ks = specularColor.rgb;
    vec3 Ka = ambientColor.rgb;
    vec3 Ke = emissiveColor.rgb;

	// Get the normal from the normal map texture and unpack it
	vec3 Tn = normalize((texture(normalMap, texcoord) * 2. - 1.).xyz);	

	// Create the TBN matrix from the normalized T and N vectors
	vec3 N = normalize(normal);
	vec3 T = normalize(tangent);
	vec3 B = cross(N, T);
	mat3 TBN = mat3(T, B, N);

	// Sample the diffuse and specular texture
	vec3 Td = texture(diffuseMap, texcoord).rgb;
	vec3 Ts = texture(specularMap, texcoord).rgb;
    vec3 Te = texture(emissiveMap, texcoord).rgb;

	// Save diffuse material parameters
	diffuseOut = Td * Kd;

	// Save the specular material parameters (with hardness)
	specularOut.rgb = Ts * Ks;
	specularOut.a = hardness/1024; 
    // Shininess must be in the range [0, -1024].  This is required to scale
    // down the shininess to 8 bits, so that "converted" shininess above 1.0f
    // doesn't get clamped.

	// Save the normal vector in view space, range [0, 1]
	normalOut = (TBN * Tn + 1.) / 2.;

    // Emissive color
    emissiveOut = Te * Ke;
}
