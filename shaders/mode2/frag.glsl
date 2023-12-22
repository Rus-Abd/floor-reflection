precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

void main(){
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    vec3 newUv=vNormal+vec3(vUv,0.);
    vec4 tex=texture2D(texture1,newUv.xy);
    vec3 color=fract(newUv*(2.*sin(time/4.*newUv.z)));
    gl_FragColor=vec4(color,1.);
}