import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

import 'loading_controller.dart';

export 'loading_controller.dart';

mixin LoadingWidgetMixin on Widget {
  LoadingController get controller;
}

abstract class Loading {
  static LoadingController? _currentController;
  static bool _loadingStarted = false;
  static bool _isShowing = false;

  static void show(
    LoadingWidgetMixin loadingWidget, {
    Color? backgroundColor,
  }) {
    _loadingStarted = true;
    _currentController = loadingWidget.controller;

    Get.dialog(
      loadingWidget,
      barrierDismissible: false,
      barrierColor: backgroundColor,
    );

    _isShowing = true;
  }

  static void start(LoadingController controller) {
    _loadingStarted = true;
    _currentController = controller;
  }

  static void proceed(String message) {
    if (!_loadingStarted) return;
    if (_currentController == null) {
      hide(force: true);
      return;
    }
    _currentController!.proceed(message);
  }

  static void complete({bool force = true}) {
    if (_currentController == null) {
      hide(force: true);
      return;
    }
    if (!force && _currentController!.isCompleted) {
      return;
    }
    _currentController!.complete();
    hide();
  }

  static void hide({bool force = false}) {
    if (_currentController != null &&
        !force &&
        _currentController!.isCompleted) {
      return;
    }

    if (_isShowing) {
      Get.back();
      _isShowing = false;
    }

    _currentController = null;
    _loadingStarted = false;
  }
}
