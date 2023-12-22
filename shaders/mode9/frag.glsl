precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

#define NUM_NOISE_OCTAVES 12

float random(vec2 st){
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float noise(vec2 x){
    vec2 i=floor(x);
    vec2 f=fract(x);
    
    // Four corners in 2D of a tile
    float a=random(i);
    float b=random(i+vec2(1.,0.));
    float c=random(i+vec2(0.,1.));
    float d=random(i+vec2(1.,1.));
    
    // Same code, with the clamps in smoothstep and common subexpressions
    // optimized away.
    vec2 u=f*f*(3.-2.*f);
    return mix(a,b,u.x)+(c-a)*u.y*(1.-u.x)+(d-b)*u.x*u.y;
}

float fbm(vec2 x){
    float v=0.;
    float a=.5;
    vec2 shift=vec2(100);
    // Rotate to reduce axial bias
    mat2 rot=mat2(cos(.5),sin(.5),-sin(.5),cos(.50));
    for(int i=0;i<NUM_NOISE_OCTAVES;++i){
        v+=a*noise(x);
        x=rot*x*2.+shift;
        a*=.5;
    }
    return v;
}

void main(){
    vec3 st=vNormal+vec3(vUv,0.);
    //st += st * abs(sin(time*0.1)*3.0);
    
    vec2 q=vec2(0.);
    
    q.x=fbm(st.xy+1.+vec2(1.7,9.2)+.15*time/2.);
    q.y=fbm(st.xy+1.+vec2(8.3,2.8)+.126*time/2.);
    
    float f=fbm(st.xy+q);
    
    // Output to screen
    //  fragColor = vec4(f,f,f,1.0);
    gl_FragColor=vec4(cos(f*30.),cos(f*40.),cos(f*20.),1.);
}