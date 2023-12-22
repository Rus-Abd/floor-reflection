precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

void main(){
    vec3 uv=vNormal+vec3(vUv,0.);
    
    for(float i=1.;i<10.;i++){
        uv.x+=.6/i*cos(i*2.5*uv.y+time/3.);
        uv.y+=.6/i*cos(i*1.5*uv.x+time/3.);
    }
    
    gl_FragColor=vec4(vec3(.1)/abs(sin(time/3.-uv.y-uv.x)),1.);
}