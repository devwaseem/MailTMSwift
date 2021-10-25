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

## Used by
[Tempbox](https://github.com/devwaseem/TempBox) - An opensource disposable email client for MacOS powered by [Mail.tm](https://mail.tm)

[![Tempbox](https://user-images.githubusercontent.com/12982964/136702592-b793d676-fd61-41a9-aa61-1f459787999a.png)](https://github.com/devwaseem/TempBox)
  
## Documentation

- Documentation is generated from Apple's DocC and is hosted on [here](https://mailtmswift.waseem.works)
- The mail.tm api is documented [here](https://api.mail.tm/)

## Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/devwaseem/MailTMSwift.git`
- Select "Up to Next Major" with "1.1.1"

## Requirements

Swift: 5.0

| Platform | Minimum required version |
| -------- | ------------------------ |
| iOS      | 11.0                     |
| macOS    | 10.12                    |
| watchOS  | 4.0                      |
| tvOS     | 11.0                     |

## Highlights
🕹 Simple interface

🚥 Combine support

📡 Live updates using SSE

🚧 Cancel ongoing request
## Getting started

### Introduction
All the methods in this package support Combine. Retaining AnyCancellables will take care of canceling the ongoing API request when the retaining class is deinitialized. However, to cancel ongoing API requests when using completion handler supported methods, use [MTAPIServiceTask](https://mailtmswift.waseem.works/documentation/mailtmswift/mtapiservicetask).

The Helper classes [`MTAccountService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtaccountservice), [`MTMessageService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtmessageservice) and [`MTDomainService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtdomainservice) are _Stateless_ classes, so you are free to create multiple instances of it, without creating any side effects. If you use a dependency container, store the instance of the class and store it as `Application` or `Singleton` scope.

### Cancel ongoing API Request

Any non-combine methods of [`MTAccountService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtaccountservice), [`MTMessageService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtmessageservice) and [`MTDomainService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtdomainservice) return [`MTAPIServiceTask`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtapiservicetask). You can call `cancel()` method to cancel the ongoing API request.

```swift

let task = messageService.deleteMessage(id: id, token: token) { ... }

// cancel request
task.cancel()
```

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
        return
    }
    
    // Account deleted
    doSomethingAfterDelete()
}
```

### Fetching available domains

```swift
import MailTMSwift

let domainService = MTDomainService()
domainService.getAllDomains { (result: Result<[MTDomain], MTError>) in
    switch result {
      case .success(let domains):
        print("Available domains: \(domains)")
      case .failure(let error):
        print("Error occurred \(error)")
    }
}
```

To get details of a specific domain:

```swift
import MailTMSwift

let id = // domain ID
domainService.getDomain(id: id) { (result: Result<MTDomain, MTError>) in
    switch result {
      case .success(let domain):
        print("Domain: \(domain)")
      case .failure(let error):
        print("Error occurred \(error)")
    }
}
```

### Get all messages

```swift
import MailTMSwift

let messageService = MTMessageService()
let token = // Account JWT token
messageService.getAllMessages(token: token) { (result: Result<[MTMessage], MTError>) in
    switch result {
      case .success(let messages):
            for message in messages {
                print("Message: \(message)")
            }
      case .failure(let error):
        print("Error occurred \(error)")
    }
}
```

> The messages returned by `getAllMessages(token:)` does not contain complete information, because it is intended to list the messages as list. To fetch the complete message with the complete information, use [`getMessage(id:token:)`](#get-complete-message).

### Get complete message

```swift
import MailTMSwift

let messageService = MTMessageService()
let id = // Message ID
let token = // Account JWT token
messageService.getMessage(id: id, token: token) { (result: Result<MTMessage, MTError>) in
    switch result {
      case .success(let message):
        print("Complete message: \(message)")
      case .failure(let error):
        print("Error occurred \(error)")
    }
}
```

> Please see [Get all messages](#get-all-messages) before proceeding with this method.

### Mark message as seen

```swift
import MailTMSwift

let messageService = MTMessageService()
let id = // Message ID
let token = // Account JWT token
messageService.markMessageAs(id: id, seen: true, token: token) { (result: Result<MTMessage, MTError>) in
    switch result {
      case .success(let message):
        print("Updated message: \(message)")
      case .failure(let error):
        print("Error occurred \(error)")
    }
}
```

### Get the source of a message

```swift
import MailTMSwift

let messageService = MTMessageService()
let id = // Message ID
let token = // Account JWT token
messageService.getSource(id: id, token: token) { (result: Result<MTMessageSource, MTError>) in
    switch result {
      case .success(let messageSource):
        print("Message source: \(messageSource)")
      case .failure(let error):
        print("Error occurred \(error)")
    }
}
```

If the size of message is big and you wish to use a downloadTask from `URLSession`, you can do so manually by using the `URLRequest` object returned by:

```swift
import MailTMSwift

let messageService = MTMessageService()
let id = // Message ID
let token = // Account JWT token
let urlRequest = messageService.getSourceRequest(id: id, token: token)
let task = URLSession.shared.downloadTask(with: request)
// handle download task
```

### Deleting a message

```swift
import MailTMSwift

let messageService = MTMessageService()
let id = // Message ID
let token = // Account JWT token
messageService.deleteMessage(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
    if case let .failure(error) = result {
        print("Error Occurred: \(error)")
        return
    }
    
    // Message deleted
    doSomethingAfterDelete()
}
```

## 🚥 Live Events

[`MTLiveMailService`](https://mailtmswift.waseem.works/documentation/mailtmswift/mtlivemailservice) uses Apple's Combine framework to listen for live events. Make sure you use the required minimum version of the platform you're using this package.

### Requirements

| Platform | Minimum required version   |
| -------- | -------------------------- |
| iOS      | 13.0+                      |
| macOS    | 10.15+                     |
| watchOS  | 6.0+                       |
| tvOS     | 13.0+                      |

### Setup

```swift
import MailTMSwift
import Combine

let subscriptions = Set<AnyCancellable>()
let token = // Account JWT token
let id = // Account id
let liveMailService = MTLiveMailService(token: token, accountId: id)
```

### Listen for New / Updated messages

```swift
liveMailService.messagePublisher.sink { message in
    print("Received message event: \(message)")
}
.store(in: &subscriptions)
```

### Listen for account updates

```swift
liveMailService.accountPublisher.sink { account in
    print("Received account event: \(account)")
}
.store(in: &subscriptions)
```

### Listen for connection changes

```swift
liveMailService.statePublisher.sink { state in
  if state == .opened {
      print("Connected to server")
  } else {
      print("Disconnected to server")
  }
}
.store(in: &subscriptions)
```

### Start the listener

```swift
liveMailService.start()
```

### Stop the listener

```swift
liveMailService.stop()
```

### Restart the listener

```swift
liveMailService.restart()
```

Enable `autoRetry` property to automatically restart the connection if the connection is lost in between.

```swift
liveMailService.autoRetry = true
```

## Contribute 🤝

If you want to contribute to this library, you're always welcome!
You can contribute by filing issues, bugs and PRs.

### Contributing guidelines:
- Open issue regarding proposed change.
- Repo owner will contact you there.
- If your proposed change is approved, Fork this repo and do changes.
- Open PR against latest `development` branch. Add nice description in PR.
- You're done!

## ☕️ Donation

If this project helped you in any way, you can give me a cup of coffee :).

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/iamwaseem99)

## 📱 Contact

Have an project? DM us at 👇

Drop a mail to:- waseem07799@gmail.com

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
