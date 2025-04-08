// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import '../model.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets.dart';
import 'editor.dart';

class GeneratingCodePanel extends StatefulWidget {
  const GeneratingCodePanel({
    required this.appModel,
    required this.appServices,
    super.key,
  });

  final AppModel appModel;
  final AppServices appServices;

  @override
  State<GeneratingCodePanel> createState() => _GeneratingCodePanelState();
}

class _GeneratingCodePanelState extends State<GeneratingCodePanel> {
  final _focusNode = FocusNode();
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();

    final genAiManager = widget.appModel.genAiManager;

    final stream = genAiManager.stream;

    _subscription = stream.value.listen(
      (text) => setState(() {
        genAiManager.writeToStreamBuffer(text);
      }),
      onDone: () {
        setState(() {
          final generatedCode = genAiManager.generatedCode().trim();
          if (generatedCode.isEmpty) {
            widget.appModel.editorStatus.showToast('Error generating code');
            widget.appModel.appendError(
              'There was an error generating your code, please try again.',
            );
            widget.appModel.genAiManager.enterStandby();
            return;
          }
          genAiManager.setStreamBufferValue(generatedCode);
          genAiManager.setStreamIsDone(true);
          genAiManager.enterAwaitingAcceptReject();
          _focusNode.requestFocus();
          widget.appModel.sourceCodeController.textNoScroll = generatedCode;
          widget.appServices.performCompileAndReloadOrRun();
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genAiManager = widget.appModel.genAiManager;
    return ValueListenableBuilder(
      valueListenable: genAiManager.streamIsDone,
      builder: (
        BuildContext context,
        bool genAiCodeStreamIsDone,
        Widget? child,
      ) {
        final resolvedSpinner =
            genAiCodeStreamIsDone
                ? SizedBox(width: 0, height: 0)
                : Positioned(
                  top: 10,
                  right: 10,
                  child: AnimatedContainer(
                    duration: animationDelay,
                    curve: animationCurve,
                    child: CircularProgressIndicator(),
                  ),
                );
        return Stack(
          children: [
            resolvedSpinner,
            MultiValueListenableBuilder(
              listenables: [
                genAiManager.streamBuffer,
                widget.appModel.genAiManager.isGeneratingNewProject,
                genAiManager.preGenAiSourceCode,
              ],
              builder: (_) {
                final genAiCodeStreamBuffer =
                    genAiManager.streamBuffer.value.toString();
                final isGeneratingNewProject =
                    widget.appModel.genAiManager.isGeneratingNewProject.value;
                return Focus(
                  autofocus: true,
                  focusNode: _focusNode,
                  child:
                      isGeneratingNewProject
                          ? ReadOnlyCodeWidget(genAiCodeStreamBuffer)
                          : ReadOnlyDiffWidget(
                            existingSource:
                                genAiManager.preGenAiSourceCode.value,
                            newSource: genAiCodeStreamBuffer,
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
