class Helper{

  static bool isImage(String image_string){
    RegExp regExp = RegExp("[^\\s]+(.*?)\\.(jpg|jpeg|png|gif|JPG|JPEG|PNG|GIF)");
    return regExp.hasMatch(image_string);
  }

  static bool isValidLink(String link){
    return Uri.tryParse(link)!.hasAbsolutePath;
  }

}