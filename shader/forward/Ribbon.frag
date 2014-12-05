/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

#version 330

uniform sampler2D tex;

in vec2 texcoord;
in float alpha;
out vec4 color;

void main() {
    color = texture(tex, texcoord);
    color.a *= alpha;
}
