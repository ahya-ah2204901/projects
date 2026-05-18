import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChequeImageScreen extends ConsumerStatefulWidget {
  final String? chequeFilePath;
  const ChequeImageScreen({super.key, required this.chequeFilePath});

  @override
  ConsumerState<ChequeImageScreen> createState() => _ChequeImageScreenState();
}

class _ChequeImageScreenState extends ConsumerState<ChequeImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: const Text("Cheque Image"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1.0,
            maxScale: 3.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Image.file(
                    File(widget.chequeFilePath!),
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
