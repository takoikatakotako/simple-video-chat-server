import FluentMySQL
import Vapor

/// A simple user.
final class Room: MySQLModel {
    var id: Int?
    static let entity = "room"
    
    var room_id: Int?
    var room_name: Date?
    var created_at: Date?
    var offer_sdp: String?
    var offer_id: String?
    var answer_sdp: String?
    var answer_id: String?
}

/// Allows `Todo` to be used as a dynamic migration.
extension Room: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Room: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Room: Parameter { }
