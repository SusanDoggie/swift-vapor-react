//
//  ReactController.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

public class ReactController: RouteCollection {
    
    public var root: String
    public var bundle: String
    
    let context: NIOJSContext
    
    public init(bundle: String, serverScript: URL, root: String = "root", eventLoop: EventLoop) throws {
        self.bundle = bundle
        self.root = root
        self.context = NIOJSContext()
        
        self.context.start()
        
        try self.context.run(eventLoop: eventLoop) {
            
            $0["self"] = $0.global
            
            try $0.evaluateScript(String(contentsOf: serverScript))
            
            if let exception = $0.exception {
                throw Error(message: exception.stringValue)
            }
        }.wait()
    }
    
    deinit {
        context.shutdownGracefully { _ in }
    }
    
    public func boot(routes: RoutesBuilder) throws {
        
        routes.get { req -> EventLoopFuture<Response> in
            
            self.html(req.url.path, eventLoop: req.eventLoop).map { html in
                
                let response = Response(status: .ok, body: .init(string: html))
                response.headers.contentType = .html
                return response
            }
        }
        
        routes.get("**") { req -> EventLoopFuture<Response> in
            
            self.html(req.url.path, eventLoop: req.eventLoop).map { html in
                
                let response = Response(status: .ok, body: .init(string: html))
                response.headers.contentType = .html
                return response
            }
        }
    }
}

extension ReactController {
    
    public struct Error: Swift.Error {
        
        public var message: String?
    }
    
    private func html(_ path: String, eventLoop: EventLoop) -> EventLoopFuture<String> {
        
        return context.run(eventLoop: eventLoop) { context in
            
            let result = context.global.invokeMethod("render", withArguments: [JSObject(string: path, in: context)])
            
            if let exception = context.exception {
                throw Error(message: exception.stringValue)
            }
            
            let html = result["html"].stringValue ?? ""
            let css = result["css"].stringValue ?? ""
            
            return """
            <!doctype html>
            <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
                    <style>
                        html,
                        body {
                            height: 100%;
                        }
                        body {
                            overflow: hidden;
                        }
                        #\(self.root) {
                            display: flex;
                            height: 100%;
                        }
                    </style>
                    \(css)
                </head>
                <body>
                    <div id="\(self.root)">\(html)</div>
                    <script src="\(self.bundle)"></script>
                </body>
            </html>
            """
        }
    }
}
