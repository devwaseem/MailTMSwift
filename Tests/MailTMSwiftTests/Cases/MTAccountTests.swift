//
//  MTAccountTests.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTAccountTests: XCTestCase {
    
    var decoder: MTJSONDecoder!
    var givenCreatedAtDate: Date!
    var givenUpdatedAtDate: Date!
    
    
    override func setUp() {
        givenCreatedAtDate = Date()
        givenUpdatedAtDate = Date()
        decoder = MTJSONDecoder()
    }
    
    override func tearDown() {
        givenCreatedAtDate = nil
        givenUpdatedAtDate = nil
        decoder = nil
    }
    
    // MARK: - Lifecycle Tests
    func test_init() {
        let givenId = "12345"
        let givenCreatedAtDate = Date()
        let givenUpdatedAtDate = Date()
        
        let sut = MTAccount(id: givenId,
                            address: "example@example.com",
                            quotaLimit: 100,
                            quotaUsed: 0,
                            isDisabled: false,
                            isDeleted: false,
                            createdAt: givenCreatedAtDate,
                            updatedAt: givenUpdatedAtDate)
        
        XCTAssertEqual(sut.id, givenId)
        XCTAssertEqual(sut.quotaLimit, 100)
        XCTAssertEqual(sut.quotaUsed, 0)
        XCTAssertEqual(sut.isDeleted, false)
        XCTAssertEqual(sut.isDisabled, false)
        XCTAssertEqual(sut.createdAt, givenCreatedAtDate)
        XCTAssertEqual(sut.updatedAt, givenUpdatedAtDate)
    }
    
    func test_decodesAccount_successfullyFromJSON() throws {
        
        let url = Bundle.module.bundleURL.appendingPathComponent("Contents/Resources/FakeData/Account.json")

        let json = try Data(contentsOf: url)
        let decodedAccount: MTAccount!
        do {
            decodedAccount = try decoder.decode(MTAccount.self, from: json)
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        XCTAssertNotNil(decodedAccount)
        XCTAssertEqual(decodedAccount.id, "6140db437eb15d095b7107e6")
        XCTAssertEqual(decodedAccount.quotaLimit, 40000000)
        XCTAssertEqual(decodedAccount.quotaUsed, 4991)
        XCTAssertEqual(decodedAccount.isDeleted, false)
        XCTAssertEqual(decodedAccount.isDisabled, false)
    }
    
    func test_whenQuotaLimitIsReached_isQuotaLimitReached_returnsFalse() {
        let sut = MTAccount(id: "12345",
                            address: "example@example.com",
                            quotaLimit: 100,
                            quotaUsed: 10,
                            isDisabled: false,
                            isDeleted: false,
                            createdAt: givenCreatedAtDate,
                            updatedAt: givenUpdatedAtDate)
        
        XCTAssertFalse(sut.isQuotaLimitReached)
    }
    
    func test_whenQuotaLimitIsReached_isQuotaLimitReached_returnsTrue() {
        let sut = MTAccount(id: "12345",
                            address: "example@example.com",
                            quotaLimit: 100,
                            quotaUsed: 101,
                            isDisabled: false,
                            isDeleted: false,
                            createdAt: givenCreatedAtDate,
                            updatedAt: givenUpdatedAtDate)
        
        XCTAssertTrue(sut.isQuotaLimitReached)
    }
    
    func test_quotaUsedPercentage_returnsCorrectly() {
        let sut = MTAccount(id: "12345",
                            address: "example@example.com",
                            quotaLimit: 100,
                            quotaUsed: 10,
                            isDisabled: false,
                            isDeleted: false,
                            createdAt: givenCreatedAtDate,
                            updatedAt: givenUpdatedAtDate)
        XCTAssertEqual(sut.quotaUsedPercetage, 0.1)
    }
    
    func test_quotaUsedPercentage_whenQuotaUsedIsGreaterThanQuotaLimit_returnsPercentage_One() {
        let sut = MTAccount(id: "12345",
                            address: "example@example.com",
                            quotaLimit: 100,
                            quotaUsed: 200,
                            isDisabled: false,
                            isDeleted: false,
                            createdAt: givenCreatedAtDate,
                            updatedAt: givenUpdatedAtDate)
        XCTAssertEqual(sut.quotaUsedPercetage, 1.0)
    }
    
}
