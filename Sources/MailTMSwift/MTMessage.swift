//
//  File.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation

public struct MTMessage: Codable {

    public let id: String
    public let msgid: String
    public let from: MTMessageUser
    public let to: [MTMessageUser]
    public let cc, bcc: [MTMessageUser]?
    public let subject: String
    public let seen, flagged, isDeleted: Bool
    public let retention: Bool?
    public let retentionDate: Date?
    public var intro: String?
    public let text: String?
    public let html: [String]?
    public let hasAttachments: Bool
    public let attachments: [MTAttachment]?
    public let size: Int
    public let downloadURL: String?
    public let createdAt, updatedAt: Date

    public init(id: String,
                msgid: String,
                from: MTMessageUser,
                to: [MTMessageUser],
                cc: [MTMessageUser],
                bcc: [MTMessageUser],
                subject: String,
                seen: Bool,
                flagged: Bool,
                isDeleted: Bool,
                retention: Bool,
                retentionDate: Date,
                intro: String,
                text: String,
                html: [String],
                hasAttachments: Bool,
                attachments: [MTAttachment],
                size: Int,
                downloadURL: String,
                createdAt: Date,
                updatedAt: Date) {
        self.id = id
        self.msgid = msgid
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.seen = seen
        self.flagged = flagged
        self.isDeleted = isDeleted
        self.retention = retention
        self.retentionDate = retentionDate
        self.intro = intro
        self.text = text
        self.html = html
        self.hasAttachments = hasAttachments
        self.attachments = attachments
        self.size = size
        self.downloadURL = downloadURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case downloadURL = "downloadUrl"
        case createdAt, updatedAt
        case msgid, from, to, cc, bcc, subject, seen
        case flagged, isDeleted, retention, retentionDate
        case intro, text, html, hasAttachments, attachments, size
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.msgid = try container.decode(String.self, forKey: .msgid)
        self.from = try container.decode(MTMessageUser.self, forKey: .from)
        self.to = try container.decode([MTMessageUser].self, forKey: .to)
        self.cc = try container.decodeIfPresent([MTMessageUser].self, forKey: .cc) ?? []
        self.bcc = try container.decodeIfPresent([MTMessageUser].self, forKey: .bcc) ?? []
        self.subject = try container.decode(String.self, forKey: .subject)
        self.seen = try container.decodeIfPresent(Bool.self, forKey: .seen) ?? false
        self.flagged = try container.decodeIfPresent(Bool.self, forKey: .flagged) ?? false
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        self.retention = try container.decodeIfPresent(Bool.self, forKey: .retention)
        self.retentionDate = try container.decodeIfPresent(Date.self, forKey: .retentionDate)
        self.intro = try container.decodeIfPresent(String.self, forKey: .intro)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.html = try container.decodeIfPresent([String].self, forKey: .html)
        self.hasAttachments = try container.decode(Bool.self, forKey: .hasAttachments)
        self.attachments = try container.decodeIfPresent([MTAttachment].self, forKey: .attachments) ?? []
        self.size = try container.decode(Int.self, forKey: .size)
        self.downloadURL = try container.decodeIfPresent(String.self, forKey: .downloadURL)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

public struct MTAttachment: Codable {

    public var localId, filename, contentType, disposition: String
    public let transferEncoding: String
    public let related: Bool
    public let size: Int
    public let downloadURL: String

    public init(id: String,
                filename: String,
                contentType: String,
                disposition: String,
                transferEncoding: String,
                related: Bool,
                size: Int,
                downloadURL: String) {
        self.localId = id
        self.filename = filename
        self.contentType = contentType
        self.disposition = disposition
        self.transferEncoding = transferEncoding
        self.related = related
        self.size = size
        self.downloadURL = downloadURL
    }

    enum CodingKeys: String, CodingKey {
        // Server returned ID is not unique. Still we save the returned ID for other purposes.
        case localId = "id"
        case downloadURL = "downloadUrl"
        case filename, contentType, disposition, transferEncoding, related, size
    }
}

public struct MTMessageUser: Codable {
    public let address, name: String

    public init(address: String, name: String) {
        self.address = address
        self.name = name
    }

}

extension MTMessage: Hashable, Identifiable {
    public static func == (lhs: MTMessage, rhs: MTMessage) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(msgid)
        hasher.combine(from)
        hasher.combine(to)
        hasher.combine(seen)
        hasher.combine(flagged)
        hasher.combine(isDeleted)
        hasher.combine(retention)
        hasher.combine(retentionDate)
        hasher.combine(text)
        hasher.combine(hasAttachments)
        hasher.combine(attachments)
        hasher.combine(size)
        hasher.combine(downloadURL)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
        hasher.combine(cc)
        hasher.combine(bcc)
        hasher.combine(subject)
    }

}

extension MTAttachment: Hashable, Identifiable {
    
    public var id: Int {
        hashValue
    }

    public static func == (lhs: MTAttachment, rhs: MTAttachment) -> Bool {
        lhs.id == rhs.id
    }

}

extension MTMessageUser: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(name)
    }
}
