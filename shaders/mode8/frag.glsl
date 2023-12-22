precision mediump float;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture1;

varying vec2 vUv;
varying vec3 vNormal;

vec2 random2(vec2 p){
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(.670,.330))))*43758.5453);
}

void main()
{
    vec3 st=vNormal+vec3(vUv,0.);
    // st.x *= iResolution.x/iResolution.y;
    vec3 color=vec3(.129,.454,.925);
    
    // Scale
    st*=3.;
    
    // Tile the space
    vec2 i_st=floor(st.xy);
    vec2 f_st=fract(st.xy);
    
    float m_dist=1.;// minimum distance
    
    for(int y=-1;y<=1;y++){
        for(int x=-1;x<=1;x++){
            // Neighbor place in the grid
            vec2 neighbor=vec2(float(x),float(y));
            
            // Random position from current + neighbor place in the grid
            vec2 point=random2(i_st+neighbor);
            
            // Animate the point
            point=.5+.5*sin(time/4.+6.2831*point);
            
            // Vector between the pixel and the point
            vec2 diff=neighbor+point-f_st;
            
            // Distance to the point
            float dist=length(diff);
            
            // Keep the closer distance
            m_dist=min(m_dist,dist*m_dist);
        }
    }
    
    // Draw the min distance (distance field)
    color+=m_dist;
    
    // Show isolines
    color-=step(.988,abs(sin(30.*m_dist)))*.5;
    
    gl_FragColor=vec4(color,1.);
}