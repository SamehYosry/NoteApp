import 'dart:math';

import 'package:flutter/material.dart';
import 'package:noteapp/dataBase/contactDataBase.dart';
import 'package:noteapp/models/contatcModel.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool confirmDelete = false;
  bool isDeleteAll = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  bool isUpdateMode = false;

  ContatcDataBaseHandler contatcDataBaseHandler = ContatcDataBaseHandler();

  // getAllData
  Future<List<ContactModel>> getAllData() async {
    List<ContactModel> allData = [];
    await contatcDataBaseHandler.getAllContactsFromDataBase().then((value) {
      allData = value;
    });
    return allData;
  }

  // insert Data To DataBase
  Future<void> insertData(BuildContext context) async {
    await contatcDataBaseHandler
        .insertContactToDataBase(
      ContactModel(name: nameController.text, number: numberController.text),
    )
        .then((value) {
      print('Data Saved');
      nameController.clear();
      numberController.clear();
      setState(() {});
      Navigator.pop(context);
    });
  }

// delet All Data
  deleteAllContatcs() async {
    await contatcDataBaseHandler.deleteAllContactsFromDataBase();
    setState(() {});
  }

// Delete contatc By Id
  deleteContact(int id) async {
    await contatcDataBaseHandler.deleteContactFromDataBaseByID(id);
  }

  // Update contatc
  updateContatc(ContactModel model, BuildContext context) async {
    await contatcDataBaseHandler
        .updateContactFromDataBaseById(
      ContactModel(
          name: nameController.text,
          number: numberController.text,
          id: model.id),
    )
        .then((value) {
      setState(() {});
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note App'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              deleteMessageDialog1(context: context);
              //deleteAllContatcs();
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            label: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO : ADD Contacts
          customAlertDialog(context, null);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: getAllData(),
          builder: (BuildContext context,
              AsyncSnapshot<List<ContactModel>> snapshot) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return customContactTile(context,
                      id: snapshot.data![index].id!,
                      name: snapshot.data![index].name,
                      number: snapshot.data![index].number);
                },
              );
            } else {
              return const Center(
                  child: Text(
                ' No Notes',
                style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ));
            }
          },
        ),
      ),
    );
  }

// Custom Contact Car
  Widget customContactTile(
    BuildContext context, {
    required String name,
    required String number,
    required int id,
  }) {
    return Card(
      elevation: 15,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.red, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Dismissible(
        confirmDismiss: (vlaue) async {
          await deleteMessageDialog(context: context,id: id);
          return confirmDelete;
        },
        direction: DismissDirection.endToStart,
        key: UniqueKey(),
        background: Container(
          padding: const EdgeInsets.only(right: 10),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete,color: Colors.white,size: 50),
          ),
        ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              IconButton(
                onPressed: () {
                  customAlertDialog(
                    context,
                    ContactModel(name: name, number: number, id: id),
                  );
                },
                icon: const Icon(Icons.edit,color: Colors.green),
              ),
            ],
          ),
          subtitle: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.indigo),
              //borderRadius: BorderRadius.circular(20),
            ),
            child: Text(textAlign: TextAlign.end,
              number,
              style: TextStyle(fontSize: 25),
            ),
          ),
         
        ),
      ),
    );
  }

// Delete Note
  Future deleteMessageDialog(
      {required BuildContext context, required int id}) async {
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: Container(
            height: MediaQuery.of(context).size.height / 8.5,
            child: Column(
              children: [
                const Text(
                  'Delete Message',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  (isDeleteAll)
                      ? 'Are you sure you want to delete All contacts'
                      : 'Are you sure you want to delete this contact',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO : delete just a contact
              deleteContact(id);
              confirmDelete = true;
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              // don't delete
              confirmDelete = false;
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
    isDeleteAll = false;
  }

// Delete Message
  Future deleteMessageDialog1({required BuildContext context}) async {
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: Container(
            height: MediaQuery.of(context).size.height / 8.5,
            child: Column(
              children: [
                const Text(
                  'Delete Notes',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to delete All Notes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO : delete All notes
              deleteAllContatcs();
              confirmDelete = true;
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              // don't delete
              confirmDelete = false;
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
    isDeleteAll = false;
  }

// Custom Widget For TextField
  Widget CustomTextField(String title, TextInputType keyBoardType,
      TextEditingController controller) {
    return TextField(
      maxLines: max(1, 2),
      controller: controller,
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        label: Text('$title'),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.indigo,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(35),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

// Custom AlertDialog For ADD Or Update
  customAlertDialog(BuildContext context, ContactModel? model) {
    if (model != null) {
      // Update Mode
      isUpdateMode = true;
      nameController.text = model.name;
      numberController.text = model.number;
    } else {
      // Add Mode
      isUpdateMode = false;
      nameController.clear();
      numberController.clear();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.indigo, width: 2),
            ),
            elevation: 15,
            content: Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                children: [
                  Text(
                    (isUpdateMode) ? 'Update Notes' : 'Add Notes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.indigo),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                      'Title', TextInputType.multiline, nameController),
                  const SizedBox(height: 8),
                  CustomTextField(
                   
                      'Note', TextInputType.multiline, numberController),
                  SizedBox(height: 15),
                  ElevatedButton(
                    // to Add Contact or Update Contact
                    onPressed: () => (isUpdateMode)
                        ? updateContatc(model!, context)
                        : insertData(context),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        (isUpdateMode) ? 'Update' : 'Save',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side:
                              const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
