//
//  ViewController.swift
//  SwiftMetalForOSX
//
//  Created by Amund Tveit on 10/06/15.
//  Copyright © 2015 Amund Tveit. All rights reserved.
//

import Cocoa
import Metal

@available(OSX 10.11, *)

class ViewController: MetalViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let start = NSDate()
        
        // Create input and output vectors, and corresponding metal buffer
        let N = 32000000
        let in1 = createInputVector(N)
        //let in2 = createInputVector(N)
        let out1 = multWithMetal(in1, in2: in1)
        //print("input = \(inputVector)")
        //print("output = \(outputVector)")
        
        let M = N/2
        //let in1f2 = createVector2Array(M)
        //let in2f2 = createVector2Array(M)
        //let out2 = multWithMetalF2(in1f2, in2: in1f2)
        
        
        let K = N/4
        //let in1f4 = createVector4Array(K)
        //let in2f4 = createVector4Array(K)
        //let out4 = multWithMetalF4(in1f4, in2: in1f4)
        
        print("Time to run entire job: \(NSDate().timeIntervalSinceDate(start))")

        
        exit(0)
    }
    
    func doublerWithMetal(inputVector:[Float]) -> [Float] {
        print("multWithMetal Float")
        // uses metal to calculate double array
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("doubler")
        let inputMetalBuffer = createMetalBuffer(inputVector)
        var outputVector = [Float](count: inputVector.count, repeatedValue: 0.0)
        let outputMetalBuffer = createMetalBuffer(outputVector)
        
        // Create Metal Compute Command Encoder and add input and output buffers to it
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(inputMetalBuffer, offset: 0, atIndex: 0)
        metalComputeCommandEncoder.setBuffer(outputMetalBuffer, offset: 0, atIndex: 1)
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Find max number of parallel GPU threads (threadExecutionWidth) in computePipelineState
        let threadExecutionWidth = computePipelineState.threadExecutionWidth
        
        // Set up thread groups on GPU
        let threadsPerGroup = MTLSize(width:threadExecutionWidth,height:1,depth:1)
        let numThreadgroups = MTLSize(width:(inputVector.count+threadExecutionWidth)/threadExecutionWidth, height:1, depth:1)
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
        
        print("outputVector before job is running: \(outputVector.count)")
        
        // Start job
        var start = NSDate()
        metalCommandBuffer.commit()
        
        // Wait for it to finish
        metalCommandBuffer.waitUntilCompleted()
        
        print("Time to run network: \(NSDate().timeIntervalSinceDate(start))")

        
        // Get output data from Metal/GPU into Swift
        let data = NSData(bytesNoCopy: outputMetalBuffer.contents(),
            length: outputVector.count*sizeof(Float), freeWhenDone: false)
        data.getBytes(&outputVector, length:inputVector.count * sizeof(Float))
        
        return outputVector
        
    }
    
    func multWithMetalF2(in1:[Vector2], in2:[Vector2]) -> [Vector2] {
        print("multWithMetal Float2")
        // uses metal to calculate double array
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("multvfloat2")
        let in1Metal = createVector2MetalBuffer(in1, metalDevice: metalDevice)
        let in2Metal = createVector2MetalBuffer(in2, metalDevice: metalDevice)
        var outputVector = createVector2Array(in1.count)
        let outputMetalBuffer = createVector2MetalBuffer(outputVector, metalDevice: metalDevice)
        
        // Create Metal Compute Command Encoder and add input and output buffers to it
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(in1Metal, offset: 0, atIndex: 0)
        metalComputeCommandEncoder.setBuffer(in2Metal, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(outputMetalBuffer, offset: 0, atIndex: 2)
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Find max number of parallel GPU threads (threadExecutionWidth) in computePipelineState
        let threadExecutionWidth = computePipelineState.threadExecutionWidth
        
        // Set up thread groups on GPU
        let threadsPerGroup = MTLSize(width:threadExecutionWidth,height:1,depth:1)
        let numThreadgroups = MTLSize(width:(in1.count)/threadExecutionWidth, height:1, depth:1)
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
        
        print("outputVector before job is running: \(outputVector.count)")
        
        // Start job
        metalCommandBuffer.enqueue()
        
        var start = NSDate()
        metalCommandBuffer.commit()
        
        // Wait for it to finish
        metalCommandBuffer.waitUntilCompleted()
        
        print("Time to run network: \(NSDate().timeIntervalSinceDate(start))")
        
        
        // Get output data from Metal/GPU into Swift
        let data = NSData(bytesNoCopy: outputMetalBuffer.contents(),
            length: outputVector.count*sizeof(Vector2), freeWhenDone: false)
        data.getBytes(&outputVector, length:in1.count * sizeof(Vector2))
        
        return outputVector
        
    }
    
    func multWithMetalF4(in1:[Vector4], in2:[Vector4]) -> [Vector4] {
        print("multWithMetal Float4")
        // uses metal to calculate double array
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("multvfloat4")
        let in1Metal = createVector4MetalBuffer(in1, metalDevice: metalDevice)
        let in2Metal = createVector4MetalBuffer(in2, metalDevice: metalDevice)
        var outputVector = createVector4Array(in1.count)
        let outputMetalBuffer = createVector4MetalBuffer(outputVector, metalDevice: metalDevice)
        
        // Create Metal Compute Command Encoder and add input and output buffers to it
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(in1Metal, offset: 0, atIndex: 0)
        metalComputeCommandEncoder.setBuffer(in2Metal, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(outputMetalBuffer, offset: 0, atIndex: 2)
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Find max number of parallel GPU threads (threadExecutionWidth) in computePipelineState
        let threadExecutionWidth = computePipelineState.threadExecutionWidth
        
        // Set up thread groups on GPU
        let threadsPerGroup = MTLSize(width:threadExecutionWidth,height:1,depth:1)
        let numThreadgroups = MTLSize(width:(in1.count)/threadExecutionWidth, height:1, depth:1)
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
        
        print("outputVector before job is running: \(outputVector.count)")
        
        // Start job
        metalCommandBuffer.enqueue()
        
        var start = NSDate()
        metalCommandBuffer.commit()
        
        // Wait for it to finish
        metalCommandBuffer.waitUntilCompleted()
        
        print("Time to run network: \(NSDate().timeIntervalSinceDate(start))")
        
        
        // Get output data from Metal/GPU into Swift
        let data = NSData(bytesNoCopy: outputMetalBuffer.contents(),
            length: outputVector.count*sizeof(Vector4), freeWhenDone: false)
        data.getBytes(&outputVector, length:in1.count * sizeof(Vector4))
        
        return outputVector
        
    }
    
    func multWithMetal(in1:[Float], in2:[Float]) -> [Float] {
        // uses metal to calculate double array
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("multvfloat")
        let in1Metal = createMetalBuffer(in1)
        let in2Metal = createMetalBuffer(in2)
        var outputVector = [Float](count: in1.count, repeatedValue: 0.0)
        let outputMetalBuffer = createMetalBuffer(outputVector)
        
        // Create Metal Compute Command Encoder and add input and output buffers to it
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(in1Metal, offset: 0, atIndex: 0)
        metalComputeCommandEncoder.setBuffer(in2Metal, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(outputMetalBuffer, offset: 0, atIndex: 2)
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Find max number of parallel GPU threads (threadExecutionWidth) in computePipelineState
        let threadExecutionWidth = computePipelineState.threadExecutionWidth
        
        // Set up thread groups on GPU
        let threadsPerGroup = MTLSize(width:threadExecutionWidth,height:1,depth:1)
        let numThreadgroups = MTLSize(width:(in1.count)/threadExecutionWidth, height:1, depth:1)
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
        
        print("outputVector before job is running: \(outputVector.count)")
        
        // Start job
        metalCommandBuffer.enqueue()
        
        var start = NSDate()
        metalCommandBuffer.commit()
        
        // Wait for it to finish
        metalCommandBuffer.waitUntilCompleted()
        
        print("Time to run network: \(NSDate().timeIntervalSinceDate(start))")
        
        
        // Get output data from Metal/GPU into Swift
        let data = NSData(bytesNoCopy: outputMetalBuffer.contents(),
            length: outputVector.count*sizeof(Float), freeWhenDone: false)
        data.getBytes(&outputVector, length:in1.count * sizeof(Float))
        
        return outputVector
        
    }

    
    func createInputVector(N: Int) -> [Float] {
        var vector = [Float](count: N, repeatedValue: 0.0)
        for (index, _) in vector.enumerate() {
            vector[index] = Float(index)
        }
        return vector
    }
    
    
    
}

