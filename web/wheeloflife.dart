import 'dart:html';
import 'dart:math' as math;
import 'dart:async';

import 'src/state.dart';
import 'src/world.dart';
import 'src/canvas.dart';

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

void main() {
	querySelector("#sample_text_id")
			..text = "Click me!"
			..onClick.listen(reverseText);

	world.load();

	requestTick();
}

void reverseText(MouseEvent event) {
	var text = querySelector("#sample_text_id").text;
	var buffer = new StringBuffer();
	for (int i = text.length - 1; i >= 0; i--) {
		buffer.write(text[i]);
	}
	querySelector("#sample_text_id").text = buffer.toString();

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
		querySelector("#sample_text_id").text = min.truncate().toString() + " ms ... " + max.truncate().toString() + " ms, " + avg.truncate().toString() + " ms, time=" + time.truncate().toString() + ", c_a=" + state.c_a.truncate().toString();

		logic(diff);

  	draw(diff);
	}

	ticking = false;

	new Future.delayed(const Duration(milliseconds: 20), () {
		requestTick();
	});
}

void logic(double delta) {
//	state.c_a += delta / 50;
	state.c_a = state.c_a % 360.0;
}

void draw(double delta) {
//	var random = new math.Random();
//	random.nextInt(300)
	canvas.repaint(canvasElement, delta);

//	context.clearRect(0, 0, canvasElement.width, canvasElement.height);

	context..beginPath()
				 ..lineWidth = 20
				 ..strokeStyle = ORANGE
				 ..arc(100, 120, SEED_RADIUS, 0, state.p_a / 180.0 * math.PI, false)
				 ..stroke();

	ticking = false;
}
