precision mediump float;
uniform sampler2D u_image;
uniform float time;
uniform vec2 resolution;

varying vec2 vUv;
varying vec3 vNormal;

void main(){
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    vec3 combinedValue=vNormal+vec3(vUv,0.);
    float d=length(vNormal);
    gl_FragColor=vec4(vec3(d),1.);
}