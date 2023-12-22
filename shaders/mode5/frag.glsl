precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

#define NUM_OF_LAYERS 6.

mat2 Rot(float a){//Angle to Rotation Matrix
    float s=sin(a),c=cos(a);
    return mat2(c,-s,s,c);
}

float Hash21(vec2 p){//Random Number Generator
    p=fract(p*vec2(123.34,456.21));
    p+=dot(p,p+45.32);
    return fract(p.x*p.y);
}

float Star(vec2 uv,float flare){
    float d=length(uv);
    float m=.05/d;//instead of smoothstep(.1, .05, d) for generating the circle
    
    float rays=max(0.,1.-abs(uv.x*uv.y*1000.));//Flare A
    m+=rays*flare;
    
    uv*=Rot(3.1415/4.);//Rotate UV to 45*
    
    rays=max(0.,1.-abs(uv.x*uv.y*1000.));//Flare B
    m+=rays*.3*flare;
    
    m*=smoothstep(1.,.2,d);//Reduces Bleed
    
    return m;
}

vec3 StarLayer(vec2 uv){
    vec3 col=vec3(0);
    
    vec2 gv=fract(uv)-.5;
    vec2 id=floor(uv);
    
    for(int y=-1;y<=1;y++){
        for(int x=-1;x<=1;x++){
            vec2 offs=vec2(x,y);
            
            float n=Hash21(id+offs);//To get the value in neighbours of 3x3
            float size=fract(n*345.32);
            float star=Star(gv-offs-vec2(n,fract(n*34.))+.5,smoothstep(.8,1.,size));
            
            vec3 colour=sin(vec3(.2,.3,.9)*fract(n*2345.2)*125.2)*.5+.5;
            colour*=vec3(1.-.2*size,.5-.1*size,1.+size);
            
            star*=sin(time*3.+n*6.2831)*.4+1.;
            
            col+=star*size*colour;
        }
    }
    
    return col;
}

void main()
{
    vec3 uv=vNormal+vec3(vUv,0.);
    
    //look input
    
    //uv *= 5.0;
    float t=time*.01;
    uv.xy*=Rot(t);//Rotating UV
    
    vec3 col=vec3(0);
    for(float i=0.;i<1.;i+=1./NUM_OF_LAYERS){
        float depth=fract(i+t);
        float scale=mix(20.,.5,depth);
        
        float opacity=depth*smoothstep(1.,.9,depth);
        col+=StarLayer(uv.xy*scale+i*453.2)*opacity;
    }
    
    gl_FragColor=vec4(col,1.);//Output
}