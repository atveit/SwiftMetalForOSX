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
        
        // Create input and output vectors, and corresponding metal buffer
        let N = 100
        let inputVector = createInputVector(N)
        var outputVector = doublerWithMetal(inputVector)
        print("input = \(inputVector)")
        print("output = \(outputVector)")
        exit(0)
    }
    
    func doublerWithMetal(inputVector:[Float]) -> [Float] {
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
        
        print("outputVector before job is running: \(outputVector)")
        
        // Start job
        metalCommandBuffer.commit()
        
        // Wait for it to finish
        metalCommandBuffer.waitUntilCompleted()
        
        // Get output data from Metal/GPU into Swift
        let data = NSData(bytesNoCopy: outputMetalBuffer.contents(),
            length: outputVector.count*sizeof(Float), freeWhenDone: false)
        data.getBytes(&outputVector, length:inputVector.count * sizeof(Float))
        
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

