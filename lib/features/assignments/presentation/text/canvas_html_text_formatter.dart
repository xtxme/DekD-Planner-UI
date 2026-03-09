const String _boldOpenMarker = '[[B]]';
const String _boldCloseMarker = '[[/B]]';

String canvasHtmlToReadableMultilineText(String value) {
  if (value.trim().isEmpty) {
    return '';
  }

  var output = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  output = _expandLists(output);

  output = output
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*/\s*p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<\s*p\b[^>]*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*/\s*div\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*div\b[^>]*>', caseSensitive: false), '\n');

  output = output.replaceAll(RegExp(r'<[^>]*>'), '');
  output = _decodeHtmlEntities(output);

  final normalizedLines = <String>[];
  var previousLineBlank = true;

  for (final rawLine in output.split('\n')) {
    final line = rawLine.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
    if (line.isEmpty) {
      if (previousLineBlank) {
        continue;
      }
      normalizedLines.add('');
      previousLineBlank = true;
      continue;
    }

    normalizedLines.add(line);
    previousLineBlank = false;
  }

  if (normalizedLines.isNotEmpty && normalizedLines.last.isEmpty) {
    normalizedLines.removeLast();
  }

  return normalizedLines.join('\n');
}

String canvasHtmlToReadableMultilineTextWithBoldMarkers(String value) {
  if (value.trim().isEmpty) {
    return '';
  }

  final marked = value
      .replaceAll(
        RegExp(r'<\s*(strong|b)\b[^>]*>', caseSensitive: false),
        _boldOpenMarker,
      )
      .replaceAll(
        RegExp(r'<\s*/\s*(strong|b)\s*>', caseSensitive: false),
        _boldCloseMarker,
      );

  return canvasHtmlToReadableMultilineText(marked);
}

String _decodeHtmlEntities(String value) {
  final namedEntities = <String, String>{
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
  };

  var output = value;
  namedEntities.forEach((entity, replacement) {
    output = output.replaceAll(entity, replacement);
  });

  output = output.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    final codePoint = int.tryParse(match.group(1) ?? '');
    if (codePoint == null) {
      return match.group(0) ?? '';
    }
    return String.fromCharCode(codePoint);
  });

  output = output.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
    final codePoint = int.tryParse(match.group(1) ?? '', radix: 16);
    if (codePoint == null) {
      return match.group(0) ?? '';
    }
    return String.fromCharCode(codePoint);
  });

  return output.replaceAll('\u00A0', ' ');
}

String _expandLists(String value) {
  final buffer = StringBuffer();
  final tokenPattern = RegExp(r'<[^>]+>|[^<]+');
  final stack = <_ListContext>[];

  for (final match in tokenPattern.allMatches(value)) {
    final token = match.group(0) ?? '';
    if (token.isEmpty) {
      continue;
    }

    if (!token.startsWith('<')) {
      buffer.write(token);
      continue;
    }

    final nameMatch = RegExp(
      r'^<\s*/?\s*([a-zA-Z0-9]+)',
      caseSensitive: false,
    ).firstMatch(token);
    if (nameMatch == null) {
      buffer.write(token);
      continue;
    }

    final tag = (nameMatch.group(1) ?? '').toLowerCase();
    final isClosing = RegExp(r'^<\s*/', caseSensitive: false).hasMatch(token);

    if (isClosing) {
      switch (tag) {
        case 'ol':
          _popLastOfKind(stack, _ListKind.ordered);
          buffer.write('\n');
          break;
        case 'ul':
          _popLastOfKind(stack, _ListKind.unordered);
          buffer.write('\n');
          break;
        case 'li':
          break;
        default:
          buffer.write(token);
      }
      continue;
    }

    switch (tag) {
      case 'ol':
        final attrsMatch = RegExp(
          r'^<\s*ol\b([^>]*)>',
          caseSensitive: false,
        ).firstMatch(token);
        final attrs = attrsMatch?.group(1) ?? '';
        final startMatch = RegExp(
          "(^|\\s)start\\s*=\\s*['\\\"]?(\\d+)['\\\"]?",
          caseSensitive: false,
        ).firstMatch(attrs);
        final start = int.tryParse(startMatch?.group(2) ?? '') ?? 1;
        stack.add(_ListContext.ordered(start: start));
        buffer.write('\n');
        break;
      case 'ul':
        stack.add(_ListContext.unordered());
        buffer.write('\n');
        break;
      case 'li':
        final marker = stack.isEmpty ? '• ' : stack.last.consumeMarker();
        if (!_endsWithNewline(buffer)) {
          buffer.write('\n');
        }
        buffer.write(marker);
        break;
      default:
        buffer.write(token);
    }
  }

  return buffer.toString();
}

void _popLastOfKind(List<_ListContext> stack, _ListKind kind) {
  for (var i = stack.length - 1; i >= 0; i--) {
    if (stack[i].kind == kind) {
      stack.removeAt(i);
      return;
    }
  }
}

bool _endsWithNewline(StringBuffer buffer) {
  return buffer.length > 0 && buffer.toString().endsWith('\n');
}

enum _ListKind { ordered, unordered }

final class _ListContext {
  _ListContext.unordered()
    : kind = _ListKind.unordered,
      _nextIndex = null;

  _ListContext.ordered({required int start})
    : kind = _ListKind.ordered,
      _nextIndex = start;

  final _ListKind kind;
  int? _nextIndex;

  String consumeMarker() {
    if (kind == _ListKind.unordered) {
      return '• ';
    }

    final marker = '${_nextIndex ?? 1}. ';
    _nextIndex = (_nextIndex ?? 1) + 1;
    return marker;
  }
}
