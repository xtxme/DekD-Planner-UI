import 'package:flutter/material.dart';
import 'package:my_first_app/features/assignments/presentation/text/canvas_html_text_formatter.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailNotesCard extends StatelessWidget {
  const AssignmentDetailNotesCard({
    super.key,
    required this.text,
    this.htmlText,
  });

  final String text;
  final String? htmlText;

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 18 / 1.15,
      height: 1.45,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w900);
    final richTextChildren = _buildRichTextChildren(baseStyle, boldStyle);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 6,
                decoration: const BoxDecoration(
                  color: AppColors.cFFE2D8CF,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 18, 22),
            child: richTextChildren == null
                ? const SizedBox.shrink()
                : RichText(
                    text: TextSpan(
                      style: baseStyle,
                      children: richTextChildren,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan>? _buildRichTextChildren(
    TextStyle baseStyle,
    TextStyle boldStyle,
  ) {
    final html = htmlText?.trim();
    if (html == null || html.isEmpty) {
      if (text.isEmpty) {
        return null;
      }
      return <InlineSpan>[TextSpan(text: text, style: baseStyle)];
    }

    final marked = canvasHtmlToReadableMultilineTextWithBoldMarkers(html);
    if (marked.isEmpty) {
      if (text.isEmpty) {
        return null;
      }
      return <InlineSpan>[TextSpan(text: text, style: baseStyle)];
    }

    return _tokenizeBoldMarkers(
      markedText: marked,
      baseStyle: baseStyle,
      boldStyle: boldStyle,
    );
  }

  List<InlineSpan> _tokenizeBoldMarkers({
    required String markedText,
    required TextStyle baseStyle,
    required TextStyle boldStyle,
  }) {
    const openToken = '[[B]]';
    const closeToken = '[[/B]]';
    final spans = <InlineSpan>[];
    var cursor = 0;
    var isBold = false;

    while (cursor < markedText.length) {
      final nextOpen = markedText.indexOf(openToken, cursor);
      final nextClose = markedText.indexOf(closeToken, cursor);

      final hasOpen = nextOpen >= 0;
      final hasClose = nextClose >= 0;
      int nextTokenIndex;
      bool tokenIsOpen;

      if (!hasOpen && !hasClose) {
        final tail = markedText.substring(cursor);
        if (tail.isNotEmpty) {
          spans.add(
            TextSpan(text: tail, style: isBold ? boldStyle : baseStyle),
          );
        }
        break;
      }

      if (hasOpen && (!hasClose || nextOpen < nextClose)) {
        nextTokenIndex = nextOpen;
        tokenIsOpen = true;
      } else {
        nextTokenIndex = nextClose;
        tokenIsOpen = false;
      }

      if (nextTokenIndex > cursor) {
        final segment = markedText.substring(cursor, nextTokenIndex);
        if (segment.isNotEmpty) {
          spans.add(
            TextSpan(text: segment, style: isBold ? boldStyle : baseStyle),
          );
        }
      }

      if (tokenIsOpen) {
        isBold = true;
        cursor = nextTokenIndex + openToken.length;
      } else {
        isBold = false;
        cursor = nextTokenIndex + closeToken.length;
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: markedText, style: baseStyle));
    }

    return spans;
  }
}
