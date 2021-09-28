//
//  File.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTDomainTests: XCTestCase {

    var decoder: MTJSONDecoder!

    override func setUp() {
        decoder = MTJSONDecoder()
    }

    override func tearDown() {
        decoder = nil
    }

    // MARK: - Lifecycle Tests
    func test_init() {
        let givenId = "12345"
        let givenDomain = "example.com"
        let givenCreatedAtDate = Date()
        let givenUpdatedAtDate = Date()
        let sut = MTDomain(id: givenId,
                                   domain: givenDomain,
                                   isActive: false,
                                   isPrivate: false,
                                   createdAt: givenCreatedAtDate,
                                   updatedAt: givenUpdatedAtDate)

        XCTAssertEqual(sut.id, givenId)
        XCTAssertEqual(sut.domain, givenDomain)
        XCTAssertEqual(sut.isActive, false)
        XCTAssertEqual(sut.isPrivate, false)
        XCTAssertEqual(sut.createdAt, givenCreatedAtDate)
        XCTAssertEqual(sut.updatedAt, givenUpdatedAtDate)

    }

    // MARK: - Decodable Tests

    func test_MTDomain_decodesSingleDomain_successfullyFromJSON() throws {

        let url = Bundle.module.bundleURL.appendingPathComponent("Contents/Resources/FakeData/Domain.json")

        let json = try Data(contentsOf: url)
        let decodedDomain: MTDomain!
        do {
            decodedDomain = try decoder.decode(MTDomain.self, from: json)
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        XCTAssertNotNil(decodedDomain)
        XCTAssertEqual(decodedDomain.id, "613f72dc2a2501052c66504d")
        XCTAssertEqual(decodedDomain.domain, "uniromax.com")
        XCTAssertEqual(decodedDomain.isActive, true)
        XCTAssertEqual(decodedDomain.isPrivate, false)
    }

    func test_MTDomain_decodesMultipleDomain_successfullyFromJSON() throws {
        let url = Bundle.module.bundleURL.appendingPathComponent("Contents/Resources/FakeData/Domains.json")

        let json = try Data(contentsOf: url)
        let decodedDomains: [MTDomain]!
        do {
            let data = try decoder.decode(HydraWrapper<[MTDomain]>.self, from: json)
            decodedDomains = data.result
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        XCTAssertNotNil(decodedDomains)
        XCTAssertEqual(decodedDomains.count, 1)
        XCTAssertEqual(decodedDomains[0].id, "613f72dc2a2501052c66504d")
    }

}
