import Vapor

final class RoomController {

    
    struct Result: Content {
        var name: String
        var email: String
    }
    
    func make(_ req: Request) throws -> Future<HTTPStatus> {
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
            return user.save(on: req).transform(to: .ok)
        }
    }
    
    func make2(_ req: Request) throws -> User2 {
        // curl -H "Content-Type: application/json" -X POST -d '{"room_name":"zelda"}' http://localhost:8080/api/v0/make
        
        let aaa = try req.content.decode(Room.self).map { user -> User2 in
            return User2(
                name: "Vapeeeor User",
                email: "user@vapor.codes"
            )
        }

        
        return User2(
            name: "Vapeeeor User",
            email: "user@vapor.codes"
        )
        
    }
}
