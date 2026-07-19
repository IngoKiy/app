import 'package:vikunja_app/core/sync/filter/filter_ast.dart';

/// Tokenizer + rekursiver Abstiegsparser für die Vikunja-Filtergrammatik.
///
/// Grammatik (vereinfacht):
///   or        := and ( '||' and )*
///   and       := primary ( '&&' primary )*
///   primary   := '(' or ')' | condition
///   condition := field op value
///   op        := '=' | '!=' | '>' | '<' | '>=' | '<=' | 'in' | 'like'
///
/// Präzedenz: `&&` bindet stärker als `||` (wie im Server).
/// Unbekannte Felder/Operatoren/Konstrukte -> [UnsupportedFilterException].
class FilterParser {
  /// Erlaubte Felder samt der jeweils zulässigen Operatoren.
  static const Set<String> _dateFields = {'due_date', 'start_date', 'end_date'};
  static const Set<String> _numFields = {'priority', 'percent_done'};
  static const Set<String> _idFields = {'labels', 'assignees', 'project'};

  static FilterExpr parse(String input) {
    final tokens = _tokenize(input);
    final parser = _Parser(tokens);
    final expr = parser._parseOr();
    if (parser._cur.type != _TokType.eof) {
      throw UnsupportedFilterException('Unerwartetes Token: ${parser._cur.text}');
    }
    return expr;
  }

  // --- Tokenizer ---

  static List<_Token> _tokenize(String s) {
    final tokens = <_Token>[];
    var i = 0;
    bool isWordTerminator(String c) => ' \t\n\r()&|=<>!,'.contains(c);

    while (i < s.length) {
      final c = s[i];
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
        i++;
        continue;
      }
      if (c == '(') {
        tokens.add(const _Token(_TokType.lparen, '('));
        i++;
      } else if (c == ')') {
        tokens.add(const _Token(_TokType.rparen, ')'));
        i++;
      } else if (c == ',') {
        tokens.add(const _Token(_TokType.comma, ','));
        i++;
      } else if (c == '&') {
        if (i + 1 < s.length && s[i + 1] == '&') {
          tokens.add(const _Token(_TokType.and, '&&'));
          i += 2;
        } else {
          throw UnsupportedFilterException('Erwartet "&&" an Position $i');
        }
      } else if (c == '|') {
        if (i + 1 < s.length && s[i + 1] == '|') {
          tokens.add(const _Token(_TokType.or, '||'));
          i += 2;
        } else {
          throw UnsupportedFilterException('Erwartet "||" an Position $i');
        }
      } else if (c == '!') {
        if (i + 1 < s.length && s[i + 1] == '=') {
          tokens.add(const _Token(_TokType.op, '!='));
          i += 2;
        } else {
          throw UnsupportedFilterException('Erwartet "!=" an Position $i');
        }
      } else if (c == '=') {
        tokens.add(const _Token(_TokType.op, '='));
        i++;
      } else if (c == '>') {
        if (i + 1 < s.length && s[i + 1] == '=') {
          tokens.add(const _Token(_TokType.op, '>='));
          i += 2;
        } else {
          tokens.add(const _Token(_TokType.op, '>'));
          i++;
        }
      } else if (c == '<') {
        if (i + 1 < s.length && s[i + 1] == '=') {
          tokens.add(const _Token(_TokType.op, '<='));
          i += 2;
        } else {
          tokens.add(const _Token(_TokType.op, '<'));
          i++;
        }
      } else if (c == '\'' || c == '"') {
        // Quotierter String (kann Leerzeichen enthalten).
        final quote = c;
        final buf = StringBuffer();
        i++;
        while (i < s.length && s[i] != quote) {
          buf.write(s[i]);
          i++;
        }
        if (i >= s.length) {
          throw UnsupportedFilterException('Nicht geschlossener String');
        }
        i++; // schließendes Quote
        tokens.add(_Token(_TokType.word, buf.toString()));
      } else {
        // Bareword bis zum nächsten Terminator.
        final start = i;
        while (i < s.length && !isWordTerminator(s[i])) {
          i++;
        }
        tokens.add(_Token(_TokType.word, s.substring(start, i)));
      }
    }
    tokens.add(const _Token(_TokType.eof, ''));
    return tokens;
  }
}

