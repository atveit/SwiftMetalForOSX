//
//  Shaders.metal
//  SwiftMetalForOSX
//
//  Created by Amund Tveit on 10/06/15.
//  Copyright © 2015 Amund Tveit. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void doubler(const device float *inVector [[ buffer(0) ]],
                    device float *outVector [[ buffer(1) ]],
                    uint id [[ thread_position_in_grid ]]) {
    outVector[id] = 2*inVector[id];
}

kernel void multvfloat(const device float *in1 [[ buffer(0) ]],
                      const device float *in2 [[ buffer(1) ]],
                       device float *out [[ buffer(2) ]],
                      uint id [[ thread_position_in_grid ]]) {
    
    out[id] = in1[id]*in2[id];
}

kernel void multvfloat2(const device float2 *in1 [[ buffer(0) ]],
                        const device float2 *in2 [[ buffer(1) ]],
                        device float2 *out [[ buffer(2) ]],
                        uint id [[ thread_position_in_grid ]]) {
    out[id] = in1[id]*in2[id];
}

kernel void multvfloat4(const device float4 *in1 [[ buffer(0) ]],
                       const device float4 *in2 [[ buffer(1) ]],
                       device float4 *out [[ buffer(2) ]],
                       uint id [[ thread_position_in_grid ]]) {
    out[id] = in1[id]*in2[id];
}

kernel void multvfloat16(const device float4x4 *in1 [[ buffer(0) ]],
                        const device float4x4 *in2 [[ buffer(1) ]],
                        device float4x4 *out [[ buffer(2) ]],
                        uint id [[ thread_position_in_grid ]]) {
    out[id] = in1[id]*in2[id];

}