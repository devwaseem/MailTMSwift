//
//  File.swift
//  
//
//  Created by Waseem Akram on 01/10/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTMessageTests: XCTestCase {

    let dateFormatter = DateFormatter()
    var decoder: MTJSONDecoder!

    override func setUp() {
        decoder = MTJSONDecoder()
        dateFormatter.dateFormat = Config.dateFormat
    }

    override func tearDown() {
        decoder = nil
    }

    // MARK: - Lifecycle Tests
    func test_init_setsAllFields() {
        let givenId = "12345"
        let givenMsgId = "test-msgId"
        let givenFrom = MTMessageUser(address: "from-address", name: "from-name")
        let givenTo = [givenFrom]
        let givenCC = [givenFrom]
        let givenBCC = [givenFrom]
        let givenSubject = "test-subject"
        let givenSeen = true
        let givenFlagged = true
        let givenIsDeleted = true
        let givenRetention = true
        let givenRetentionDate = Date()
        let givenText = "test-text"
        let givenHtml = ["test-html"]
        let givenHasAttachment = true
        let givenAttachments = [MTAttachment(id: "at-id", filename: "at-filename", contentType: "at-contentType", disposition: "at-disposition", transferEncoding: "at-transferEncoding", related: true, size: 100, downloadURL: "at-downloadURL")]
        let givenSize = 100
        let givenDownloadURL = "test-downloadURL"
        let givenCreatedAt = Date()
        let givenUpdatedAt = Date()
        
        let sut = MTMessage(id: givenId,
                            msgid: givenMsgId,
                            from: givenFrom,
                            to: givenTo,
                            cc: givenCC,
                            bcc: givenBCC,
                            subject: givenSubject,
                            seen: givenSeen,
                            flagged: givenFlagged,
                            isDeleted: givenIsDeleted,
                            retention: givenRetention,
                            retentionDate: givenRetentionDate,
                            text: givenText,
                            html: givenHtml,
                            hasAttachments: givenHasAttachment,
                            attachments: givenAttachments,
                            size: givenSize,
                            downloadURL: givenDownloadURL,
                            createdAt: givenCreatedAt,
                            updatedAt: givenUpdatedAt)
        
        XCTAssertEqual(sut.id, givenId)
        XCTAssertEqual(sut.msgid, givenMsgId)
        XCTAssertEqual(sut.from, givenFrom)
        XCTAssertEqual(sut.to, givenTo)
        XCTAssertEqual(sut.cc, givenCC)
        XCTAssertEqual(sut.bcc, givenBCC)
        XCTAssertEqual(sut.subject, givenSubject)
        XCTAssertEqual(sut.seen, givenSeen)
        XCTAssertEqual(sut.flagged, givenFlagged)
        XCTAssertEqual(sut.isDeleted, givenIsDeleted)
        XCTAssertEqual(sut.retention, givenRetention)
        XCTAssertEqual(sut.retentionDate, givenRetentionDate)
        XCTAssertEqual(sut.text, givenText)
        XCTAssertEqual(sut.html, givenHtml)
        XCTAssertEqual(sut.hasAttachments, givenHasAttachment)
        XCTAssertEqual(sut.attachments, givenAttachments)
        XCTAssertEqual(sut.size, givenSize)
        XCTAssertEqual(sut.downloadURL, givenDownloadURL)
        XCTAssertEqual(sut.createdAt, givenCreatedAt)
        XCTAssertEqual(sut.updatedAt, givenUpdatedAt)

    }
    
    func stringToDate(dateString: String) -> Date {
        dateFormatter.date(from: dateString)!
    }

    // MARK: - Decodable Tests

    func test_MTDomain_decodesSingleDomain_successfullyFromJSON() throws {

        guard let url = Bundle.module.url(forResource: "Message", withExtension: "json", subdirectory: "FakeData") else {
            XCTFail("Message.json file not found!. Bundle URL: \(Bundle.module.bundleURL)")
            return
        }

        let json = try Data(contentsOf: url)
        let decodedMessage: MTMessage!
        do {
            decodedMessage = try decoder.decode(MTMessage.self, from: json)
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        XCTAssertNotNil(decodedMessage)
        XCTAssertEqual(decodedMessage.id, "6140df9033dbfcd61d71b3f9")
        XCTAssertEqual(decodedMessage.msgid, "<CAHwEYXL+eGaFJWkA7rVtQnb5GhZ0EwXNc5xE361rpXKBsAmJ=Q@mail.gmail.com>")
        XCTAssertEqual(decodedMessage.from.address, "waseem07799@gmail.com")
        XCTAssertEqual(decodedMessage.from.name, "waseem akram")
        XCTAssertEqual(decodedMessage.to.count, 1)
        XCTAssertEqual(decodedMessage.to[0].address, "randommmmm@uniromax.com")
        XCTAssertEqual(decodedMessage.to[0].name, "")
        XCTAssertEqual(decodedMessage.cc.count, 0)
        XCTAssertEqual(decodedMessage.bcc.count, 0)
        XCTAssertEqual(decodedMessage.subject, "Fwd: Test attachment")
        XCTAssertEqual(decodedMessage.seen, true)
        XCTAssertEqual(decodedMessage.flagged, false)
        XCTAssertEqual(decodedMessage.isDeleted, false)
        XCTAssertEqual(decodedMessage.retention, true)
        XCTAssertEqual(decodedMessage.retentionDate, stringToDate(dateString: "2021-09-21T17:44:48+00:00"))
        XCTAssertEqual(decodedMessage.text, "")
        XCTAssertEqual(decodedMessage.html.count, 1)
        XCTAssertEqual(decodedMessage.hasAttachments, true)
        XCTAssertEqual(decodedMessage.attachments.count, 1)
        XCTAssertEqual(decodedMessage.attachments[0].id, "ATTACH000001")
        XCTAssertEqual(decodedMessage.attachments[0].filename, "4375105_logo_swift_icon.svg")
        XCTAssertEqual(decodedMessage.attachments[0].contentType, "image/svg+xml")
        XCTAssertEqual(decodedMessage.attachments[0].disposition, "attachment")
        XCTAssertEqual(decodedMessage.attachments[0].transferEncoding, "base64")
        XCTAssertEqual(decodedMessage.attachments[0].related, false)
        XCTAssertEqual(decodedMessage.attachments[0].size, 1)
        XCTAssertEqual(decodedMessage.attachments[0].downloadURL, "/messages/6140df9033dbfcd61d71b3f9/attachment/ATTACH000001")
        XCTAssertEqual(decodedMessage.size, 4991)
        XCTAssertEqual(decodedMessage.downloadURL, "/messages/6140df9033dbfcd61d71b3f9/download")
        XCTAssertEqual(decodedMessage.createdAt, stringToDate(dateString: "2021-09-14T17:40:42+00:00"))
        XCTAssertEqual(decodedMessage.updatedAt, stringToDate(dateString: "2021-09-14T17:47:00+00:00"))
    }

}


