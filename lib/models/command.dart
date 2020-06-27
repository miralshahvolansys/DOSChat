import '../utility/enum.dart';

class ModelCommand {
  String prefixText = 'C:\\';
  eCommandType commandType = eCommandType.none;
  eInputType inputType = eInputType.none;
  bool allowEditing = false;
  String infoText = '';
  String inputText = '';
}
