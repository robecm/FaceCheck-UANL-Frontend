class CheckFaceRequest {
  final String img;

  CheckFaceRequest({required this.img});

  Map<String, dynamic> toJson() {
    return {
      'img': img,
    };
  }
}