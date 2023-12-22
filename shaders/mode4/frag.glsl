precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

vec3 palette(float t){
    vec3 a=vec3(.5,.5,.5);
    vec3 b=vec3(.5,.5,.5);
    vec3 c=vec3(1.,1.,1.);
    vec3 d=vec3(.263,.416,.557);
    
    return a+b*cos(6.28318*(c*t+d));
}

void main(){
    
    vec3 newUv=vNormal+vec3(vUv,0.);
    
    vec3 finalColor=vec3(0.);
    
    vec3 newUv0=newUv.xyz;
    
    for(float i=0.;i<4.;i++){
        newUv=fract(newUv*1.5)-.5;
        
        float d=length(newUv)*exp(-length(newUv0));
        
        vec3 col=palette(length(newUv0)+i*.4+time*.2);
        
        d=sin(d*8.+time/3.)/8.;
        d=abs(d);
        
        d=pow(.01/d,1.2);
        
        finalColor+=col*d;
    }
    
    gl_FragColor=vec4(finalColor,1.);
}