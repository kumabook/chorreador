# chorreador
## About
chorreador is JavaScript based JavaScript profiler.
This tool aims to analysis JavaScript on broswers that don't have native profiler such as "Chrome Developer Tool".

chorreador is inspired by esmorph: https://github.com/ariya/esmorph.
Thank the creator of esmorph.
And chorreador uses esprima, estraverse, escodegen, and jsdom.
Thank these library creators and contributors, too.

## How to use
- First, install dependencies:
```
    $ npm install -g coffee-script
    $ npm install
```
- Copy the html and JavaScripts that you want to profile
  to directory. ex 'instrumented/'.
- Run chorreador `server` sub command:
```
    $ bin/chorreador server
```
- Open the html with Browser, ex: http://localhost:3000/instrumented/index.html
- Then, print the summary of javascript traces on console.

- `instrument` sub command just generate instrumented code.

```
    $ bin/chorreador instrument xxxx.js
```

## License

Copyright (C) 2014 Hiroki Kumamoto (twitter: @kumabook).

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
