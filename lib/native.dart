import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;

import 'package:mask/extension.dart';

typedef CInitPaddleFunction = ffi.Void Function(
    ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);
typedef InitPaddleFunction = void Function(
    ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

typedef CBytesRegFunc = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8> input, ffi.Int32 inLength);

typedef BytesRegFunc = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8> input, int inLength);

class NativeOcr {
  static NativeOcr? _instance;

  bool isInited = false;

  late final ffi.DynamicLibrary lib;

  NativeOcr._internal();
  static NativeOcr get instance {
    _instance ??= NativeOcr._internal();
    return _instance!;
  }

  initOcr() {
    lib = ffi.DynamicLibrary.open("./ppocr.dll");
    final InitPaddleFunction init = lib
        .lookup<ffi.NativeFunction<CInitPaddleFunction>>("InitPaddle")
        .asFunction();
    init(
        r"D:\PaddleOCR-2.6.0\models\ch_PP-OCRv3_rec_infer".toNativeUtf8(),
        r"D:\PaddleOCR-2.6.0\models\ch_PP-OCRv3_det_infer".toNativeUtf8(),
        r"D:\PaddleOCR-2.6.0\models\ppocr_keys_v1.txt".toNativeUtf8());
    isInited = true;
  }

  String detectBytes(Uint8List input) {
    if (!isInited) {
      initOcr();
    }

    final BytesRegFunc func = lib
        .lookup<ffi.NativeFunction<CBytesRegFunc>>("ImageBytesProcess")
        .asFunction();
    final result = func(input.allocatePointer(), input.length);
    return result.toDartString();
  }
}

class NativeOcrIsolate {
  static NativeOcrIsolate? _instance;

  // ignore: avoid_init_to_null
  static Isolate? _isolate = null;
  NativeOcrIsolate._internal();
  static NativeOcrIsolate get instance {
    _instance ??= NativeOcrIsolate._internal();
    return _instance!;
  }

  Future ocr(Uint8List data,
      {required StreamController controller, VoidCallback? onError}) async {
    if (_isolate != null) {
      if (onError != null) {
        onError();
      }
      return;
    }

    final receivePort1 = ReceivePort();
    _isolate = await Isolate.spawn(_detect, receivePort1.sendPort);
    final sendPort2 = await receivePort1.first as SendPort;

    final answerReceivePort = ReceivePort();
    sendPort2.send([data, answerReceivePort.sendPort]);

    controller.sink.add("装载OCR模型中");

    String result = await answerReceivePort.first;

    _isolate = null;
    controller.sink.add("识别中");
    controller.sink.add(result);
    controller.sink.add("识别完成");
  }

  void _detect(SendPort sendPort1) {
    final receivePort2 = ReceivePort();
    sendPort1.send(receivePort2.sendPort);
    receivePort2.listen((message) {
      final imageData = message[0] as Uint8List;
      final send = message[1] as SendPort;

      String result = NativeOcr.instance.detectBytes(imageData);
      send.send(result);
    });
  }
}
