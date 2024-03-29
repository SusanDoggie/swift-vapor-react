//
//  NIOJSContext.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public class NIOJSContext {
    
    private let context: JSContext
    
    public let threadPool: NIOThreadPool = NIOThreadPool(numberOfThreads: 1)
    
    public var logger: (() -> Logger?)?
    
    public init() {
        self.context = JSContext()
        self.context.polyfill(self)
    }
    
    public init(context: JSContext) {
        self.context = context
    }
}

extension NIOJSContext {
    
    public func start() {
        self.threadPool.start()
    }
    
    public func shutdownGracefully(_ callback: @escaping (Error?) -> Void) {
        self.threadPool.shutdownGracefully(callback)
    }
    
    public func syncShutdownGracefully() throws {
        try self.threadPool.syncShutdownGracefully()
    }
}

extension NIOJSContext {
    
    public func run<T>(callback: @escaping (JSContext) throws -> T) rethrows -> T {
        return try callback(self.context)
    }
    
    public func run<T>(eventLoop: EventLoop, callback: @escaping (JSContext) throws -> T) -> EventLoopFuture<T> {
        
        return self.threadPool.runIfActive(eventLoop: eventLoop) {
            try callback(self.context)
        }
    }
}
