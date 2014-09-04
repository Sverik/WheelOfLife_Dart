import 'dart:html';
import 'dart:math' as math;
import 'dart:async';

import 'src/state.dart';
import 'src/world.dart';
import 'src/canvas.dart';
import 'src/logic.dart';
import 'src/keyboard.dart';
import 'src/input_state.dart';

const String ORANGE = "orange";
const int SEED_RADIUS = 25;
const int SCALE_FACTOR = 4;
const num TAU = math.PI * 1.6;

final CanvasElement canvasElement = querySelector("#canvas") as CanvasElement;
final CanvasRenderingContext2D context =
	canvasElement.context2D;

num centerX = canvasElement.width / 2;
num centerY = canvasElement.height / 2;

bool ticking = false;
double previous = -1000.0;

num min = 999999;
num max = 0;
int count = 0;
double avg = 0.0;

final State state = new State();
final World world = new World();
final Canvas canvas = new Canvas(state, world);
final InputState inputState = new InputState();
final Logic logic = new Logic(state, inputState, world);

void main() {
	world.load();

	new KeyboardListener(inputState);

	requestTick();
}

void requestTick() {
	if ( ! ticking) {
		window.requestAnimationFrame(update);
		ticking = true;
	}
}

void update(double time) {

	if (previous == -1000) {
		previous = time;
	} else {
		double diff = time - previous;
		previous = time;
		min = math.min(min, diff);
		max = math.max(max, diff);
		avg = (avg * count + diff) / ++count;

		logic.step(diff);

  	draw(diff);
	}

	ticking = false;

	new Future.delayed(const Duration(milliseconds: 20), () {
		requestTick();
	});
}

void draw(double delta) {
	canvas.repaint(canvasElement, delta);

	ticking = false;
}
