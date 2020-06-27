class HTTPException implements Exception {
  final errorMessage;
  HTTPException({this.errorMessage});

  @override
  String toString() {
    return errorMessage;
    //return super.toString();
  }
}
