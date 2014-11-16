/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330

uniform sampler2D diffuseMap;
uniform sampler2D specularMap;
uniform sampler2D normalMap;
uniform sampler2D emissiveMap;

uniform vec3 diffuseColor;
uniform vec3 specularColor;
uniform vec3 ambientColor;
uniform vec3 emissiveColor;
uniform float hardness;

in vec3 normal;
in vec3 tangent;
in vec2 texCoord;

layout(location=0) out vec3 material;
layout(location=1) out vec4 specular;
layout(location=2) out vec3 normalOut;
layout(location=3) out vec3 emissive;

/* Deferred render shader with normal, specular, and diffuse mapping */
void main() {
    vec3 Kd = diffuseColor;
    vec3 Ks = specularColor;
    vec3 Ka = ambientColor;
    vec3 Ke = emissiveColor;

	// Get the normal from the normal map texture and unpack it
	vec3 Tn = normalize((texture(normalMap, texCoord) * 2. - 1.).xyz);	

	// Create the TBN matrix from the normalized T and N vectors
	vec3 N = normalize(normal);
	vec3 T = normalize(tangent);
	vec3 B = cross(N, T);
	mat3 TBN = mat3(T, B, N);

	// Sample the diffuse and specular texture
	vec3 Td = texture(diffuseMap, texCoord).rgb;
	vec3 Ts = texture(specularMap, texCoord).rgb;
    vec3 Te = texture(emissiveMap, texCoord).rgb;

	// Save diffuse material parameters
	material = Td * Kd;

	// Save the specular material parameters (with hardness)
	specular.rgb = Ts * Ks;
	specular.a = hardness/1024; 
    // Shininess must be in the range [0, -1024].  This is required to scale
    // down the shininess to 8 bits, so that "converted" shininess above 1.0f
    // doesn't get clamped.

	// Save the normal vector in view space, range [0, 1]
	normalOut = (TBN * Tn + 1.) / 2.;

    // Emissive color
    emissive = Te * Ke;
}
