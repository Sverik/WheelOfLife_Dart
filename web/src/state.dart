library state;

class State {
	/** Camera angle */
	double c_a = 280.0;
	/** Camera radius, this radius is at vieport bottom */
	double c_r = 1400.0;

	double p_a = 107.0;
	double p_r = 238.0;

	/** Character's radial velocity */
	double p_rv = 0.0;
	/** Character's linear velocity */
	double p_lv = 0.0;

	Season season = Season.SPRING;

}

class Season {
	final _value;
	const Season._internal(this._value);
	toString() => 'Season.$_value';

	static const WINTER = const Season._internal('WINTER'); // 0-90
	static const SPRING = const Season._internal('SPRING'); // 90-180
	static const SUMMER = const Season._internal('SUMMER'); // 180-270
	static const AUTUMN = const Season._internal('AUTUMN'); // 270-360

	static int length() {
		return 4;
	}

	static Season get(int index) {
		switch (index) {
			case 0: return WINTER;
			case 1: return SPRING;
			case 2: return SUMMER;
			case 3: return AUTUMN;
		}
		return null;
	}
}
