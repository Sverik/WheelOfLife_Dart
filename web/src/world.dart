library world;

import 'dart:html';
import 'line.dart';

class World {

	List<Line> lines = new List();

	List<Line> getLines() {
		return lines;
	}

	void load() {
	  var semicolon = ';'.codeUnitAt(0);
    var result = [];

    String url = "world.def";
    HttpRequest.getString(url).then((content){
    	String clean = content.toString().replaceAll(new RegExp(r"#[^$]*$"), "");
      RegExp exp = new RegExp(r"L\(([^)]+)\)");
      Iterable<Match> matches = exp.allMatches(clean);
      for (Match m in matches) {
      	parseParameters(m.group(1));
      }
    });
	}

	void parseParameters(String params) {
		var p = [0.0, 0.0, 0.0, 0.0];
		int i = 0;
		RegExp exp = new RegExp(r"(-?[\d.]+)");
    Iterable<Match> matches = exp.allMatches(params);
    for (Match m in matches) {
    	if (i >= p.length) {
    		break;
    	}
			p[i++] = double.parse(m.group(1));
		}

		if (p[0] < p[1]) {
			lines.add(new Line(p[0], p[1], p[2], p[3]));
		} else {
			lines.add(new Line(p[0], 360.1, p[2], p[3]));
			lines.add(new Line(-0.1, p[1], p[2], p[3]));
		}
	}

}
