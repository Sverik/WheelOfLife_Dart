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

	static final List<Color> blokeColors = [new Color(35, 95, 217), new Color(85, 162, 58), new Color(129, 142, 79), new Color(131, 49, 36)];

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
			  world = world {
	}

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

		return;

		paintBloke(g);

		paintOverlay(g);
	}

	void paintBackground(CanvasRenderingContext2D g) {
		g.setFillColorRgb(0, 0, 192);
		g.fillRect(0, 0, width, height);

		const double r = 1500.0;
		double cx = w_2;
		double cy = -state.c_r + height;
		double angle = worldToScreenAngle(0.0);
		for (Color c in backgrounds) {
			g.beginPath();
			PointM p = polarToScreen(angle - 90.0, r, null);
			g.moveTo(p.x, p.y);
			log("move:x=${p.x.truncate()},y=${p.y.truncate()}");
			g.lineTo(cx, cy);
			log("line:x=${cx.truncate()},y=${cy.truncate()}");
			polarToScreen(angle, r, p);
			g.lineTo(p.x, p.y);
			log("line:x=${p.x.truncate()},y=${p.y.truncate()}");
			g.arc(cx, cy, r, angle * math.PI / 180.0, (angle - 0.1) * math.PI / 180.0 - math.PI / 2, true);
			log("arc:x=${cx.truncate()},y=${cy.truncate()}");
			g.fillStyle = c.rgb;
//			g.strokeStyle = c.rgb;
//			g.stroke();
			g.fill();

//			Arc2D.double arc = new Arc2D.double(ox, oy, (r * 2), (r * 2), angle, 90.1f, Arc2D.PIE);
//			g.fill(arc);
			angle -= 90.0;
//			break;

		}
	}

	void log(String text) {
		querySelector("#sample_text_id").text += "\n" + text;
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
//		g.setStroke(new BasicStroke(thickness, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL));

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
//		Arc2D.double af = new Arc2D.double(ox, oy, (r * 2), (r * 2), startAngle, arc, Arc2D.OPEN);

	}

	void paintBloke(CanvasRenderingContext2D g) {

		Point2D.double s = polarToScreen(state.p_a, state.p_r - 3);

		g.setColor(blokeColors[state.season.ordinal()]);
		g.fillOval((int)(s.x - 5), (int)(s.y - 5), 10, 10);
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

	PointM polarToScreen(double a, double r, PointM out) {
		if (out == null) {
			out = new PointM(0.0, 0.0);
		}

		polarToCart(a, r, out);

		out.x += w_2;
		out.y += height - state.c_r;

		return out;
	}

	double worldToScreenAngle(double worldAngle) {
		return - worldAngle + state.c_a + 90;
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
