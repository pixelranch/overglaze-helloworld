// Hello World -- the desktop breathing between full colour and grayscale.
//
// A .wgsl-only plugin: no JavaScript, no build step. The host reads this file and
// runs it through its WGSL driver, which supplies the fullscreen vertex stage and
// the @group(0) builtin prelude -- the `src` desktop texture, the uniform structs
// (`time`, `resolution`, ...) and the sRGB helpers. This file therefore defines
// ONLY the fragment stage.
//
// `src` is an unfilterable-float texture, so it is read with textureLoad at
// integer texel coordinates rather than sampled. If you need smooth sampling
// (for a warp or a blur) you write the bilinear filter yourself.
//
// The knobs are declared below in `@param` comments. Each becomes a member of a
// generated `struct Params` in that same prelude -- read as `params.<name>` --
// and a labelled control in this plugin's panel, persisted the moment the user
// moves it away from the default. That is the whole UI: a shader-only plugin
// never writes a line of interface code. Stating both `min` and `max` is what
// turns a drag box into a slider.

// Master switch. Keeping a gate like this in every effect is the fastest way to
// tell "my shader is wrong" apart from "capture is wrong". A `bool` parameter
// occupies the struct as a u32, so it is compared against 0u rather than used
// directly as a condition.
// @param enableEffect bool true label="Enable effect" tooltip="Off = untouched passthrough of the captured desktop."

// @param desaturation f32 1.0 min=0 max=1 label=Desaturation tooltip="Peak share of grayscale mixed in at the top of the cycle. 0 = always full colour, 1 = fully grey at the peak."

// The lower bound is doing real work here: it is what stops the division below
// from reaching zero, which would take sin() to NaN and blank the screen.
// @param cycleSeconds f32 6.0 min=0.5 max=30 label="Cycle seconds" tooltip="Length of one complete colour -> grey -> colour breath, in seconds."

// Rec.709 luma weights. Perceptual weights rather than a flat (1/3, 1/3, 1/3)
// average are what stop saturated reds from going muddy as they desaturate.
// Deliberately not a @param: a constant of the colour space is not a knob.
const LUMA : vec3f = vec3f(0.2126, 0.7152, 0.0722);

const TAU : f32 = 6.2831853;

@fragment fn fs(@builtin(position) pos : vec4f) -> @location(0) vec4f {
    let dim = vec2i(textureDimensions(src));
    // pos.xy is in pixels and can land exactly on the far edge, so clamp before
    // the load -- an out-of-bounds textureLoad returns zero, which shows up as a
    // one-pixel black seam along the right and bottom of the screen.
    let p   = clamp(vec2i(pos.xy), vec2i(0), dim - vec2i(1));
    let rgb = textureLoad(src, p, 0).rgb;

    if (params.enableEffect == 0u) {
        return vec4f(rgb, 1.0);
    }

    let grey = vec3f(dot(rgb, LUMA));

    // sin() lingers near its extremes and moves fastest through zero, so the
    // breath holds at full colour and full grey instead of sweeping evenly.
    let phase = 0.5 + 0.5 * sin(time.value * TAU / params.cycleSeconds);

    // Colour here is scene-referred linear: 1.0 is SDR reference white and values
    // above it are HDR headroom, which the host maps to the display. Returning
    // alpha 1.0 keeps the desktop opaque; see `mode` in package.json to composite
    // over the live screen instead.
    return vec4f(mix(rgb, grey, params.desaturation * phase), 1.0);
}
