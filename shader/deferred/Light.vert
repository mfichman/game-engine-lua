/*****************************************************************************
 * Simple, Fast Renderer (SFR)                                               *
 * CS249b                                                                    *
 * Matt Fichman                                                              *
 * February, 2011                                                            *
 *****************************************************************************/
  
uniform mat4 worldViewMatrix;
uniform mat4 worldViewProjectionMatrix;

layout(location=0) in vec3 positionIn;

out vec4 position;
out vec3 lightPosition;

/* Deferred render point light shader */
void main() {
	// Transform the vertex to get the clip-space position of the vertex
	gl_Position = position = worldViewProjectionMatrix * vec4(positionIn, 1);
	lightPosition = (worldViewMatrix * vec4(0, 0, 0, 1)).xyz;
}
