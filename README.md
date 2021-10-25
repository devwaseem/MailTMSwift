# MailTMSwift

<p align="center">
<a href="https://github.com/devwaseem/MailTMSwift/actions/workflows/swift.yml"><img src="https://github.com/devwaseem/MailTMSwift/actions/workflows/swift.yml/badge.svg"></a>
<a href="https://"><img src="https://img.shields.io/github/v/release/devwaseem/MailTMSwift?display_name=tag"></a>
<a href="https://mailtmswift.waseem.works"><img src="https://img.shields.io/badge/Swift-Doc-DE5C43.svg?style=flat"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<img src="https://img.shields.io/badge/Combine-supported-DE5C43.svg">
<br />
<a href="https://raw.githubusercontent.com/devwaseem/MailTMSwift/main/LICENSE"><img src="https://img.shields.io/github/license/devwaseem/mailtmswift"></a>
<img src="https://img.shields.io/badge/platforms-iOS|macOS|watchOS|tvOS-FFFFF3.svg">
</p>

<p align="center">MailTMSwift is a Lightweight Swift Wrapper for https://mail.tm API (A Temp Mail Service).</p>
  
## Documentation

- Documentation is generated from Apple's DocC and is hosted on [here](https://mailtmswift.waseem.works)
- The mail.tm api is documented [here](https://api.mail.tm/)

## Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/devwaseem/MailTMSwift.git`
- Select "Up to Next Major" with "1.1.1"

## Supported platforms
| Platform | Supported versions |
| -------- | ------------------ |
| iOS      | 11+                |
| MacOS    | 10.12+             |
| watchOS  | 4+                 |
| tvOS     | 11+                |

## Highlights
-[x] Simple interface

-[x] Combine support

-[x] Live updates using SSE

-[x] Cancel ongoing request
## Getting started

### Introduction
All the methods in this package support Combine. Retaining AnyCancellables will take care of canceling the ongoing API request when the retaining class is deinitialized. However, to cancel ongoing API requests when using completion handler supported methods, use [MTAPIServiceTask](https://mailtmswift.waseem.works/documentation/mailtmswift/mtapiservicetask).

The Helper classes [`MTAccountService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtaccountservice), [`MTMessageService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtmessageservice), [`MTDomainService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtdomainservice) are _Stateless_ classes, so you are free to create multiple instances of it, without creating any side effects. If you use a dependency container, store the instance of the class and store it as `Application` or `Singleton` scope.

### Creating an account

```swift
import MailTMSwift

let auth = MTAuth(address: "address@domain.com", password: "12345678")
let accountService = MTAccountService()
accountService.createAccount(using: auth) { (accountResult: Result<MTAccount, MTError>) in
  switch accountResult {
    case .success(let account):
      print("Created an account \(account)")
    case .failure(let error):
      print("Error occurred \(error)")
  }
}
```
### Login with existing Account

`createAccount(using:)` returns account document but not JWT token. You need JWT token to authorize protected endpoints.

To fetch the JWT token:

```swift
import MailTMSwift

let auth = MTAuth(address: "address@domain.com", password: "12345678")
let accountService = MTAccountService()
accountService.login(using: auth) { (result: Result<String, MTError>) in
  switch result {
    case .success(let token):
      print("got JWT: \(token)")
    case .failure(let error):
      print("Error occurred \(error)")
  }
}
```

### Deleting an account

```swift
import MailTMSwift

let id = // Account ID
let token = // Account JWT token
let accountService = MTAccountService()
accountService.deleteAccount(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
    if case let .failure(error) = result {
        print("Error Occurred: \(error)")
    }
    
    // Account deleted
    doSomething()
}
```

### Fetching available domains
### Get all messages
### Mark message as seen
### Get source of a message
### Deleteing a message
### Listening for live events
 
## License

MailTMSwift is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/devwaseem/MailTMSwift/main/LICENSE) for details.

```
Copyright (c) 2021 Waseem akram

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
```
