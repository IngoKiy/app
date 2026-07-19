/// AST für Vikunja-Übersichts-Filter (Meilenstein M3, Paket F1).
///
/// Der Parser ([FilterParser]) baut aus einem Filterstring einen Baum aus
/// [FilterExpr]-Knoten, den der [FilterEvaluator] gegen einen [Task] auswertet.
/// Alles, was nicht sicher geparst werden kann, führt zu einer
/// [UnsupportedFilterException] – der Aufrufer fällt dann auf den Online-Pfad
/// zurück, statt lokal falsch zu filtern.
library;

/// Wird geworfen, wenn ein Filterstring ein nicht unterstütztes Feld,
/// Konstrukt oder einen Syntaxfehler enthält.
class UnsupportedFilterException implements Exception {
  final String message;
  UnsupportedFilterException(this.message);

  @override
  String toString() => 'UnsupportedFilterException: $message';
}

/// Logische Verknüpfung zweier Teilausdrücke.
enum LogicOp { and, or }

/// Vergleichsoperatoren der Filtergrammatik.
enum CompareOp { eq, neq, gt, lt, gte, lte, inList, like }

/// Basisklasse aller Filter-Knoten.
sealed class FilterExpr {
  const FilterExpr();
}

/// Verknüpfung `left && right` bzw. `left || right`.
class LogicNode extends FilterExpr {
  final LogicOp op;
  final FilterExpr left;
  final FilterExpr right;
  const LogicNode(this.op, this.left, this.right);
}

/// Einzelbedingung `field op value` (z.B. `priority >= 3`).
class ConditionNode extends FilterExpr {
  final String field;
  final CompareOp op;
  final FilterValue value;
  const ConditionNode(this.field, this.op, this.value);
}

/// Werte auf der rechten Seite einer Bedingung.
sealed class FilterValue {
  const FilterValue();
}

class BoolValue extends FilterValue {
  final bool value;
  const BoolValue(this.value);
}

class NumValue extends FilterValue {
  final num value;
  const NumValue(this.value);
}

class StringValue extends FilterValue {
  final String value;
  const StringValue(this.value);
}

/// Absolutes ISO-Datum (immer in UTC gehalten).
class DateValue extends FilterValue {
  final DateTime value;
  const DateValue(this.value);
}

/// `now`-Ausdruck mit optionaler Arithmetik/Rundung. Die Schritte werden zur
/// Auswertungszeit gegen das (injizierbare) `now` angewendet.
class NowValue extends FilterValue {
  final List<NowStep> steps;
  const NowValue(this.steps);
}

/// Liste von Werten für den `in`-Operator (z.B. `labels in 1,2`).
class ListValue extends FilterValue {
  final List<FilterValue> values;
  const ListValue(this.values);
}

/// Ein Rechenschritt innerhalb eines `now`-Ausdrucks.
sealed class NowStep {
  const NowStep();
}

/// Rundung auf den Anfang einer Einheit, z.B. `/d` = Tagesanfang.
class NowRound extends NowStep {
  /// Einheit: s, m, h, d.
  final String unit;
  const NowRound(this.unit);
}

/// Verschiebung um [amount] (vorzeichenbehaftet) Einheiten, z.B. `+7d`.
class NowOffset extends NowStep {
  final int amount;

  /// Einheit: s, m, h, d, w, M, y.
  final String unit;
  const NowOffset(this.amount, this.unit);
}
