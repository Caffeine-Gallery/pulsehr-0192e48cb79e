import Bool "mo:base/Bool";
import Hash "mo:base/Hash";

import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

actor {
    // Define the Employee type
    type Employee = {
        id: Text;
        firstName: Text;
        lastName: Text;
        email: Text;
        title: Text;
        department: Text;
        employeeId: Text;
        middleName: ?Text;
        preferredName: ?Text;
        birthDate: ?Text;
        ssn: ?Text;
        gender: ?Text;
    };

    // Create a stable variable to store employees
    private stable var employeesEntries : [(Text, Employee)] = [];

    // Create a HashMap to store employees
    private var employees = HashMap.HashMap<Text, Employee>(0, Text.equal, Text.hash);

    // Initialize the HashMap with stable data
    system func preupgrade() {
        employeesEntries := Iter.toArray(employees.entries());
    };

    system func postupgrade() {
        employees := HashMap.fromIter<Text, Employee>(employeesEntries.vals(), 1, Text.equal, Text.hash);
    };

    // Helper function to create a new employee
    private func createEmployee(id: Text, firstName: Text, lastName: Text, email: Text, title: Text, department: Text, employeeId: Text) : Employee {
        {
            id = id;
            firstName = firstName;
            lastName = lastName;
            email = email;
            title = title;
            department = department;
            employeeId = employeeId;
            middleName = null;
            preferredName = null;
            birthDate = null;
            ssn = null;
            gender = null;
        }
    };

    // Initialize with some sample data
    private func initSampleData() {
        let employee1 = createEmployee("1", "John", "Doe", "john@example.com", "Software Engineer", "Engineering", "EMP001");
        let employee2 = createEmployee("2", "Jane", "Smith", "jane@example.com", "Product Manager", "Product", "EMP002");
        
        employees.put(employee1.id, employee1);
        employees.put(employee2.id, employee2);
    };

    // Call initSampleData when the canister is deployed
    initSampleData();

    // Get all employees
    public query func getAllEmployees() : async [Employee] {
        Iter.toArray(employees.vals())
    };

    // Get a specific employee by ID
    public query func getEmployee(id: Text) : async ?Employee {
        employees.get(id)
    };

    // Update an employee's information
    public func updateEmployee(id: Text, field: Text, value: Text) : async Bool {
        switch (employees.get(id)) {
            case (null) { false };
            case (?employee) {
                var updatedEmployee = employee;
                switch (field) {
                    case "firstName" { updatedEmployee := { employee with firstName = value } };
                    case "lastName" { updatedEmployee := { employee with lastName = value } };
                    case "email" { updatedEmployee := { employee with email = value } };
                    case "title" { updatedEmployee := { employee with title = value } };
                    case "department" { updatedEmployee := { employee with department = value } };
                    case "employeeId" { updatedEmployee := { employee with employeeId = value } };
                    case "middleName" { updatedEmployee := { employee with middleName = ?value } };
                    case "preferredName" { updatedEmployee := { employee with preferredName = ?value } };
                    case "birthDate" { updatedEmployee := { employee with birthDate = ?value } };
                    case "ssn" { updatedEmployee := { employee with ssn = ?value } };
                    case "gender" { updatedEmployee := { employee with gender = ?value } };
                    case _ { return false };
                };
                employees.put(id, updatedEmployee);
                true
            };
        }
    };

    // Get the current user (for demo purposes, we'll return a fixed user)
    public query func getCurrentUser() : async Employee {
        switch (employees.get("1")) {
            case (null) {
                // If the user doesn't exist, return a default user
                createEmployee("1", "John", "Doe", "john@example.com", "Software Engineer", "Engineering", "EMP001")
            };
            case (?employee) {
                employee
            };
        }
    };
}
