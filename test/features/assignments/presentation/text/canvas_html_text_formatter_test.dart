import 'package:my_first_app/features/assignments/presentation/text/canvas_html_text_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('canvasHtmlToReadableMultilineText', () {
    test('keeps paragraph and line-break structure', () {
      final output = canvasHtmlToReadableMultilineText(
        '<p>Line 1<br>Line 2</p><p>Line 3</p>',
      );

      expect(output, 'Line 1\nLine 2\n\nLine 3');
    });

    test('renders ordered and unordered lists', () {
      final output = canvasHtmlToReadableMultilineText(
        '<ol start="2"><li>Second</li><li>Third</li></ol>'
        '<ul><li>Bullet A</li><li>Bullet B</li></ul>',
      );

      expect(output, '2. Second\n3. Third\n\n• Bullet A\n• Bullet B');
    });

    test('ignores data-start and starts ordered list from 1 by default', () {
      final output = canvasHtmlToReadableMultilineText(
        '<ol data-start="479" data-end="689">'
        '<li>Explain</li><li>Analyze</li><li>Evaluate</li>'
        '</ol>',
      );

      expect(output, '1. Explain\n2. Analyze\n3. Evaluate');
    });

    test('keeps numbering correct for nested ordered lists', () {
      final output = canvasHtmlToReadableMultilineText(
        '<ol>'
        '<li>Pre-Scan Reflection'
        '<ol><li>Question A</li><li>Question B</li></ol>'
        '</li>'
        '<li>Run VisScan'
        '<ol><li>Step 1</li><li>Step 2</li></ol>'
        '</li>'
        '</ol>',
      );

      expect(
        output,
        '1. Pre-Scan Reflection\n'
        '1. Question A\n'
        '2. Question B\n'
        '2. Run VisScan\n'
        '1. Step 1\n'
        '2. Step 2',
      );
    });

    test('keeps strong tags as bold markers when requested', () {
      final output = canvasHtmlToReadableMultilineTextWithBoldMarkers(
        '<p><strong>Point</strong>: 1<br><b>Due date</b>: Monday</p>',
      );

      expect(output, '[[B]]Point[[/B]]: 1\n[[B]]Due date[[/B]]: Monday');
    });
  });
}
