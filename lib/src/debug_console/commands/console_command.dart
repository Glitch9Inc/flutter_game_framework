import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';

/// 모든 커맨드는 2개의 인자를 받습니다
abstract class ConsoleCommand {
  final DebugConsoleController _controller = Get.put(DebugConsoleController());
  String get input;
  String get help;

  /// when the command is called without a parameter, this is the default parameter
  int get defaultParameter;

  void execute(List<String> args) {
    if (args.isEmpty) {
      _controller.logger.warning('콘솔 명령어 $input는 인자가 필요합니다');
      return;
    }

    if (args[0] == 'help') {
      _controller.logger.info(help);
      return;
    }

    var parameter = defaultParameter;

    if (args.length > 1) {
      parameter = parseParameter(args[1]);
      if (parameter == -1) return;
    }

    // Parameter(인자)가 없으면 DefaultParameter를 사용

    var index = int.tryParse(args[0]);
    if (index != null) {
      onExecuteIndex(index, parameter);
    } else {
      onExecuteId(args[0], parameter);
    }
  }

  int parseParameter(String arg) {
    var parameter = int.tryParse(arg);
    if (parameter == null) {
      _controller.logger.warning('콘솔 명령어 인자 $arg는 숫자여야 합니다');
      return -1;
    }
    return parameter;
  }

  void onExecuteIndex(int index, int parameter);
  void onExecuteId(String id, int parameter);
}
