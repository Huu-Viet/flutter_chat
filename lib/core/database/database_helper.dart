import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/auth/data/entities/user_entity.dart';

class DatabaseHelper {
  static const String _databaseName = 'flutter_chat.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper _instance = DatabaseHelper._();
  static DatabaseHelper get instance => _instance;

  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await db.execute(UserEntity.createTableSQL);
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}