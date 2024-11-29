import SwiftUI

struct ContentView: View {
    @State var name: String = ""
    @State var age: Double = 0 // Use Double for the slider
    @State var email: String = ""
    @State var users: [User] = [] // This will hold the list of users
    @State var isEditing: Bool = false // Flag to check if we are editing
    @State var editingUser: User? // To hold the user being edited
    
    // New state to control showing the delete confirmation alert
    @State private var showingDeleteAlert: Bool = false
    @State private var userToDelete: User? = nil // Store the user to delete
    
    var body: some View {
        VStack {
            Text("Database").font(.title)
            
            // Name input field
            TextField("Enter name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(15)
            
            // Age slider with label
            VStack {
                Text("Age: \(Int(age))") // Convert to Int to display as an integer
                    .font(.headline)
                Slider(value: $age, in: 0...100, step: 1) // Slider for age selection (now works with Double)
                    .padding([.leading, .trailing, .bottom], 15)
            }
            
            // Email input field
            TextField("Enter email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(15)
            
            // Button to add user or update user if editing
            Button(action: {
                if let editingUser = self.editingUser {
                    // Update existing user
                    DatabaseHelper.shared.updateUser(id: editingUser.id ?? 0, name: self.name, age: Int(self.age), email: self.email)
                    self.isEditing = false
                    self.editingUser = nil
                } else {
                    // Add new user
                    DatabaseHelper.shared.insertUser(name: self.name, age: Int(self.age), email: self.email)
                }
                
                // Clear the input fields
                self.name = ""
                self.age = 0
                self.email = ""
                
                // Reload the list of users
                self.users = DatabaseHelper.shared.fetchUsers()
            }) {
                Text(isEditing ? "Update User" : "Add User")
            }
            .padding(.top, 15).buttonStyle(BorderedProminentButtonStyle())
            
            // List of users with Edit button
            List(users, id: \.id) { user in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name: \(user.name)")
                        Text("Age: \(user.age)")
                        Text("Email: \(user.email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Edit Button
                    Button(action: {
                        // Set the form to editing mode with the selected user
                        self.isEditing = true
                        self.editingUser = user
                        self.name = user.name
                        self.age = Double(user.age)
                        self.email = user.email
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Delete Button
                    Button(action: {
                        // Show the confirmation alert for deletion
                        self.userToDelete = user
                        self.showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(10)
                .background(self.editingUser?.id == user.id ? Color.blue.opacity(0.1) : Color.clear) // Highlight the user being edited
                .cornerRadius(8) // Optional: Round the corners for the highlighted item
                .shadow(radius: self.editingUser?.id == user.id ? 5 : 0) // Optional: Add a shadow for emphasis
            }
            .padding(.top, 15)
        }
        .padding()
        .onAppear {
            // Load the users when the view appears
            self.users = DatabaseHelper.shared.fetchUsers()
        }
        // Alert for delete confirmation
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Do you really want to delete this user?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let userToDelete = self.userToDelete {
                        // Perform the deletion if confirmed
                        DatabaseHelper.shared.deleteUser(id: userToDelete.id ?? 0)
                        self.users = DatabaseHelper.shared.fetchUsers() // Reload the users
                    }
                },
                secondaryButton: .cancel() // Cancel the deletion
            )
        }
    }
}

// Preview
#Preview {
    ContentView()
}
