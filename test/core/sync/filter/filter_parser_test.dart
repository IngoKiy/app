import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/sync/filter/filter_ast.dart';
import 'package:vikunja_app/core/sync/filter/filter_parser.dart';

/// Rendert den AST kompakt, damit Struktur/Präzedenz tabellengetrieben
/// vergleichbar sind.
String render(FilterExpr e) {
  switch (e) {
    case LogicNode(:final op, :final left, :final right):
      final sym = op == LogicOp.and ? '&&' : '||';
      return '(${render(left)} $sym ${render(right)})';
    case ConditionNode(:final field, :final op, :final value):
      return '$field ${_op(op)} ${_val(value)}';
  }
}

String _op(CompareOp op) => switch (op) {
  CompareOp.eq => '=',
  CompareOp.neq => '!=',
  CompareOp.gt => '>',
  CompareOp.lt => '<',
  CompareOp.gte => '>=',
  CompareOp.lte => '<=',
  CompareOp.inList => 'in',
  CompareOp.like => 'like',
};

String _val(FilterValue v) => switch (v) {
  BoolValue(:final value) => '$value',
  NumValue(:final value) => '$value',
  StringValue(:final value) => "'$value'",
  DateValue(:final value) => value.toUtc().toIso8601String(),
  NowValue(:final steps) => 'now${steps.map(_step).join()}',
  ListValue(:final values) => '[${values.map(_val).join(',')}]',
};

String _step(NowStep s) => switch (s) {
  NowRound(:final unit) => '/$unit',
  NowOffset(:final amount, :final unit) =>
    '${amount >= 0 ? '+' : ''}$amount$unit',
};

void main() {
  group('gültige Ausdrücke', () {
    final cases = <String, String>{
      'done = false': 'done = false',
      'priority >= 3': 'priority >= 3',
      'priority != 1': 'priority != 1',
      'percent_done < 0.5': 'percent_done < 0.5',
      'labels in 1,2': 'labels in [1,2]',
      'labels in 1, 2, 3': 'labels in [1,2,3]',
      'assignees in 5': 'assignees in [5]',
      'project = 4': 'project = 4',
      'project in 1, 2': 'project in [1,2]',
      'title like Foo': "title like 'Foo'",
      "title like 'foo bar'": "title like 'foo bar'",
      'due_date > now': 'due_date > now',
      'due_date > now/d': 'due_date > now/d',
      'due_date > now+7d': 'due_date > now+7d',
      'due_date < now-1w': 'due_date < now-1w',
      'start_date >= now-1M': 'start_date >= now-1M',
      'end_date <= now+2y': 'end_date <= now+2y',
      'due_date > now/d+7d': 'due_date > now/d+7d',
      'due_date = 2026-07-18T00:00:00Z': 'due_date = 2026-07-18T00:00:00.000Z',
      // Alle Operatoren.
      'priority = 5 && priority <= 9': '(priority = 5 && priority <= 9)',
      // Präzedenz: && bindet stärker als ||.
      'done = false && due_date > now/d || priority >= 3':
          '((done = false && due_date > now/d) || priority >= 3)',
      // Klammern kehren Präzedenz um.
      'done = false && (due_date > now/d || priority >= 3)':
          '(done = false && (due_date > now/d || priority >= 3))',
      // Verschachtelte Klammern.
      '((done = true))': 'done = true',
    };

    cases.forEach((input, expected) {
      test(input, () => expect(render(FilterParser.parse(input)), expected));
    });
  });

  group('kaputte / nicht unterstützte Ausdrücke', () {
    final broken = <String>[
      '', // leer
      'foobar = 1', // unbekanntes Feld
      'done', // Operator fehlt
      'done =', // Wert fehlt
      'priority > abc', // keine Zahl
      'done > true', // Operator für bool nicht erlaubt
      'title > x', // Operator für title nicht erlaubt
      'labels like 1', // like nur für title
      'due_date = kaputt', // ungültiges Datum
      'due_date > now/w', // Rundungseinheit nicht unterstützt
      'due_date > now+3x', // Zeiteinheit unbekannt
      'due_date > now+', // Zahl fehlt
      'priority = 1 &', // unvollständiges &&
      'priority = 1 |', // unvollständiges ||
      '(priority = 1', // fehlende Klammer
      'priority = 1)', // überzählige Klammer
      'priority = 1 && ', // rechte Seite fehlt
      'in in 1', // Feld = Keyword ohne Operator
    ];
    for (final input in broken) {
      test('"$input" -> UnsupportedFilterException', () {
        expect(
          () => FilterParser.parse(input),
          throwsA(isA<UnsupportedFilterException>()),
        );
      });
    }
  });
}
