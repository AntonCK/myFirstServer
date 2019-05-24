import Vapor

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
        let user: [String: Any] = ["name": data.name, "id": data.id, "lat": data.lat, "long": data.long]
        
        return SaveVisitorResponse(visitor: data, success: setUsers(userForStor: user))
    }
    
    router.get("deleteUser") { req -> String in
        UserDefaults.standard.removeObject(forKey: "Users")
        if UserDefaults.standard.value(forKey: "Users") != nil {
            return "false"
        } else {
            return "success"
        }
    }
}
private func getUsers() -> [Visitor]? {
    if UserDefaults.standard.value(forKey: "Users") != nil {
        let users:[[String: Any]] = UserDefaults.standard.value(forKey: "Users") as! [[String: Any]]
        var visitors:[Visitor] = []
        for user in users {
            let name = user["name"] as! String
            let id = user["id"] as! String
            let lat = user["lat"] as! Double
            let long = user["long"] as! Double
            let visitor = Visitor(lat: lat, long: long, name: name, id: id)
            if visitors.isEmpty {
                visitors = [visitor]
            } else {
                visitors.append(visitor)
            }
        }
        
        return visitors
    } else {
        return []
    }
}

private func setUsers(userForStor: [String: Any]) -> String {
    let visitor:[String: Any] = parseVisitor(user: userForStor)
    var visitors:[[String: Any]] = []
    if let users = UserDefaults.standard.value(forKey: "Users") {
        visitors = users as! [[String : Any]]
    }
    visitors.append(visitor)
    UserDefaults.standard.set(visitors, forKey: "Users")
    return "success"
}

private func parseVisitor(user: [String: Any]) -> [String: Any] {
    let name = user["name"] as! String
    let id = user["id"] as! String
    let lat = user["lat"] as! Double
    let long = user["long"] as! Double
    return ["lat": lat, "long": long, "name": name, "id": id]
}

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
