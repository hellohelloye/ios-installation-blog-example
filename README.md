# Example use of private iOS APIs

This is an example project that accompanies [this blog post](http://testlio.com/blog), please read that first! The project in this repository demonstrates opening and installation of applications from within another application, relying on Over-the-Air distribution and private APIs in MobileCoreServices.framework.

## Usage

Simply download the sample code and build it in Xcode. The code was created using Xcode 6.4 and Swift 1.2, the application is meant to be run on a device, but does also run on the simulator (the installation of applications does not work, as the `itms-services` scheme is not supported).

There are two methods outlined in [`ViewController.swift`](Example/ViewController.swift#L46). If you wish to use the first, which also allows installation of an application, you need to provide a URL to a valid manifest property list file. An example of such a file (with a few blanks) is provided in the project ([Manifest.plist](Example/Manifest.plist)).

## About Us

[Some standard sign-off for our open source repositories]

## License

The MIT License (MIT)

Copyright (c) 2015 Testlio, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
