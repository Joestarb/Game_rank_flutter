import 'package:riverpod/riverpod.dart';

class HomeFilterController extends Notifier<String> {
  @override
  String build() => 'Todos';

  void setFiltro(String value) => state = value;
}
