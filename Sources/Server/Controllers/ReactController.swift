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
    
    public init(bundle: String, serverScript: URL, root: String = "root") throws {
        self.bundle = bundle
        self.root = root
        self.context = NIOJSContext()
        
        self.context.start()
        
        try self.context.run {
            
            try $0.evaluateScript(String(contentsOf: serverScript))
            
            if let exception = $0.exception {
                throw Error(message: exception["message"].stringValue)
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
}

extension ReactController {
    
    private func html(_ req: Request) throws -> EventLoopFuture<Response> {
        
        return context.run(eventLoop: req.eventLoop) { context in
            
            var location: Json = ["pathname": "\(req.url.path)"]
            if let query = req.url.query { location["search"] = "?\(query)" }
            if let fragment = req.url.fragment { location["hash"] = "#\(fragment)" }
            
            let result = context.global["render"].call(withArguments: [JSObject(json: location, in: context)])
            
            if let exception = context.exception {
                throw Abort(.internalServerError, reason: exception["message"].stringValue)
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
