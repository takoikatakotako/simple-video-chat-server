import Vapor

final class RoomController {



    func make(_ req: Request) throws -> Future<HTTPStatus> {
        // curl -H "Content-Type: application/json" -X POST -d '{"room_name":"zelda"}' http://localhost:8080/api/v0/make

        //let room = Room.query(on: req).filter(\.room_name == "onojun").all()

        return try req.content.decode(Room.self).flatMap { user in
            let rooms = Room.query(on: req).all().map { data in
                print("All Datas")
                print(data)
                for room: Room in data {
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

        try req.content.decode(Room.self).map { user -> User2 in
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


    struct Result: Content {
        var message: String
    }

    // OK
    // curl -H "Content-Type: application/json" -X POST -d '{"room_name":"zelda"}' http://localhost:8080/make
    func makeRoom(_ req: Request) throws -> Future<Result> {
        return try req.content.decode(Room.self).flatMap { newRoom -> Future<Result> in
            if newRoom.room_name!.count > 4 {
                return Room.query(on: req).all().map { rooms -> Result in
                    return Result(
                        message: "message"
                    )
                }
            } else {
                return req.future(Result(message: "message"))
            }
        }
    }
    
    

    // curl -H "Content-Type: application/json" -X POST -d '{"room_name":"zelda"}' http://localhost:8080/make
    func makeRoom2(_ req: Request) throws -> Future<Result> {
        return try req.content.decode(Room.self).flatMap { newRoom -> Future<Result> in
            print(newRoom.room_name!) //zelda
            if newRoom.room_name!.count > 4 {
                return Room.query(on: req).all().map { rooms -> Result in
                    return Result(
                        message: "message"
                    )
                }
            } else {
                return req.future(Result(message: "message"))
            }
        }
    }
    
    func makeRoom3(_ req: Request) throws -> Future<Result> {
        return try req.content.decode(Room.self).map { newRoom -> Result in
            print(newRoom.room_name!) //zelda
            return Result(
                message: "message"
            )
        }
    }
}
