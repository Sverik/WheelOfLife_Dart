library state;

class State {
	/** Camera angle */
	double c_a = 20.0;
	/** Camera radius, this radius is at vieport bottom */
	double c_r = 60.0;

	double p_a = 107.0;
	double p_r = 240.0;

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
}
