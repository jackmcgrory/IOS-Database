import Foundation
import SQLite3

class DatabaseHelper {
    
    static let shared = DatabaseHelper() // Singleton instance
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTable() // Ensure table is created when the app runs
    }
    
    // Open the SQLite database
    private func openDatabase() {
        // Get the path to the database file
        let path = getDatabasePath()
        
        // Open the database, if it doesn't exist it will be created
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Successfully opened database at \(path)")
        }
    }
    
    // Get the path to the SQLite database
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentDirectory.appendingPathComponent("database.sqlite")
        return databaseURL.path
    }
    
    // Create the Users table if it doesn't exist
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            email TEXT
        );
        """
        
        // Prepare the query
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Users table created successfully.")
            } else {
                print("Error creating table: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        // Finalize the statement
        sqlite3_finalize(stmt)
    }
    
    func insertUser(name: String, age: Int, email: String) {
        let insertQuery = "INSERT INTO Users (name, age, email) VALUES (?, ?, ?);"
        
        var stmt: OpaquePointer?
        
        // Prepare the statement
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
            
            // Bind the values to the query
            let nameCString = name.cString(using: .utf8)
            let emailCString = email.cString(using: .utf8)
            sqlite3_bind_text(stmt, 1, nameCString, -1, nil) // Bind name
            sqlite3_bind_int(stmt, 2, Int32(age))            // Bind age
            sqlite3_bind_text(stmt, 3, emailCString, -1, nil) // Bind email
            
            // Execute the statement
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("User inserted successfully.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error inserting user: \(errorMessage)")  // More detailed error
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing insert statement: \(errorMessage)")  // More detailed error
        }
        
        sqlite3_finalize(stmt)
    }

    
    // Update a user's details
    func updateUser(id: Int, name: String, age: Int, email: String) {
        let updateQuery = "UPDATE Users SET name = ?, age = ?, email = ? WHERE id = ?;"
        
        var stmt: OpaquePointer?
        
        
        // Bind the values to the query
        let nameCString = name.cString(using: .utf8)
        let emailCString = email.cString(using: .utf8)
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &stmt, nil) == SQLITE_OK {
            // Bind the values to the query
            sqlite3_bind_text(stmt, 1, nameCString, -1, nil)
            sqlite3_bind_int(stmt, 2, Int32(age))
            sqlite3_bind_text(stmt, 3, emailCString, -1, nil)
            sqlite3_bind_int(stmt, 4, Int32(id)) // Bind the user id
            
            // Execute the query
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("User updated successfully.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error updating user: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing update statement: \(errorMessage)")
        }
        
        sqlite3_finalize(stmt)
    }

    
    // Fetch all users from the Users table
    func fetchUsers() -> [User] {
        var users = [User]()
        let fetchQuery = "SELECT * FROM Users;"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0) // Automatically generated by SQLite
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let age = sqlite3_column_int(stmt, 2)
                let email = String(cString: sqlite3_column_text(stmt, 3))
                
                // Create a User instance and add it to the array
                let user = User(id: Int(id), name: name, age: Int(age), email: email)
                users.append(user)
            }
        } else {
            print("Error fetching users: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
        return users
    }
    
    func deleteUser(id: Int){
        let deleteQuery = "DELETE FROM Users WHERE id = ?;"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(id)) // Bind the user id
            
            // Execute the query
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("User deleted successfully.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error deleting user: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing delete statement: \(errorMessage)")
        }
        
        sqlite3_finalize(stmt)
        
    }
    
    // Close the database connection
    deinit {
        sqlite3_close(db)
    }
}
