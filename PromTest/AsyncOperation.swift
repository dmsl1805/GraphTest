//  Operation.swift
//
//  Created by Dmitriy Shulzhenko on 9/2/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

typealias AsyncOperationExecutionBlock = (_ currentOperation: AsyncOperation) -> Void

class AsyncOperation : Operation, OperationWithObjectStorage {

    private var storage: TrailingObjectProtocol?
    
    open var executionBlocks: [AsyncOperationExecutionBlock]
    
    open func addExecutionBlock(_ block: @escaping AsyncOperationExecutionBlock) {
        executionBlocks.append(block)
    }

    public func getStorage() -> TrailingObjectProtocol { return storage! }
    
    public func setStorage(_ storage: TrailingObjectProtocol) { self.storage = storage }
    
    override func addDependency(_ op: Operation) {
        super.addDependency(op)
        setStorage((op as! OperationWithObjectStorage).getStorage())
    }
    
    private var currentExecuting: Bool = false {
        willSet {  willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    
    override var isExecuting: Bool {
        get { return currentExecuting }
        set {
            guard currentExecuting != newValue else { return }
            currentExecuting = newValue
        }
    }
    
    private var currentFinished: Bool = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    override var isFinished: Bool {
        get { return currentFinished }
        set {
            guard currentFinished != newValue else { return }
            currentFinished = newValue
        }
    }
    
    private var currentCancelled: Bool = false{
        willSet { willChangeValue(forKey: "isCancelled") }
        didSet { didChangeValue(forKey: "isCancelled") }
    }
    
    override var isCancelled: Bool {
        get { return currentCancelled }
        set {
            guard currentCancelled != newValue else { return }
            currentCancelled = newValue
        }
    }
    
    private var isAsync: Bool = true
    override var isAsynchronous: Bool { return isAsync }
    
    override func start() {
        guard !isCancelled && !isFinished else { return }
        isExecuting = true
        isFinished = false
        for block in executionBlocks {
            block(self)
        }
        print("\(self) started")
    }
    
//    override func main() {
//        
//    }
    
    public init(trailingObject: TrailingObjectProtocol?, isAsync: Bool, executionBlock: @escaping AsyncOperationExecutionBlock) {
        self.storage = trailingObject
        self.executionBlocks = [executionBlock]
        self.isAsync = isAsync
    }
    
    public convenience init(_ executionBlock: @escaping AsyncOperationExecutionBlock) {
        self.init(trailingObject: nil, isAsync: true, executionBlock: executionBlock)
    }

    public func finish() -> Void {
        print("\(self) finished")
        currentExecuting = false
        currentFinished = true
    }
}
