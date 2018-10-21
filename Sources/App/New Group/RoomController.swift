import Vapor

final class RoomController {
    func make(_ req: Request) throws -> Future<Room> {
        // curl -H "Content-Type: application/json" -X POST -d '{"room_name":"zelda"}' http://localhost:8080/api/v0/make
        
        //let room = Room.query(on: req).filter(\.room_name == "onojun").all()
        
        return try req.content.decode(Room.self).flatMap { user in
            let rooms = Room.query(on: req).all().map { data in
                print("All Datas")
                print(data)
                for room:Room in data {
                    print(room)
                }
                print("------")
            }
            print(rooms)
            // 同じ名前のroomが作られているかチェックしたい。
            //
            return user.save(on: req)
        }
    }
}
