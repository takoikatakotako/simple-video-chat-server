import Vapor

final class RoomController {
    func make(_ req: Request) throws -> Future<Room> {
        // curl -H "Content-Type: application/json" -X POST -d '{"room_name":"zelda"}' http://localhost:8080/api/v0/make
        return try req.content.decode(Room.self).flatMap { user in
            print(user)
            return user.save(on: req)
        }
    }
}
