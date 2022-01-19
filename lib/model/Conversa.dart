import 'Message.dart';

class Conversa {

  String profile_picture;
  String name;
  String id;
  String email;
  List<Message> messages;


  Conversa({ required this.email, required this.id,required this.profile_picture, required this.name, required this.messages});

}