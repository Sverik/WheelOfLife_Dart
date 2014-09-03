library world;

import 'line.dart';

class World {
	//static final Pattern linePattern = Pattern.compile("L\\(([^)]+)\\)");
	//static final Pattern parameterPattern = Pattern.compile("(-?[\\d.]+)");

	List<Line> lines = new List();

	List<Line> getLines() {
		return lines;
	}

	void load() {
/*
		lines = new List<Line>();
		BufferedReader r = null;
		try {
			InputStream in = getClass().getResourceAsStream("/world.def");
			r = new BufferedReader(new InputStreamReader(in));
			String fileLine;
			while ((fileLine = r.readLine()) != null) {
				// remove comments starting with hash
				fileLine = fileLine.replaceAll("#.*", "");
				parseFileLine(fileLine);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (r != null) {
			try {
				r.close();
			} catch (IOException e) {}
		}
*/
		lines.add(new Line(103.0, 112.0, 250.0, 260.0));
		lines.add(new Line(108.0, 112.0, 220.0, 288.0));
    lines.add(new Line(95.0, 97.0, 220.0, 800.0));
    lines.add(new Line(95.0, 97.0, 795.0, 1205.0));
    lines.add(new Line(95.0, 97.0, 1200.0, 1500.0));
    lines.add(new Line(104.0, 106.0, 255.0, 815.0));
    lines.add(new Line(104.0, 106.0, 810.0, 1185.0));
    lines.add(new Line(104.0, 106.0, 1180.0, 1450.0));
	}

/*
	void parseFileLine(String fileLine) {
		Matcher m = linePattern.matcher(fileLine);
		while (m.find()) {
			parseParameters(m.group(1));
		}
	}

	void parseParameters(String params) {
		Matcher m = parameterPattern.matcher(params);
		float[] p = new float[4];
		int i = 0;
		while (m.find() && i < p.length) {
			try {
				p[i++] = parseParam(m.group(1));
			} catch (Exception e) {}
		}
		if (p[0] < p[1]) {
			lines.add(new Line(p[0], p[1], p[2], p[3]));
		} else {
			lines.add(new Line(p[0], 361, p[2], p[3]));
			lines.add(new Line(-1, p[1], p[2], p[3]));
		}
	}

	float parseParam(String paramString) {
		return Float.parseFloat(paramString.trim());
	}
*/
}
