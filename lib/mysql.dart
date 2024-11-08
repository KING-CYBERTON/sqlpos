import 'package:mysql1/mysql1.dart';

class MySQLHelper {
  // Define MySQL connection settings
  final ConnectionSettings settings = ConnectionSettings(
    host: 'localhost', // Change this to your server's IP or domain if not local
    port: 3306,        // Default MySQL port
    user: 'root',     // Your MySQL username
    password: '1234', // Your MySQL password
    db: 'pos_system', // Database name
  );

  MySqlConnection? _connection;

  // Initialize and open the connection
  Future<void> openConnection() async {
    try {
      _connection = await MySqlConnection.connect(settings);
      print('Connected to MySQL database.');
    } catch (e) {
      print('Error connecting to the database: $e');
    }
  }

  // Close the connection
  Future<void> closeConnection() async {
    await _connection?.close();
    print('Database connection closed.');
  }

  // General method to run SELECT queries
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? params]) async {
    final List<Map<String, dynamic>> results = [];

    if (_connection == null) {
      print('No open connection found.');
      return results;
    }

    try {
      // Execute the query
      final queryResults = await _connection!.query(sql, params);

      // Convert results into a list of maps
      for (var row in queryResults) {
        results.add(row.fields);
      }
    } catch (e) {
      print('Error executing query: $e');
    }

    return results;
  }

  // General method for INSERT, UPDATE, DELETE operations
  Future<int> execute(String sql, [List<dynamic>? params]) async {
    int affectedRows = 0;

    if (_connection == null) {
      print('No open connection found.');
      return affectedRows;
    }

    try {
      final result = await _connection!.query(sql, params);
      affectedRows = result.affectedRows ?? 0;
    } catch (e) {
      print('Error executing operation: $e');
    }

    return affectedRows;
  }
}
