/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330

uniform sampler2D tex;
uniform sampler2D depthBuffer;
uniform mat4 projectionInvMatrix; // From clip space to view space
uniform vec4 tint;

in float alpha;
in float rotation;
in float viewZ;
in vec2 texcoord;
in vec4 color;
in vec4 position;

out vec4 colorOut;

void main() {
    float x = texcoord.s - 0.5;
    float y = texcoord.t - 0.5;
    float s = x * cos(rotation) - y * sin(rotation) + 0.5;
    float t = x * sin(rotation) + y * cos(rotation) + 0.5;
    
    // Soft particles
    vec2 normalized = position.xy/position.w;
    vec2 viewport = (normalized.xy + 1.)/2.;

    float depth = texture(depthBuffer, viewport).r;
    vec3 clip = vec3(normalized, 2. * depth - 1.);
    vec4 view = projectionInvMatrix * vec4(clip, 1.);
    view /= view.w;

    float scale = 4.f;
    float fade = clamp((viewZ - view.z) * scale, 0, 1);

	colorOut = color * tint * texture(tex, vec2(s, t));
    colorOut.a *= fade; // Soft particles
}

