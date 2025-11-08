import 'package:riverpod/riverpod.dart';

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}
