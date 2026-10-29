import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/core/utils/check_internet_conexion.dart';

void main() {
  test('does not emit when an internet check finishes after close', () async {
    final verification = Completer<bool>();
    final checker = CheckInternetConnection(
      verifyInternet: () => verification.future,
    );
    final statuses = <ConnectionStatus>[];
    final subscription = checker.internetStatus().listen(statuses.add);

    await checker.close();
    verification.complete(true);
    await Future<void>.delayed(Duration.zero);

    expect(statuses, isEmpty);
    await subscription.cancel();
  });
}
