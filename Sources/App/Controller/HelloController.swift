import Vapor

final class HelloController {
    func greet(_ req: Request) throws -> String {
        
        let aaa = Room.query(on: req).range(..<50).all()
        print("@@@@")
        print(aaa)
        print("@@@@")

        let task = Room()
        task.room_name = "onojun"
        task.save(on: req)

        return "Hello!"
    }
}
