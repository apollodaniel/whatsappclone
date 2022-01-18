import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Message.dart';

import '../Helper.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> conversas = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    conversas.add(Conversa(
        profile_picture: "https://static.photocdn.pt/images/articles/2019/08/07/images/articles/2019/07/31/linkedin_profile_picture_examples.png",
        name: "Apollo",
        messages: [Message(content: "https://pixy.org/src2/600/6007103.jpg", date: DateTime.fromMillisecondsSinceEpoch(1642456819).toString())]));
    conversas.add(Conversa(
        profile_picture: "http://getwallpapers.com/wallpaper/full/3/e/b/563644.jpg",
        name: "Fernanda",
        messages: [Message(content: "Oieee", date: DateTime.now().toString())]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: conversas.length,
        itemBuilder: (context, index) {


          String date = conversas[index].messages[conversas[index].messages.length - 1].date;
          DateTime date_parsed = DateTime.parse(date);
          String formated_date = "";

          String message_content_raw = conversas[index].messages[conversas[index].messages.length - 1].content;
          String message_content =  isImage(message_content_raw) ? "Sent a image" : message_content_raw;
          String profile_picture = conversas[index].profile_picture;
          String name = conversas[index].name;

          if(date_parsed.difference(DateTime.now()).inDays != 0 && date_parsed.isBefore(DateTime.now())){
            formated_date =  DateFormat("dd/MM/yyyy").format(date_parsed);
          }else{
            formated_date = DateFormat("HH:mm").format(date_parsed);
          }




          return Card(
            child: ListTile(
              leading: GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(conversas[index].profile_picture),
                ),
                onTap: (){
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text(name),
                      content: Image.network(profile_picture,height: 180, width: 180, fit: BoxFit.cover,),

                    );
                  },);
                },
              ),
              title: Text(conversas[index].name),
              subtitle: Text(
                  "${formated_date} - ${message_content}",
              ),
            ),
          );
        },
      ),
    );
  }

  isImage(String message_raw){
    if(Helper.isValidLink(message_raw) && Helper.isImage(message_raw.split("/").last)){
      return true;
    }
    return false;
  }

}
