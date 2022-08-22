import 'package:noteapp/const/contactConst.dart';
import 'package:noteapp/models/contatcModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class ContatcDataBaseHandler {
  // Start SinglTone
  ContatcDataBaseHandler.internal();
  static final ContatcDataBaseHandler contatcDataBaseHandler =
      ContatcDataBaseHandler.internal();
  factory ContatcDataBaseHandler() {
    return contatcDataBaseHandler;
  }

  // Empty Object Frm Data from SQF package
  Database? database;

  // Get Data Base
  Future<Database> getDataBase() async {
    if (database != null) {
      return database!;
    } else {
      database = await createDataBase();
      return database!;
    }
  }


    Future<Database> createDataBase() async {
    String path = join(await getDatabasesPath(), 'muContacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE $contactTable ($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT , $numberColumn TEXT )');
      },
    );
  }

// CRUD
  // Insert to DataBase
  Future<void> insertContactToDataBase(ContactModel model) async {
    Database database = await getDataBase();
    await database.insert(contactTable, model.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update Contatc
  Future<void> updateContactFromDataBaseById(ContactModel model) async {
    Database database = await getDataBase();
    await database.update(contactTable, model.toJson(),
        where: '$idColumn = ?', whereArgs: [model.id]);
  }

  // get All Contacts
  Future<List<ContactModel>> getAllContactsFromDataBase() async {
    Database database = await getDataBase();
    List<Map<String, dynamic>> allData = await database.query(contactTable);

    if (allData.isNotEmpty) {
      return allData.map((contatc) => ContactModel.fromJson(contatc)).toList();
    } else {
      return [];
    }
  }

  // get Contact By ID
  Future<ContactModel> getContactFromDataBaseById(int id) async {
    Database database = await getDataBase();
    List<Map<String, dynamic>> allData = await database
        .query(contactTable, where: '$idColumn= ?', whereArgs: [id]);

    if (allData.isNotEmpty) {
      return ContactModel.fromJson(allData[0]);
    } else {
      return ContactModel(name: '', number: '');
    }
  }

  //Delete All Contatcs
  Future<void> deleteAllContactsFromDataBase() async {
    Database database = await getDataBase();
    await database.delete(contactTable);
  }

  //Delete Contatc By ID
  Future<void> deleteContactFromDataBaseByID(int id) async {
    Database database = await getDataBase();
    await database
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }
}