enum _TokType { word, op, and, or, lparen, rparen, comma, eof }

class _Token {
  final _TokType type;
  final String text;
  const _Token(this.type, this.text);
}

class _Parser {
  final List<_Token> tokens;
  int pos = 0;
  _Parser(this.tokens);

  _Token get _cur => tokens[pos];

  FilterExpr _parseOr() {
    var left = _parseAnd();
    while (_cur.type == _TokType.or) {
      pos++;
      final right = _parseAnd();
      left = LogicNode(LogicOp.or, left, right);
    }
    return left;
  }

  FilterExpr _parseAnd() {
    var left = _parsePrimary();
    while (_cur.type == _TokType.and) {
      pos++;
      final right = _parsePrimary();
      left = LogicNode(LogicOp.and, left, right);
    }
    return left;
  }

  FilterExpr _parsePrimary() {
    if (_cur.type == _TokType.lparen) {
      pos++;
      final inner = _parseOr();
      if (_cur.type != _TokType.rparen) {
        throw UnsupportedFilterException('Erwartet ")"');
      }
      pos++;
      return inner;
    }
    return _parseCondition();
  }

  FilterExpr _parseCondition() {
    if (_cur.type != _TokType.word) {
      throw UnsupportedFilterException('Feldname erwartet, war: "${_cur.text}"');
    }
    final field = _cur.text;
    pos++;

    // Operator: entweder Symbol-Token oder das Wort "in"/"like".
    final CompareOp op;
    if (_cur.type == _TokType.op) {
      op = _symbolToOp(_cur.text);
      pos++;
    } else if (_cur.type == _TokType.word && _cur.text == 'in') {
      op = CompareOp.inList;
      pos++;
    } else if (_cur.type == _TokType.word && _cur.text == 'like') {
      op = CompareOp.like;
      pos++;
    } else {
      throw UnsupportedFilterException('Operator erwartet nach "$field"');
    }

    _requireOperatorAllowed(field, op);

    if (op == CompareOp.inList) {
      final values = <FilterValue>[_parseSingleValue(field, op)];
      while (_cur.type == _TokType.comma) {
        pos++;
        values.add(_parseSingleValue(field, op));
      }
      return ConditionNode(field, op, ListValue(values));
    }

    final value = _parseSingleValue(field, op);
    return ConditionNode(field, op, value);
  }

  CompareOp _symbolToOp(String sym) => switch (sym) {
    '=' => CompareOp.eq,
    '!=' => CompareOp.neq,
    '>' => CompareOp.gt,
    '<' => CompareOp.lt,
    '>=' => CompareOp.gte,
    '<=' => CompareOp.lte,
    _ => throw UnsupportedFilterException('Unbekannter Operator: $sym'),
  };

  /// Prüft, dass [op] für [field] zulässig ist – und dass [field] überhaupt
  /// bekannt ist.
  void _requireOperatorAllowed(String field, CompareOp op) {
    final Set<CompareOp> allowed;
    if (field == 'done') {
      allowed = {CompareOp.eq, CompareOp.neq};
    } else if (FilterParser._numFields.contains(field) ||
        FilterParser._dateFields.contains(field)) {
      allowed = {
        CompareOp.eq,
        CompareOp.neq,
        CompareOp.gt,
        CompareOp.lt,
        CompareOp.gte,
        CompareOp.lte,
      };
    } else if (FilterParser._idFields.contains(field)) {
      allowed = {CompareOp.eq, CompareOp.neq, CompareOp.inList};
    } else if (field == 'title') {
      allowed = {CompareOp.like, CompareOp.eq, CompareOp.neq};
    } else {
      throw UnsupportedFilterException('Unbekanntes Feld: "$field"');
    }
    if (!allowed.contains(op)) {
      throw UnsupportedFilterException(
        'Operator "${op.name}" nicht erlaubt für Feld "$field"',
      );
    }
  }

