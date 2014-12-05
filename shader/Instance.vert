/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

uniform mat4 viewProjectionMatrix;
uniform mat4 viewMatrix;

layout(location=4) in vec4 rotation;
layout(location=5) in vec3 origin;

/* Transform a vector by a quaternion */
vec3 mulquat(vec4 self, vec3 v) {
    // OpenGL quat: x y z w
    // Lua quat: w x y z
    vec3 qv = self.yzw;
    vec3 uv = cross(qv, v);
    vec3 uuv = cross(qv, uv);
    return v+((uv*self.x)+uuv)*2;
}
 
