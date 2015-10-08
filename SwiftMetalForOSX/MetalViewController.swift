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

struct Vector4 // matches float4 in Metal
{
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    var w: Float = 0.0
}

struct Vector2 // matches float2 in Metal
{
    var x: Float = 0.0
    var y: Float = 0.0
}

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
//        metalDevice = MTLCreateSystemDefaultDevice()
        metalDevice = MTLCopyAllDevices()[1]
        
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
            
            let shader = metalDefaultLibrary.newFunctionWithName(shaderName)
            let computePipeLineDescriptor = MTLComputePipelineDescriptor()
            computePipeLineDescriptor.computeFunction = shader
            //        var computePipelineErrors = NSErrorPointer()
            //            let computePipelineState:MTLComputePipelineState = metalDevice.newComputePipelineStateWithFunction(shader!, completionHandler: {(})
            let computePipelineErrors = NSErrorPointer()
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
    
    func createFloatNumbersArray(count: Int) -> [Float] {
        return [Float](count: count, repeatedValue: 0.0)
    }
    
    func createVector4Array(count: Int) -> [Vector4] {
        let zeroVector4 = Vector4()
        return [Vector4](count: count, repeatedValue: zeroVector4)
    }
    
    
    func createVector4MetalBuffer(var vector: [Vector4], let metalDevice:MTLDevice) -> MTLBuffer {
        let byteLength = vector.count*sizeof(Vector4)
        return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
    
    func createVector2Array(count: Int) -> [Vector2] {
        let zeroVector2 = Vector2()
        return [Vector2](count: count, repeatedValue: zeroVector2)
    }
    
    
    func createVector2MetalBuffer(var vector: [Vector2], let metalDevice:MTLDevice) -> MTLBuffer {
        let byteLength = vector.count*sizeof(Vector2)
        return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }

    
    func createFloatMetalBuffer(var vector: [Float], let metalDevice:MTLDevice) -> MTLBuffer {
        let byteLength = vector.count*sizeof(Float) // future: MTLResourceStorageModePrivate
        return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
}

