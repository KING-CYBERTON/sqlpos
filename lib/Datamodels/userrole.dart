class UserRole {
  int? userRoleId;
  int employeeId;
  int roleId;

  UserRole({
    this.userRoleId,
    required this.employeeId,
    required this.roleId,
  });

  // Convert UserRole to Map (for SQL insertion)
  Map<String, dynamic> toMap() {
    return {
      'user_role_id': userRoleId,
      'employee_id': employeeId,
      'role_id': roleId,
    };
  }

  // Convert Map to UserRole (for SQL selection)
  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      userRoleId: map['user_role_id'],
      employeeId: map['employee_id'],
      roleId: map['role_id'],
    );
  }
}
