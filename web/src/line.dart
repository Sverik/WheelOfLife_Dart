library line;

import 'dart:math';

class Line {
	final double a0;
	final double a1;
	final double r0;
	final double r1;

	Line(double a0, double a1, double r0, double r1)
			: a0 = a0,
			  a1 = a1,
			  r0 = min(r0, r1),
			  r1 = max(r0, r1);
}
