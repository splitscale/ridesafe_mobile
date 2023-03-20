import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  Contact(this.name, this.phone);
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 0;

  @override
  Contact read(BinaryReader reader) {
    return Contact(reader.read(), reader.read());
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer.write(obj.name);
    writer.write(obj.phone);
  }
}
