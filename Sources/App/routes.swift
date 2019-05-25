import Vapor
import Foundation

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get { req in
        return "Hello, this is simple application for Evgen! \n\nuse /help for more details"
    }
    
    router.get("help") { _ in
        return "1) you can use /getAllUsers to get stored user \n\n2) use /saveUser with params: \nname:string, \nid:string, \nlat:double, \nlong:Double \nfor saving user \n\n3) use /deleteUser to clear the UserDefaults"
    }
    
    router.get("getAllUsers") { req -> GetUsersResponse in
        if let users = getUsers() {
            return GetUsersResponse(visitors: users, success: "true")
        } else {
            return GetUsersResponse(visitors: [], success: "false")
        }
    }
    
    router.post(Visitor.self, at: "saveUser") { req, data -> SaveVisitorResponse in
        return SaveVisitorResponse(visitor: data, success: setUsers(userForStor: data))
    }
    
    router.get("deleteUser") { req -> String in
        UserDefaults.standard.removeObject(forKey: "Users")
        if UserDefaults.standard.object(forKey: "Users") != nil {
            return "false"
        } else {
            return "success"
        }
    }
}

private func getUsers() -> [Visitor]? {
        let users = getFromDefaults()
        var visitors:[Visitor] = []
        for user in users {
            let visitor = Visitor(lat: user.lat, long: user.long, name: user.name, id: user.id)
            if visitors.isEmpty {
                visitors = [visitor]
            } else {
                visitors.append(visitor)
            }
        }
        return visitors
}

private func setUsers(userForStor: Visitor) -> String {
    let visitor = userForStor
    var visitors:[Visitor] = getFromDefaults()
    visitors.append(visitor)
    saveToDefaults(visitir: visitors)
    return "success"
}

private func parseVisitor(user: [String: Any]) -> [String: Any] {
    let name = user["name"] as! String
    let id = user["id"] as! String
    let lat = user["lat"] as! Double
    let long = user["long"] as! Double
    return ["lat": lat, "long": long, "name": name, "id": id]
}

private func saveToDefaults (visitir: [Visitor]) {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(visitir), forKey:"Users")
}

private func getFromDefaults () -> [Visitor] {
    if let data = UserDefaults.standard.object(forKey:"Users") as? Data {
        let visitors = try? PropertyListDecoder().decode(Array<Visitor>.self, from: data)
        return visitors ?? []
    } else {
        return []
    }
}

// structs
struct SaveVisitorResponse: Content {
    let visitor: Visitor
    let success: String
}

struct GetUsersResponse: Content {
    let visitors: [Visitor]
    let success: String
}

struct Visitor: Content {
    var lat: Double
    var long: Double
    var name: String
    var id: String
    
    init(lat: Double, long: Double, name: String, id: String) {
        self.lat = lat
        self.long = long
        self.name = name
        self.id = id
    }
}
