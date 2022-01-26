//
//  polyfill.swift
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

extension JSContext {
    
    func polyfill(_ context: NIOJSContext) {
        
        global["self"] = global
        
        let console = JSObject(newObjectIn: self)
        
        console["debug"] = JSObject(newFunctionIn: self) { [weak context] _context, this, args in
            let logger = context?.logger?()
            logger?.debug("\(args.map { "\($0)" }.joined(separator: " "))")
            return JSObject(undefinedIn: _context)
        }
        
        console["info"] = JSObject(newFunctionIn: self) { [weak context] _context, this, args in
            let logger = context?.logger?()
            logger?.info("\(args.map { "\($0)" }.joined(separator: " "))")
            return JSObject(undefinedIn: _context)
        }
        
        console["log"] = JSObject(newFunctionIn: self) { [weak context] _context, this, args in
            let logger = context?.logger?()
            logger?.notice("\(args.map { "\($0)" }.joined(separator: " "))")
            return JSObject(undefinedIn: _context)
        }
        
        console["warn"] = JSObject(newFunctionIn: self) { [weak context] _context, this, args in
            let logger = context?.logger?()
            logger?.warning("\(args.map { "\($0)" }.joined(separator: " "))")
            return JSObject(undefinedIn: _context)
        }
        
        console["error"] = JSObject(newFunctionIn: self) { [weak context] _context, this, args in
            let logger = context?.logger?()
            logger?.error("\(args.map { "\($0)" }.joined(separator: " "))")
            return JSObject(undefinedIn: _context)
        }
        
        global["console"] = console
    }
}
