class Role {
  int? roleId;
  String roleName;
  String permissions;

  Role({this.roleId, required this.roleName, required this.permissions});

  // Convert a Role to a Map (for SQL insertion)
  Map<String, dynamic> toMap() {
    return {
      'role_id': roleId,
      'role_name': roleName,
      'permissions': permissions,
    };
  }

  // Convert a Map to a Role (for SQL selection)
  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      roleId: map['role_id'],
      roleName: map['role_name'],
      permissions: map['permissions'],
    );
  }
}
