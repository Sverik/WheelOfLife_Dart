library canvas;

import 'dart:math' as math;
import 'dart:html';
import 'state.dart';
import 'world.dart';
import 'line.dart';

class Canvas {

	static const int SEASON_TEXT_DURATION = 2800;
	static const double SEASON_TEXT_FADE_START = 2000.0;
//	static const Font SEASON_TEXT_FONT = new Font("SansSerif", Font.BOLD, 50);

	static final List<Color> backgrounds = [new Color(211, 248, 255), new Color(168, 255, 125), new Color(234, 217, 87), new Color(203, 100, 99)];

	static final blokeColors = {
		Season.WINTER: new Color(35, 95, 217),
		Season.SPRING: new Color(85, 162, 58),
		Season.SUMMER: new Color(129, 142, 79),
		Season.AUTUMN: new Color(131, 49, 36)
	};

	final State state;
	final World world;

	int width = 0;
	int height = 0;
	double w_2 = 0.0;

	double delta;
	int seasonTextRemaining;
	int textWidth;

	Season previousSeason = null;

	Canvas(State state, World world)
			: state = state,
			  world = world;

	void repaint(CanvasElement canvasElement, double delta) {
		this.delta = delta;
		CanvasRenderingContext2D g = canvasElement.context2D;
//		g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

		if (width != canvasElement.width || height != canvasElement.height) {
			width = canvasElement.width;
			height = canvasElement.height;
			w_2 = width / 2;
		}

		paintBackground(g);

		paintWorld(g);

		paintBloke(g);

		return;

		paintOverlay(g);
	}

	void paintBackground(CanvasRenderingContext2D g) {
		g.setFillColorRgb(192, 192, 192);
		g.fillRect(0, 0, width, height);

		const double r = 1500.0;
		double cx = w_2;
		double cy = -state.c_r + height;
		double angle = 0.0;
		for (Color c in backgrounds) {
			g.beginPath();
			PointM p = polarToScreen(angle + 90.0, r, null);
			g.moveTo(p.x, p.y);
			g.lineTo(cx, cy);
			polarToScreen(angle, r, p);
			g.lineTo(p.x, p.y);
			double screenAngle_r = worldToScreenAngle(angle) * math.PI / 180.0;
			g.arc(cx, cy, r, screenAngle_r, screenAngle_r - math.PI / 2, true);
			g.fillStyle = c.rgb;
//			g.strokeStyle = c.rgb;
//			g.stroke();
			g.fill();

			angle += 90.0;
		}
	}

	void paintWorld(CanvasRenderingContext2D g) {
		g.strokeStyle = "#000";
		for (Line line in world.getLines()) {

			paintLineWithArc(g, line);

		}
	}

	void paintLineWithArc(CanvasRenderingContext2D g, Line line) {
		g.beginPath();

		double thickness = (line.r1 - line.r0).abs();
		g.lineWidth = thickness;

		double r = (line.r0 + line.r1) / 2;

		double ox = -(r - w_2);
		double cx = ox + r;
		double oy = -(r + state.c_r - height);
		double cy = oy + r;

		double arc = line.a1 - line.a0;
		if (arc < 0) {
			arc += 360;
		}

		double startAngle_r = worldToScreenAngle(line.a0) * math.PI / 180.0;
		double endAngle_r = worldToScreenAngle(line.a1) * math.PI / 180.0;

		g.arc(cx, cy, r, startAngle_r, endAngle_r, true);
		g.stroke();

	}

	void paintBloke(CanvasRenderingContext2D g) {

		PointM s = polarToScreen(state.p_a, state.p_r);

		g.beginPath();
		g.arc(s.x, s.y, 5, 0, math.PI * 2);
		g.fillStyle = blokeColors[state.season].rgb;
		g.fill();
	}

	void paintOverlay(CanvasRenderingContext2D g) {
		if (previousSeason != state.season) {
			seasonTextRemaining = SEASON_TEXT_DURATION;
			textWidth = g.getFontMetrics(SEASON_TEXT_FONT).stringWidth(state.season.toString());
		}
		previousSeason = state.season;

		if (seasonTextRemaining > 0) {
			seasonTextRemaining -= delta;
			g.setFont(SEASON_TEXT_FONT);
			Color c = new Color.alpha(0, 0, 0, /*Math.min(1, (double)seasonTextRemaining / SEASON_TEXT_FADE_START)*/ 1.0);
			g.setColor(c);
			g.drawString(state.season.toString(), (getWidth() - textWidth) / 2, 100);
		}
	}

	static PointM polarToCart(double a, double r, PointM out) {
		if (out == null) {
			out = new PointM(0.0, 0.0);
		}
		double radianAngle = a * math.PI / 180.0;
		out.x = r * math.cos(radianAngle);
		out.y = r * math.sin(radianAngle);

		return out;
	}

	PointM polarToScreen(double a, double r, [PointM out = null]) {
		if (out == null) {
			out = new PointM(0.0, 0.0);
		}

		polarToCart(worldToScreenAngle(a), r, out);

		out.x += w_2;
		out.y += height - state.c_r;

		return out;
	}

	double worldToScreenAngle(double worldAngle) {
		return -worldAngle + state.c_a + 90;
	}

}

class PointM {
	double x;
	double y;

	PointM(double x, double y)
			: x = x,
			  y = y;
}


class Color {
	final int r;
	final int g;
	final int b;
	final double a;
	final String rgb;
	final String rgba;

	Color(int r, int g, int b)
			: r = r,
			  g = g,
			  b = b,
			  a = 1.0,
			  rgb = 'rgb($r, $g, $b)',
			  rgba = 'rgba($r, $g, $b, 1.0)';

	Color.alpha(int r, int g, int b, double a)
			: r = r,
			  g = g,
			  b = b,
			  a = a,
			  rgb = 'rgb($r, $g, $b)',
			  rgba = 'rgba($r, $g, $b, $a)';
}
