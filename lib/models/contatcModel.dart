
import 'package:noteapp/const/contactConst.dart';

class ContactModel {
  late String name, number;
  int? id;

  ContactModel({
    required this.name,
    required this.number,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      idColumn: id,
      nameColumn: name,
      numberColumn: number,
    };
  }

  ContactModel.fromJson(Map<String, dynamic> map) {
    id = map[idColumn];
    name = map[nameColumn];
    number = map[numberColumn];
  }
}
