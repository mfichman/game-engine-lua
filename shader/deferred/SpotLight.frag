/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330
#pragma include "shader/deferred/Light.frag"

uniform float atten0; 
uniform float atten1;
uniform float atten2;
uniform vec3 diffuseColor;
uniform vec3 specularColor;
uniform float cutoff;
uniform float power;
uniform vec3 direction;

in vec3 lightPosition;

out vec4 color; // Output to color buffer

/* Deferred spot light shader */
void main() {
    vec3 Ld = diffuseColor;
    vec3 Ls = specularColor;

	LightingInfo li = lightingInfo();
	float shadow = shadowPoissonPcf(li);

	// Sample the normal and the view vector
	vec3 V = normalize(li.view); // View vec
	vec3 R = reflect(V, li.N);
	vec3 L = lightPosition - li.view;
	float D = length(L);
	float atten = 1./(atten0 + atten1 * D + atten2 * D * D);
	L = normalize(L);

	float Rd = dot(li.N, L);
    float effect = clamp(dot(direction, -L), 0., 1.);

	if (Rd > 0. && effect > cutoff) {
		// Calculate the diffuse color coefficient
		vec3 diffuse = li.Kd * Ld * Rd;

		// Calculate the specular color coefficient
		vec3 specular = li.Ks * Ls * pow(max(0., dot(L, R)), li.alpha);

		// Calculate the shadow coord
		color = vec4(diffuse + specular, 1.);
		color.rgb *= shadow * atten * pow(effect, power);
	} else {
		color = vec4(0., 0., 0., 1.);
	}
    // FIXME: Luminance mapping (make optional)
    // float lum = 0.2216*color.r + 0.7152*color.g + 0.0722*color.b;
    // float lumd = lum / (1+lum); 
    
    //color.rgb += .1;
    //color.rgb *= lumd;
}
