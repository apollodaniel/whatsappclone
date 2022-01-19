class Message{

  String content;
  String date;
  String sender;

  Message({required this.content, required this.date, required this.sender});

  toMap(){
    return {
      "content":content,
      "date":date,
      "sender":sender
    };
  }

}