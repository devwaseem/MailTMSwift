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
    public let cc, bcc: [MTMessageUser]
    public let subject: String
    public let seen, flagged, isDeleted: Bool
    public let retention: Bool
    public let retentionDate: Date
    public let text: String
    public let html: [String]
    public let hasAttachments: Bool
    public let attachments: [MTAttachment]
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
        case msgid, from, to, cc, bcc, subject, seen, flagged, isDeleted, retention, retentionDate, text, html, hasAttachments, attachments, size
    }
}

public struct MTAttachment: Codable {

    public let id, filename, contentType, disposition: String
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
        self.id = id
        self.filename = filename
        self.contentType = contentType
        self.disposition = disposition
        self.transferEncoding = transferEncoding
        self.related = related
        self.size = size
        self.downloadURL = downloadURL
    }

    enum CodingKeys: String, CodingKey {
        case id, filename, contentType, disposition, transferEncoding, related, size
        case downloadURL = "downloadUrl"
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
