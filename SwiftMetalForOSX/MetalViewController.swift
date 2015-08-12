//
//  MetalViewController.swift
//  SwiftMetalForOSX
//
//  Created by Amund Tveit on 10/06/15.
//  Copyright © 2015 Amund Tveit. All rights reserved.
//

import Foundation
import Cocoa
import Metal
import MetalKit
import QuartzCore


//@available(OSX 10.11, *)
@available(OSX 10.11, *)
class MetalViewController : NSViewController {
    
    var metalDevice:MTLDevice!
    var metalCommandQueue:MTLCommandQueue!
    var metalDefaultLibrary:MTLLibrary!
    var metalCommandBuffer:MTLCommandBuffer!
    var metalComputeCommandEncoder:MTLComputeCommandEncoder!
    
    
    func setupMetal() {
        // Get access to iPhone or iPad GPU
        metalDevice = MTLCreateSystemDefaultDevice()
        
        // Queue to handle an ordered list of command buffers
        metalCommandQueue = metalDevice.newCommandQueue()
        
        // Access to Metal functions that are stored in Shaders.metal file, e.g. sigmoid()
        metalDefaultLibrary = metalDevice.newDefaultLibrary()
        
        // Buffer for storing encoded commands that are sent to GPU
        metalCommandBuffer = metalCommandQueue.commandBuffer()
    }
    
    
    func setupShaderInMetalPipeline(shaderName:String) -> (shader:MTLFunction!,
        computePipelineState:MTLComputePipelineState!,
        computePipelineErrors:NSErrorPointer!)  {
            
            var shader = metalDefaultLibrary.newFunctionWithName(shaderName)
            var computePipeLineDescriptor = MTLComputePipelineDescriptor()
            computePipeLineDescriptor.computeFunction = shader
            //        var computePipelineErrors = NSErrorPointer()
            //            let computePipelineState:MTLComputePipelineState = metalDevice.newComputePipelineStateWithFunction(shader!, completionHandler: {(})
            var computePipelineErrors = NSErrorPointer()
            var computePipelineState:MTLComputePipelineState? = nil
            do {

//                computePipelineState = try metalDevice.newComputePipelineStateWithDescriptor(computePipeLineDescriptor)
                    computePipelineState = try metalDevice.newComputePipelineStateWithFunction(shader!)
            } catch {
                print("catching..")
            }
            return (shader, computePipelineState, computePipelineErrors)
            
    }
    
    func createMetalBuffer(var vector:[Float]) -> MTLBuffer {
        let byteLength = vector.count*sizeof(Float)
        return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
    
    
}

