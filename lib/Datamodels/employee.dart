class Employee {
  int? employeeId; // Nullable, since it may be auto-incremented by the database
  String name;
  String? phone;
  String email;
  String? address;
  String password; // Store hashed password for security
  DateTime? hireDate;
  int? roleId; // Foreign key referencing roles
  String? role; // The new role field (role name)

  // Constructor
  Employee({
    this.employeeId,
    required this.name,
    this.phone,
    required this.email,
    this.address,
    required this.password,
    this.hireDate,
    this.roleId,
    this.role, // Include role in the constructor
  });

  // Method to convert Employee object to a map (to insert into the database)
  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'password': password,
      'hire_date': hireDate?.toIso8601String(), // Convert DateTime to string
      'role_id': roleId,
      'role': role, // Include role in the map
    };
  }

  // Method to convert a map to an Employee object (from the database query result)
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeId: map['employee_id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      password: map['password'],
      hireDate: map['hire_date'] != null ? DateTime.parse(map['hire_date']) : null,
      roleId: map['role_id'],
      role: map['role'], // Extract role from map
    );
  }
}
