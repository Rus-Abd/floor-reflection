precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

#define ANIMATE

vec2 hash2(vec2 p)
{
    // texture based white noise
    return textureLod(texture1,(p+.5)/256.,0.).xy;
    
    // procedural white noise
    //return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec3 voronoi(in vec2 x)
{
    vec2 ip=floor(x);
    vec2 fp=fract(x);
    
    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
    vec2 mg,mr;
    
    float md=8.;
    for(int j=-1;j<=1;j++)
    for(int i=-1;i<=1;i++)
    {
        vec2 g=vec2(float(i),float(j));
        vec2 o=hash2(ip+g);
        #ifdef ANIMATE
        o=.5+.5*sin(time/2.+6.2831*o);
        #endif
        vec2 r=g+o-fp;
        float d=dot(r,r);
        
        if(d<md)
        {
            md=d;
            mr=r;
            mg=g;
        }
    }
    
    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md=8.;
    for(int j=-2;j<=2;j++)
    for(int i=-2;i<=2;i++)
    {
        vec2 g=mg+vec2(float(i),float(j));
        vec2 o=hash2(ip+g);
        #ifdef ANIMATE
        o=.5+.5*sin(time/2.+6.2831*o);
        #endif
        vec2 r=g+o-fp;
        
        if(dot(mr-r,mr-r)>.00001)
        md=min(md,dot(.5*(mr+r),normalize(r-mr)));
    }
    
    return vec3(md,mr);
}

void main()
{
    vec3 p=vNormal+vec3(vUv,0.);
    
    vec3 c=voronoi(8.*p.xy);
    
    // isolines
    vec3 col=c.x*(.5+.5*sin(64.*c.x))*vec3(1.);
    // borders
    col=mix(vec3(1.,.6,0.),col,smoothstep(.04,.07,c.x));
    // feature points
    float dd=length(c.yz);
    col=mix(vec3(1.,.6,.1),col,smoothstep(0.,.12,dd));
    col+=vec3(1.,.6,.1)*(1.-smoothstep(0.,.04,dd));
    
    gl_FragColor=vec4(col,1.);
}