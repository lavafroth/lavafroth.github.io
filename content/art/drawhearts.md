---
title: "Step to the 💗 beat"
date: 2026-01-18T08:06:06+05:30
image: "/hearts.avif"
layout: "artpiece"
draft: false
---

My first procedurally generated animation using shaders.

The shader can be visualized with `glslViewer`.

```glsl
uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

void main (void) {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
   float aspect = u_resolution.x/u_resolution.y;
    st.x *= aspect;

    // positioning shenanigans
    st.x = st.x * 2.0 - 1.8;
    st.y = st.y * 2.0 - 0.9;

    float r = st.x*st.x + st.y*st.y - abs(st.x)*st.y;
    r *= 2.0;

    float duration = 3.0;
    float bin = 0.1;
    float scaled_time = fract(u_time/duration);
    float loop = scaled_time * 2.0 - 1.0;
    float r_disc = floor((r + loop*loop)/bin) * bin;

    vec3 deep_pink = vec3(0.917, 0.235, 0.478);
    vec3 light_pink = vec3(0.976, 0.780, 0.803);

    if (r_disc >= 1.0) {
        gl_FragColor = vec4(deep_pink, 1.0);
        return;
    }
    vec3 color = mix(deep_pink, light_pink, r_disc);
    gl_FragColor = vec4(color,1.0);
}
```

I tinkered around for quite a while before discovering that I can intersect two $xy$ skewed ellipses
with the absolute value operator. Here's my custom equation for the heart shape.

$$ x^2 + y^2 - |x|y = r $$

have fun!
