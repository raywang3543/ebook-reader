import 'package:ebook_reader/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ebook_reader/providers/reader_provider.dart';

void main() {
  testWidgets('App launches welcome screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ReaderProvider(),
        child: const EbookReaderApp(),
      ),
    );
    expect(find.text('电子书阅读器'), findsWidgets);
  });
}
