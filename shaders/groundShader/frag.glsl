uniform vec3 color;
uniform sampler2D tDiffuse;
uniform sampler2D tDudv;
uniform float time;
varying vec4 vUv;

#if defined(USE_LOGDEPTHBUF)&&defined(USE_LOGDEPTHBUF_EXT)

uniform float logDepthBufFC;
varying float vFragDepth;
varying float vIsPerspective;

#endif

float blendOverlay(float base,float blend){
    
    return(base<.5?(2.*base*blend):(1.-2.*(1.-base)*(1.-blend)));
    
}

vec3 blendOverlay(vec3 base,vec3 blend){
    
    return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
    
}

void main(){
    
    #if defined(USE_LOGDEPTHBUF)&&defined(USE_LOGDEPTHBUF_EXT)
    
    // Doing a strict comparison with == 1.0 can cause noise artifacts
    // on some platforms. See issue #17623.
    gl_FragDepthEXT=vIsPerspective==0.?gl_FragCoord.z:log2(vFragDepth)*logDepthBufFC*.5;
    
    #endif
    
    float waveStrength=.5;
    float waveSpeed=.03;
    
    // simple distortion (ripple) via dudv map (see https://www.youtube.com/watch?v=6B7IF6GOu7s)
    
    vec2 distortedUv=texture2D(tDudv,vec2(vUv.x+time*waveSpeed,vUv.y)).rg*waveStrength;
    distortedUv=vUv.xy+vec2(distortedUv.x,distortedUv.y+time*waveSpeed);
    vec2 distortion=(texture2D(tDudv,distortedUv).rg*2.-1.)*waveStrength;
    
    // new uv coords
    
    vec4 uv=vec4(vUv);
    uv.xy+=distortion;
    
    vec4 base=texture2DProj(tDiffuse,uv);
    vec4 newBase=vec4(1.);
    
    gl_FragColor=vec4(mix(base.rgb,color,.5)/15.,1.);
    
    #if defined(TONE_MAPPING)
    
    gl_FragColor.rgb=toneMapping(gl_FragColor.rgb);
    
    #endif
    gl_FragColor=linearToOutputTexel(gl_FragColor);
    
}