part of virtual_keyboard;

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRows = [
  // Row 1
  const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ],
  // Row 2
  const [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    'p',
  ],
  // Row 3
  const [
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    ';',
    '\'',
  ],
  // Row 4
  const [
    'z',
    'x',
    'c',
    'v',
    'b',
    'n',
    'm',
    ',',
    '.',
    '/',
    '?',
  ],
  // Row 5
  const [
    '@',
    '_',
  ]
];

const List<List> _chatkeyRows = [
  // Row 1
  const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ],
  // Row 2
  const [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    'p',
  ],
  // Row 3
  const [
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    ';',
    '\'',
  ],
  // Row 4
  const [
    'z',
    'x',
    'c',
    'v',
    'b',
    'n',
    'm',
    ',',
    '.',
    '/',
  ],
  // Row 5
  const [
    '@',
    '_',
    'Exits Chat',
  ]
];

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRowsNumeric = [
  // Row 1
  const [
    '1',
    '2',
    '3',
  ],
  // Row 1
  const [
    '4',
    '5',
    '6',
  ],
  // Row 1
  const [
    '7',
    '8',
    '9',
  ],
  // Row 1
  const [
    '.',
    '0',
  ],
];

/// Returns a list of `VirtualKeyboardKey` objects for Numeric keyboard.
List<VirtualKeyboardKey> _getKeyboardRowKeysNumeric(rowNum) {
  // Generate VirtualKeyboardKey objects for each row.
  return List.generate(_keyRowsNumeric[rowNum].length, (int keyNum) {
    // Get key string value.
    String key = _keyRowsNumeric[rowNum][keyNum];

    // Create and return new VirtualKeyboardKey object.
    return VirtualKeyboardKey(
      text: key,
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

/// Returns a list of `VirtualKeyboardKey` objects.
List<VirtualKeyboardKey> _getKeyboardRowKeys(rowNum) {
  // Generate VirtualKeyboardKey objects for each row.
  return List.generate(_keyRows[rowNum].length, (int keyNum) {
    // Get key string value.
    String key = _keyRows[rowNum][keyNum];
//    print( _keyRows[rowNum]);
    // Create and return new VirtualKeyboardKey object.
    return VirtualKeyboardKey(
      text: key,
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

List<VirtualKeyboardKey> _getchatKeyboardRowKeys(rowNum) {
  // Generate VirtualKeyboardKey objects for each row.
  return List.generate(_chatkeyRows[rowNum].length, (int keyNum) {
    // Get key string value.
    String key = _chatkeyRows[rowNum][keyNum];

    // Create and return new VirtualKeyboardKey object.
    return VirtualKeyboardKey(
      text: key,
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

/// Returns a list of VirtualKeyboard rows with `VirtualKeyboardKey` objects.
List<List<VirtualKeyboardKey>> _getKeyboardRows(bool isChatScreen) {
  // Generate lists for each keyboard row.
  return List.generate(_keyRows.length, (int rowNum) {
    // Will contain the keyboard row keys.
    List<VirtualKeyboardKey> rowKeys = [];

    // We have to add Action keys to keyboard.
    switch (rowNum) {
      case 1:
        // String keys.
        rowKeys = _getKeyboardRowKeys(rowNum);

        // 'Backspace' button.
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Backspace),
        );
        break;
      case 2:
        // String keys.
        rowKeys = _getKeyboardRowKeys(rowNum);

        // 'Return' button.
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Return,
              text: '\n',
              capsText: '\n'),
        );
        break;
      case 3:
        // Left Shift
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Shift),
        );

        // String keys.
        rowKeys.addAll(_getKeyboardRowKeys(rowNum));

        // Right Shift
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Shift),
        );
        break;
      case 4:
        // String keys.
        if(isChatScreen) {
          rowKeys.add(VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Hybrid,
              text: 'Esc',
              capsText: 'ESC',
              action: VirtualKeyboardKeyAction.escape));
        }
        rowKeys.addAll( _getKeyboardRowKeys(rowNum));

        rowKeys.add( VirtualKeyboardKey(
            keyType: VirtualKeyboardKeyType.Action,
            text: ' ',
            capsText: ' ',
            action: VirtualKeyboardKeyAction.Space));

        rowKeys.add(VirtualKeyboardKey(
            keyType: VirtualKeyboardKeyType.Action,
            text: 'Enter',
            capsText: 'Enter',
            action: VirtualKeyboardKeyAction.close));
        if(isChatScreen) {

          rowKeys.add(VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Hybrid,
              text: 'Send',
              capsText: 'SEND',
              action: VirtualKeyboardKeyAction.send));
        }
        // Insert the space key into second position of row.
//        rowKeys.insert(
//          1,
//          VirtualKeyboardKey(
//              keyType: VirtualKeyboardKeyType.Action,
//              text: ' ',
//              capsText: ' ',
//              action: VirtualKeyboardKeyAction.Space),
//        );
//        rowKeys.insert(
//          2,
//          VirtualKeyboardKey(
//              keyType: VirtualKeyboardKeyType.Hybrid,
//              text: 'Esc',
//              capsText: 'Esc',
//              action: VirtualKeyboardKeyAction.escape),
//        );
//        rowKeys.insert(
//          3,
//          VirtualKeyboardKey(
//              keyType: VirtualKeyboardKeyType.Hybrid,
//              text: 'Enter',
//              capsText: 'Enter',
//              action: VirtualKeyboardKeyAction.enter),
//        );

        break;
      default:
        rowKeys = _getKeyboardRowKeys(rowNum);
    }

    return rowKeys;
  });
}


List<List<VirtualKeyboardKey>> _getchatKeyboardRows() {
  // Generate lists for each keyboard row.
  return List.generate(_keyRows.length, (int rowNum) {
    // Will contain the keyboard row keys.
    List<VirtualKeyboardKey> rowKeys = [];

    // We have to add Action keys to keyboard.
    switch (rowNum) {
      case 1:
      // String keys.
        rowKeys = _getchatKeyboardRowKeys(rowNum);

        // 'Backspace' button.
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Backspace),
        );
        break;
      case 2:
      // String keys.
        rowKeys = _getchatKeyboardRowKeys(rowNum);

        // 'Return' button.
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Return,
              text: '\n',
              capsText: '\n'),
        );
        break;
      case 3:
      // Left Shift
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Shift),
        );

        // String keys.
        rowKeys.addAll(_getchatKeyboardRowKeys(rowNum));

        // Right Shift
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Shift),
        );
        break;
      case 4:
      // String keys.
        rowKeys = _getchatKeyboardRowKeys(rowNum);

        // Insert the space key into second position of row.
        rowKeys.insert(
          1,
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              text: ' ',
              capsText: ' ',
              action: VirtualKeyboardKeyAction.Space),
        );

        break;
      default:
        rowKeys = _getchatKeyboardRowKeys(rowNum);
    }

    return rowKeys;
  });
}


/// Returns a list of VirtualKeyboard rows with `VirtualKeyboardKey` objects.
List<List<VirtualKeyboardKey>> _getKeyboardRowsNumeric() {
  // Generate lists for each keyboard row.
  return List.generate(_keyRowsNumeric.length, (int rowNum) {
    // Will contain the keyboard row keys.
    List<VirtualKeyboardKey> rowKeys = [];

    // We have to add Action keys to keyboard.
    switch (rowNum) {
      case 3:
        // String keys.
        rowKeys.addAll(_getKeyboardRowKeysNumeric(rowNum));

        // Right Shift
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Backspace),
        );
        break;
      default:
        rowKeys = _getKeyboardRowKeysNumeric(rowNum);
    }

    return rowKeys;
  });
}
