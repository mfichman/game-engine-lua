/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/

layout(std140) uniform camera {
    mat4 projectionMatrix;
    mat4 projectionInvMatrix;
    mat4 viewMatrix;
    mat4 viewInvMatrix;
    mat4 viewProjectionMatrix;
    mat4 viewProjectionInvMatrix;
};

// worldViewProjectionMatrix
// worldViewMatrix
// worldViewInvMatrix
// normalMatrix
// lightMatrix
// inverseProject
