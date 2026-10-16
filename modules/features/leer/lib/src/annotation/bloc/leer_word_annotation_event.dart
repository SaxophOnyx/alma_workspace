part of 'leer_word_annotation_bloc.dart';

sealed class LeerWordAnnotationEvent {
  const LeerWordAnnotationEvent();
}

final class AnnotationStarted extends LeerWordAnnotationEvent {
  const AnnotationStarted();
}

final class AddPressed extends LeerWordAnnotationEvent {
  const AddPressed();
}

final class ClosePressed extends LeerWordAnnotationEvent {
  const ClosePressed();
}
