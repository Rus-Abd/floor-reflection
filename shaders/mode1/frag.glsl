precision mediump float;
uniform sampler2D u_image;
uniform float time;
uniform vec2 resolution;

varying vec2 vUv;
varying vec3 vNormal;

void main(){
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    vec3 combinedValue=vNormal+vec3(vUv,0.);
    vec3 color=vec3(.5+.5*sin(combinedValue.x+time),.5+.5*cos(combinedValue.y-time),.5+.5*sin(combinedValue.y-time));
    
    gl_FragColor=vec4(color,1.);
}