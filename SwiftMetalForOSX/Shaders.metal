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

