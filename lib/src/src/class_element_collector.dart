import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

/// A visitor that collects all class elements defined within
/// a particular library.
///
/// The visitor can optionally limit the classes collected to those that
/// are exported from the library. This means that they are public,
/// and are either not subject to any `show` or `hide` clause, are
/// included in a `show` clause, or are not included in a `hide` clause.
class ClassElementCollector extends RecursiveElementVisitor<void> {
  final List<ClassElement> _classElements = [];
  final bool _exportOnly;

  ClassElementCollector({
    bool exportedOnly = false,
  }) : _exportOnly = exportedOnly;

  Iterable<ClassElement> get classElements => _classElements;

  @override
  void visitClassElement(ClassElement element) {
    _classElements.add(element);
  }

  @override
  void visitLibraryElement(LibraryElement element) {
    for (final unit in element.units) {
      unit.accept(this);
    }
  }
}

  