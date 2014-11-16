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

in vec3 lightPosition;

out vec4 color;

/* Deferred point light shader */
void main() {
    vec3 Ld = diffuseColor;
    vec3 Ls = specularColor;

    LightingInfo li = lightingInfo();

    vec3 V = normalize(-li.view);
    vec3 R = reflect(-V, li.N);
    vec3 L = lightPosition - li.view;
    float D = length(L);
    float atten = 1./(atten0 + atten1 * D + atten2 * D * D);
    L = normalize(L);

    float Rd = dot(li.N, L);
    if (Rd > 0.) {
        // Calculate the diffuse color coefficient
        vec3 diffuse = li.Kd * Ld * Rd;

        // Calculate the specular color coefficient
        vec3 specular = li.Ks * Ls * pow(max(0., dot(L, R)), li.alpha);

        color = vec4(diffuse + specular, 1.);
        color.rgb *= atten;
    } else {
        color = vec4(0., 0., 0., 1.);
    }
}
