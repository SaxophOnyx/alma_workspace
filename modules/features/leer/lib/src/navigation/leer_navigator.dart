abstract interface class LeerNavigator {
  Future<void> openContext(String textId);

  Future<void> startReading(String textId);

  /// Completes once the annotation popup is closed.
  Future<void> openWordAnnotation(String wordId);

  Future<void> closeWordAnnotation();

  /// Returns to the text list, opening it when Leer was entered from another module.
  Future<void> openTextList();

  Future<void> breatheWithText();

  Future<void> openHome();

  Future<void> back();
}
