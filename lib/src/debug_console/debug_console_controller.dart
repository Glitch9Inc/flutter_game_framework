import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:logging/logging.dart';

import 'commands/console_command.dart';

class DebugConsoleController extends GetxController {
  final Logger logger = Logger('DebugConsoleController');
  final Map<String, ConsoleCommand> _commands = {
    // 'help': HelpCommand(),
    // add more commands here
  };

  void enterCommand(String command) {
    if (command.isEmpty) return;
    List<String> commandSplit = command.split(' ');
    String commandName = commandSplit[0];
    List<String> commandArgs = commandSplit.sublist(1);
    executeCommand(commandName, commandArgs);
  }

  void executeCommand(String command, List<String> args) {
    if (!_commands.containsKey(command)) {
      logger.warning('알 수 없는 콘솔 명령어입니다');
      return;
    }
    _commands[command]!.execute(args);
  }
}
