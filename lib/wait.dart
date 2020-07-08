Future<void> wait({int ms, int s}) async {
  return ms != null
      ? Future.delayed(Duration(milliseconds: ms), null)
      : Future.delayed(Duration(seconds: s), null);
}
