import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:notas_app/utils/constants.dart';
import 'package:notas_app/models/note.dart';

class DatabaseHelper{
  static final DatabaseHelper _INSTANCE = new DatabaseHelper.make();

  factory DatabaseHelper() => _INSTANCE;

  static Database _db;

  DatabaseHelper.make();


  Future<Database> get db async {
    if (_db != null) return _db; 
    _db = await initDB();
    return _db;
  }

  Future<Database> initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, Constants.DBNAME);
    var myDb = openDatabase(path, version: Constants.DB_VERSION, onCreate: _onCreate);

    return myDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE ${Constants.TABLE_NAME} (${Constants.COLUM_ID} INTEGER PRIMARY KEY AUTOINCREMENT, ${Constants.COLUM_TEXT} TEXT, ${Constants.COLUM_DATE} TEXT ,  ${Constants.COLUM_DESC} TEXT , ${Constants.COLUM_PRIO} INTEGER );");
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM ${Constants.TABLE_NAME} ORDER BY ${Constants.COLUM_TEXT} ASC");

    return result;
  }


  Future<List<Note>> getNoteList() async {
    var noteMapList = await getAllNotes(); // Get 'Map List' from database
		int count = noteMapList.length; 
    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
			noteList.add(Note.fromMap(noteMapList[i]));
		}

		return noteList;
  }

  Future<int> insertNote(Note note) async {
    var dbClient = await db;
    int count = await dbClient.insert(Constants.TABLE_NAME, note.toMap());

    return count;
  }

  Future<int> getCount() async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${Constants.TABLE_NAME}"));
    return count;
  }

  Future<Note> getSingleItem(int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM ${Constants.TABLE_NAME} WHERE ${Constants.COLUM_ID} = $id");
    if (result == null) return null;
    return new Note.fromMap(result.first);
  }

  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    int count = await dbClient.delete(Constants.TABLE_NAME,
        where: "${Constants.COLUM_ID} = ?", whereArgs: [id]);
    return count;
  }

  Future<int> updateItem(Note note) async {
    var dbClient = await db;
    int count = await dbClient.update(Constants.TABLE_NAME, note.toMap(),
        where: "${Constants.COLUM_ID} = ?", whereArgs: [note.id]);

    return count;
  }

}