//
//  ReactController.swift
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
    
    func check_exception() throws {
        
        if let exception = self.exception {
            
            #if DEBUG
            
            print("Error message:", exception["message"].stringValue ?? "")
            print("stack:", exception["stack"].stringValue ?? "")
            
            #endif
            
            throw ReactController.Error(message: exception["message"].stringValue)
        }
    }
}

public class ReactController: RouteCollection {
    
    public var root: String
    public var bundle: String
    
    #if DEBUG
    
    public var serverSideRenderEnabled: Bool = false
    
    #else
    
    public var serverSideRenderEnabled: Bool = true
    
    #endif
    
    public var preloadedStateHandler: ((Request) -> EventLoopFuture<Json>)?
    
    public var preloadedStateUpdateHandler: ((Request, Json) -> EventLoopFuture<Json?>)?
    
    public var logger: Logger?
    
    let context: NIOJSContext
    var render: JSObject!
    var minify: JSObject!
    
    public init(bundle: String, serverScript: URL, root: String = "root") throws {
        self.bundle = bundle
        self.root = root
        self.context = NIOJSContext()
        
        self.context.logger = { [weak self] in self?.logger }
        self.context.start()
        
        try self.context.run { context in
            
            try context.evaluateScript(String(contentsOf: serverScript))
            try context.check_exception()
            
            self.render = context.global["render"]
            self.minify = context.minify()
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
    
    struct Template {
        
        var statusCode: Int?
        
        var url: String?
        
        var meta: [String] = []
        
        var css: String = ""
        
        var html: String = ""
        
        var preloadedState: Json?
        
        var minified: String?
    }
}

extension ReactController {
    
    private func html_template(
        _ meta: [String],
        _ css: String,
        _ html: String,
        _ preloadedState: String
    ) -> String {
        
        return """
        <!doctype html>
        <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no, viewport-fit=cover">
                \(meta.joined(separator: "\n"))
                <style>
                    html, body {
                        width: 100%;
                        height: 100%;
                    }
                    #\(self.root) {
                        display: flex;
                        width: 100%;
                        height: 100%;
                    }
                    @media (orientation: landscape) {
                        html, body {
                            width: 100vw;
                            height: 100vh;
                        }
                        #\(self.root) {
                            position: fixed;
                        }
                    }
                </style>
                \(css)
            </head>
            <body>
                <div id="\(self.root)">\(html)</div>
                \(preloadedState)
                <script src="\(self.bundle)"></script>
            </body>
        </html>
        """
    }
}

extension ReactController {
    
    private func _template(_ req: Request) -> EventLoopFuture<Template> {
        
        let template = self.preloadedStateHandler?(req).flatMap { self._template(req, $0) } ?? self._template(req, nil)
        
        if let handler = self.preloadedStateUpdateHandler {
            return template.flatMap { self._template(req, $0, handler) }
        }
        
        return template
    }
    
    private func _template(
        _ req: Request,
        _ template: Template,
        _ handler: @escaping (Request, Json) -> EventLoopFuture<Json?>
    ) -> EventLoopFuture<Template> {
        
        guard let state = template.preloadedState else {
            return req.eventLoop.makeSucceededFuture(template)
        }
        
        return handler(req, state).flatMap { next in
            
            guard let next = next else {
                return req.eventLoop.makeSucceededFuture(template)
            }
            
            return self._template(req, next)
        }
    }
    
    private func _template(_ req: Request, _ preloadedState: Json?) -> EventLoopFuture<Template> {
        
        if serverSideRenderEnabled {
            
            return context.run(eventLoop: req.eventLoop) { context in
                
                var location: Json = ["pathname": "\(req.url.path)"]
                if let query = req.url.query { location["search"] = "?\(query)" }
                if let fragment = req.url.fragment { location["hash"] = "#\(fragment)" }
                
                var arguments = [location]
                if let state = preloadedState {
                    arguments.append(state)
                }
                
                let result = self.render.call(withArguments: arguments)
                try context.check_exception()
                
                var preloadedState = preloadedState
                
                if result.hasProperty("preloadedState") {
                    preloadedState = result["preloadedState"].toJson()
                }
                
                let meta = result["meta"].dictionary ?? [:]
                
                var meta_string: [String] = []
                if let title = result["title"].stringValue {
                    meta_string.append("<title>\(title)</title>")
                }
                for (name, content) in meta {
                    guard let content = content.stringValue else { continue }
                    meta_string.append("<meta name=\"\(name)\" content=\"\(content)\">")
                }
                
                let compressed = self.minify.call(withArguments: ["window.__PRELOADED_STATE__ = \(preloadedState?.json() ?? "{}")"])
                try self.minify.context.check_exception()
                
                return Template(
                    statusCode: result["statusCode"].doubleValue.flatMap(Int.init(exactly:)),
                    url: result["url"].stringValue,
                    meta: meta_string,
                    css: result["css"].stringValue ?? "",
                    html: result["html"].stringValue ?? "",
                    preloadedState: preloadedState,
                    minified: compressed.stringValue
                )
            }
            
        } else {
            
            return req.eventLoop.makeSucceededFuture(Template(preloadedState: preloadedState))
        }
    }
    
    private func html(_ req: Request) -> EventLoopFuture<Response> {
        
        return self._template(req).flatMapThrowing { template in
            
            var _preloadedState: String = ""
            
            if let state = template.minified {
                _preloadedState = "<script>\(state)</script>"
            } else if let state = template.preloadedState {
                _preloadedState = "<script>window.__PRELOADED_STATE__ = \(state.json() ?? "{}")</script>"
            }
            
            if self.serverSideRenderEnabled {
                
                if let url = template.url {
                    return req.redirect(to: url)
                }
                
                var headers = HTTPHeaders()
                headers.contentType = .html
                headers.cacheControl = .init(noCache: true)
                
                let body = Response.Body(string: self.html_template(template.meta, template.css, template.html, _preloadedState))
                
                return Response(status: .init(statusCode: template.statusCode ?? 200), headers: headers, body: body)
                
            } else {
                
                var headers = HTTPHeaders()
                headers.contentType = .html
                headers.cacheControl = .init(noCache: true)
                
                let body = Response.Body(string: self.html_template([], "", "", _preloadedState))
                
                return Response(status: .ok, headers: headers, body: body)
            }
        }
    }
    
}
