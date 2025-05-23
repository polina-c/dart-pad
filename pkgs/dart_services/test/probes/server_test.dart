// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../probes_and_presubmit/server_test.dart';
import '../test_infra/utils.dart';

void main() {
  for (final client in dartServicesProdClients) {
    testServer(client);
  }
}
