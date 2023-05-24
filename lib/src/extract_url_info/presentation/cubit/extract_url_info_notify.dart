import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'extract_url_info_state.dart';

class ExtractUrlInfoNotify extends StateNotifier<ExtractUrlInfoState> {
  ExtractUrlInfoNotify() : super(ExtractUrlInfoInitial());
  extractUrl(String url) async {}
}
