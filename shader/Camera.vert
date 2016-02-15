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

layout(std140) uniform buffers {
    uniform sampler2D diffuseBuffer;
    uniform sampler2D specularBuffer;
    uniform sampler2D emissiveBuffer;
    uniform sampler2D depthBuffer;
    uniform sampler2D shadowMap;
};

// inverseProject