  FilterValue _parseSingleValue(String field, CompareOp op) {
    if (_cur.type != _TokType.word) {
      throw UnsupportedFilterException('Wert erwartet für Feld "$field"');
    }
    final raw = _cur.text;
    pos++;

    if (field == 'done') {
      return BoolValue(_parseBool(raw));
    }
    if (field == 'title') {
      return StringValue(raw);
    }
    if (FilterParser._idFields.contains(field)) {
      return NumValue(_parseInt(raw));
    }
    if (FilterParser._numFields.contains(field)) {
      return NumValue(_parseNum(raw));
    }
    // Datumsfelder.
    return _parseDateOrNow(raw);
  }

  bool _parseBool(String raw) {
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    throw UnsupportedFilterException('Boolescher Wert erwartet, war: "$raw"');
  }

  int _parseInt(String raw) {
    final v = int.tryParse(raw);
    if (v == null) {
      throw UnsupportedFilterException('Ganzzahl erwartet, war: "$raw"');
    }
    return v;
  }

  num _parseNum(String raw) {
    final v = num.tryParse(raw);
    if (v == null) {
      throw UnsupportedFilterException('Zahl erwartet, war: "$raw"');
    }
    return v;
  }

  FilterValue _parseDateOrNow(String raw) {
    if (raw == 'now' || raw.startsWith('now/') || raw.startsWith('now+') ||
        raw.startsWith('now-')) {
      return _parseNow(raw);
    }
    final dt = DateTime.tryParse(raw);
    if (dt == null) {
      throw UnsupportedFilterException('Datum erwartet, war: "$raw"');
    }
    return DateValue(dt.toUtc());
  }

  /// Parst `now`, optional gefolgt von Rundungen (`/d`) und Verschiebungen
  /// (`+7d`, `-1w`). Rundung nur für s/m/h/d, Verschiebung für s/m/h/d/w/M/y.
  NowValue _parseNow(String raw) {
    var i = 3; // hinter 'now'
    final steps = <NowStep>[];
    const offsetUnits = 'smhdwMy';
    const roundUnits = 'smhd';

    while (i < raw.length) {
      final c = raw[i];
      if (c == '/') {
        i++;
        if (i >= raw.length) {
          throw UnsupportedFilterException('Rundungseinheit fehlt in "$raw"');
        }
        final unit = raw[i];
        if (!roundUnits.contains(unit)) {
          throw UnsupportedFilterException(
            'Rundungseinheit "$unit" nicht unterstützt in "$raw"',
          );
        }
        steps.add(NowRound(unit));
        i++;
      } else if (c == '+' || c == '-') {
        final sign = c == '-' ? -1 : 1;
        i++;
        final numStart = i;
        while (i < raw.length && _isDigit(raw[i])) {
          i++;
        }
        if (i == numStart) {
          throw UnsupportedFilterException('Zahl erwartet in "$raw"');
        }
        final amount = int.parse(raw.substring(numStart, i));
        if (i >= raw.length) {
          throw UnsupportedFilterException('Zeiteinheit fehlt in "$raw"');
        }
        final unit = raw[i];
        if (!offsetUnits.contains(unit)) {
          throw UnsupportedFilterException(
            'Zeiteinheit "$unit" nicht unterstützt in "$raw"',
          );
        }
        steps.add(NowOffset(sign * amount, unit));
        i++;
      } else {
        throw UnsupportedFilterException('Ungültiger now-Ausdruck: "$raw"');
      }
    }
    return NowValue(steps);
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}
