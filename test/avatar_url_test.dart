import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/domain/entities/user.dart';

void main() {
  final user = User(id: 1, username: 'ingo');

  test('Avatar-URL folgt der echten Server-Route /avatar/<username>', () {
    expect(
      user.avatarUrl('https://example.org/api/v1'),
      'https://example.org/api/v1/avatar/ingo',
    );
  });

  test('Cache-Buster hängt als Query-Parameter an', () {
    expect(
      user.avatarUrl('https://example.org/api/v1', cacheBuster: '42'),
      'https://example.org/api/v1/avatar/ingo?v=42',
    );
    // Leerer Buster ändert die URL nicht.
    expect(
      user.avatarUrl('https://example.org/api/v1', cacheBuster: ''),
      'https://example.org/api/v1/avatar/ingo',
    );
  });
}
