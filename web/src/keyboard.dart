library keyboard;

import 'dart:html';
import 'input_state.dart';

class KeyboardListener {
	final InputState inputState;

	KeyboardListener(InputState inputState)
			: inputState = inputState {

		window.onKeyDown.listen((KeyboardEvent e) {
			keyStateChanged(e, true);
		});

		window.onKeyUp.listen((KeyboardEvent e) {
			keyStateChanged(e, false);
		});

	}

	void keyStateChanged(KeyboardEvent e, bool pressed) {
//		print("k=${e.keyCode}, $pressed");
		switch (e.keyCode) {
		case 37:
			inputState.left = pressed;
			break;
		case 39:
			inputState.right = pressed;
			break;
		case 38:
			inputState.up = pressed;
			break;
//		case KeyEvent.VK_DOWN:
//			state.down = pressed;
//			break;
//		case KeyEvent.VK_PAGE_DOWN:
//			state.forward = pressed;
//			break;
		case 33:
			inputState.down = pressed;
			break;
		}
	}

}
