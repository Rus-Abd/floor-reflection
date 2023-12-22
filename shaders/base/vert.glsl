
uniform float time;
attribute vec3 a_random;
attribute vec3 a_size;

varying vec2 vUv;
varying vec3 vNormal;

const float PI=3.14159265359;

uniform vec2 hover;

void main(){
    
    vUv=uv;
    vNormal=normal;
    
    vec3 mvPosition=position;
    
    gl_Position=projectionMatrix*modelViewMatrix*vec4(mvPosition,1.);
}