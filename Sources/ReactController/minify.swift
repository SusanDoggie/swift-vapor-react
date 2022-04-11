//
//  minify.swift
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
    
    func minify() -> JSObject {
        
        return self.evaluateScript("""
            r => {
                function _compress(r, e, o) {
                    if (null == r) return "";
                    var t, a, h, f = {},
                        p = {},
                        c = "",
                        s = "",
                        n = "",
                        u = 2,
                        l = 3,
                        i = 2,
                        A = [],
                        d = 0,
                        C = 0;
                    for (h = 0; h < r.length; h += 1)
                        if (c = r.charAt(h), Object.prototype.hasOwnProperty.call(f, c) || (f[c] = l++, p[c] = !0), s = n + c, Object.prototype.hasOwnProperty.call(f, s)) n = s;
                        else {
                            if (Object.prototype.hasOwnProperty.call(p, n)) {
                                if (n.charCodeAt(0) < 256) {
                                    for (t = 0; t < i; t++) d <<= 1, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++;
                                    for (a = n.charCodeAt(0), t = 0; t < 8; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1
                                } else {
                                    for (a = 1, t = 0; t < i; t++) d = d << 1 | a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a = 0;
                                    for (a = n.charCodeAt(0), t = 0; t < 16; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1
                                }
                                0 == --u && (u = Math.pow(2, i), i++), delete p[n]
                            } else
                                for (a = f[n], t = 0; t < i; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1;
                            0 == --u && (u = Math.pow(2, i), i++), f[s] = l++, n = String(c)
                        } if ("" !== n) {
                        if (Object.prototype.hasOwnProperty.call(p, n)) {
                            if (n.charCodeAt(0) < 256) {
                                for (t = 0; t < i; t++) d <<= 1, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++;
                                for (a = n.charCodeAt(0), t = 0; t < 8; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1
                            } else {
                                for (a = 1, t = 0; t < i; t++) d = d << 1 | a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a = 0;
                                for (a = n.charCodeAt(0), t = 0; t < 16; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1
                            }
                            0 == --u && (u = Math.pow(2, i), i++), delete p[n]
                        } else
                            for (a = f[n], t = 0; t < i; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1;
                        0 == --u && (u = Math.pow(2, i), i++)
                    }
                    for (a = 2, t = 0; t < i; t++) d = d << 1 | 1 & a, C == e - 1 ? (C = 0, A.push(o(d)), d = 0) : C++, a >>= 1;
                    for (;;) {
                        if (d <<= 1, C == e - 1) {
                            A.push(o(d));
                            break
                        }
                        C++
                    }
                    return A.join("")
                }
                const altAlpha = ":;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz",
                decompressFunc = 'o=>{function r(r){for(i=f=0;i<r;)A<2&&(A=64,a=92<(a=o.charCodeAt(C++))?a-59:a-58),f|=(0<(a&(A/=2)))<<i,++i}for(var n,f,i,t,a,e=[],u=1,_=3,c=1,h=[],A=0,C=0;;){if(r(c+1),2==f)return eval(h.join(""));-2&(t=f)||(r(8*f+8),e[t=_++]=String.fromCharCode(f),--u||(u=2<<c++)),h.push(t=e[t]||n+n[0]),n&&(e[_++]=n+t[0],--u||(u=2<<c++)),n=t}}';
                const e = _compress(r, 6, r => altAlpha.charAt(r));
                return `(${decompressFunc})('${e}')`
            };
            """)
    }
}
