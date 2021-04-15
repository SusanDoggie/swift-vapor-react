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
    var render: JSObject?
    
    public init(bundle: String, serverScript: URL, root: String = "root") throws {
        self.bundle = bundle
        self.root = root
        self.context = NIOJSContext()
        
        self.context.start()
        
        try self.context.run {
            
            $0["self"] = $0.global
            
            try $0.evaluateScript(String(contentsOf: serverScript))
            
            self.render = $0.global["render"]
            self.render?.freeze()
            
            $0.global.removeProperty("render")
            $0.garbageCollect()
            
            if let exception = $0.exception {
                throw Error(message: exception.stringValue)
            }
        }
    }
    
    deinit {
        context.shutdownGracefully { _ in }
    }
    
    public func boot(routes: RoutesBuilder) throws {
        routes.get(use: self.html)
        routes.get("**", use: self.html)
    }
}

extension ReactController {
    
    public struct Error: Swift.Error {
        
        public var message: String?
    }
    
    private func html(_ req: Request) throws -> EventLoopFuture<Response> {
        
        return context.run(eventLoop: req.eventLoop) { context in
            
            guard let render = self.render else { throw Abort(.internalServerError) }
            
            let result = render.call(withArguments: [JSObject(string: req.url.path, in: context)]).toJson() ?? [:]
            
            if let exception = context.exception {
                throw Error(message: exception.stringValue)
            }
            
            if let url = result["url"].stringValue {
                return req.redirect(to: url)
            }
            
            let html = result["html"].stringValue ?? ""
            let css = result["css"].stringValue ?? ""
            
            let statusCode = result["statusCode"].doubleValue.flatMap(Int.init(exactly:)) ?? 200
            let meta = result["meta"].dictionary ?? [:]
            
            var meta_string: [String] = []
            if let title = result["title"].stringValue {
                meta_string.append("<title>\(title)</title>")
            }
            for (name, content) in meta {
                guard let content = content.stringValue else { continue }
                meta_string.append("<meta name=\"\(name)\" content=\"\(content)\">")
            }
            
            var headers = HTTPHeaders()
            headers.contentType = .html
            
            let body = Response.Body(string: """
            <!doctype html>
            <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
                    \(meta_string.joined(separator: "\n"))
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
            """)
            
            return Response(status: .init(statusCode: statusCode), headers: headers, body: body)
        }
    }
}
