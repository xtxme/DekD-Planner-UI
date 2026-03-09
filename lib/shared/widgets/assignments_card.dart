import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentsCard extends StatelessWidget {
  const AssignmentsCard({
    super.key,
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.tagBg,
    required this.tagColor,
    required this.dueText,
    required this.dueColor,
    this.dueBg,
    this.showDuePill = true,
    this.showDueIcon = true,
    this.showLeadingCircle = true,
    this.showShadow = false,
  });

  final String subject;
  final String title;
  final String subtitle;
  final Color tagBg;
  final Color tagColor;
  final String dueText;
  final Color dueColor;
  final Color? dueBg;
  final bool showDuePill;
  final bool showDueIcon;
  final bool showLeadingCircle;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;
    const subtitleBaseStyle = TextStyle(
      fontSize: 14,
      color: AppColors.cFFA48C7E,
      fontWeight: FontWeight.w500,
    );
    final subtitleBoldStyle = subtitleBaseStyle.copyWith(
      fontWeight: FontWeight.w900,
    );
    final subtitleSpans = _buildSubtitleSpans(
      text: subtitle,
      baseStyle: subtitleBaseStyle,
      boldStyle: subtitleBoldStyle,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cFFF0E6DE),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: AppColors.c1A000000,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLeadingCircle) ...[
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cFFB9A89A, width: 2),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 12,
                              color: tagColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showDuePill)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dueBg ?? AppColors.cFFF0E6DE,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showDueIcon) ...[
                              Icon(Icons.timer, size: 14, color: dueColor),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              dueText,
                              style: TextStyle(
                                fontSize: 13,
                                color: dueColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showDueIcon) ...[
                            Icon(Icons.timer, size: 14, color: dueColor),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            dueText,
                            style: TextStyle(
                              fontSize: 13,
                              color: dueColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.cFF826559,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 4),
                  if (subtitleSpans == null)
                    Text(subtitle, softWrap: true, style: subtitleBaseStyle)
                  else
                    RichText(
                      text: TextSpan(
                        style: subtitleBaseStyle,
                        children: subtitleSpans,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan>? _buildSubtitleSpans({
    required String text,
    required TextStyle baseStyle,
    required TextStyle boldStyle,
  }) {
    const openToken = '[[B]]';
    const closeToken = '[[/B]]';

    if (!text.contains(openToken) && !text.contains(closeToken)) {
      return null;
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    var isBold = false;

    while (cursor < text.length) {
      final nextOpen = text.indexOf(openToken, cursor);
      final nextClose = text.indexOf(closeToken, cursor);

      final hasOpen = nextOpen >= 0;
      final hasClose = nextClose >= 0;
      int nextTokenIndex;
      bool tokenIsOpen;

      if (!hasOpen && !hasClose) {
        final tail = text.substring(cursor);
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
        final segment = text.substring(cursor, nextTokenIndex);
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
      return <InlineSpan>[TextSpan(text: text, style: baseStyle)];
    }

    return spans;
  }
}
