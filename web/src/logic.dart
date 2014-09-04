library logic;

import 'dart:math' as math;
import 'state.dart';
import 'world.dart';
import 'line.dart';
import 'canvas.dart';
import 'input_state.dart';

class SeasonParams {
	final userAcceleration;
	final frictionDeceleration;
	final jumpAcceleration;
	final maxLinearVelocity;

	const SeasonParams(double userAcceleration, double frictionDeceleration, double jumpAcceleration, double maxLinearVelocity) :
		this.userAcceleration = userAcceleration,
		this.frictionDeceleration = frictionDeceleration,
		this.jumpAcceleration = jumpAcceleration,
		this.maxLinearVelocity = maxLinearVelocity;
}

class Logic {

	static const params = const [
		const SeasonParams(0.6, 0.008, -0.30, 10.0), // winter
		const SeasonParams(2.8, 0.024, -0.30,  8.0), // spring
		const SeasonParams(3.0,   0.02,   -0.32, 12.0), // summer
		const SeasonParams(3.0,   0.02,   -0.30, 10.0)  // autumn
	];

	static const double FALL_ACCELERATION = 0.0006;
	static const double MAX_FALL_VELOCITY = 8.0;
	static final double BLOKE_FROM_CAMERA_BOTTOM = 120.0;
	static final double TOUCHING_GROUND_THRESHOLD = 0.005;
	static final double AIR_CONTROL_MULTIPLIER = 0.006;
	static final double CAMERA_ANGLE_APPROACH = 0.002;
	static final double CAMERA_RADIUS_APPROACH = 0.002;

	State state;
	World world;
	InputState inputState;

	PointM d = new PointM(0.0, 0.0);
	bool jumping = false;
	SeasonParams sParams;

	Logic(State state, InputState inputState, World world) :
		this.state = state,
		this.world = world,
		this.inputState = inputState;

	void step(double delta) {
		_updateSeason();

//		state.p_a += 0.5;

		_input(delta);

		_physics(delta);

		if ( ! _validLocation(d)) {
			state.p_rv = 0.0;
		}

		state.p_a += d.x;
		state.p_r += d.y;

		if (state.p_a >= 360) {
			state.p_a -= 360;
		}
		if (state.p_a < 0) {
			state.p_a += 360;
		}
		d.x = 0.0;
		d.y = 0.0;

		_updateCamera(delta);

	}

	void _updateSeason() {
		int seasonIndex = state.p_a ~/ 90;
		while (seasonIndex < 0) {
			seasonIndex += Season.length();
		}
		seasonIndex = seasonIndex % Season.length();
		state.season = Season.get(seasonIndex);
		sParams = params[seasonIndex];
	}

	void _physics(double delta) {
		state.p_rv += FALL_ACCELERATION * delta;
		if (state.p_rv > MAX_FALL_VELOCITY) {
			state.p_rv = MAX_FALL_VELOCITY;
		}
		d.y = delta * state.p_rv;

		if ( ! jumping) {
			state.p_lv -= (state.p_lv).sign * sParams.frictionDeceleration * delta;
		}
		d.x = delta * state.p_lv / (state.p_r + d.y);
	}

	bool _validLocation(PointM d) {
		bool collisionFree = true;
		double p_a = state.p_a + d.x;
		double p_r = state.p_r + d.y;
		double groundDistance = double.MAX_FINITE;
		if (p_a >= 360) {
			p_a -= 360;
		}
		if (p_a < 0) {
			p_a += 360;
		}
		for (Line line in world.getLines()) {
			if (line.a0 > p_a) {
				continue;
			}
			if (line.a1 < p_a) {
				continue;
			}

			groundDistance = math.min(groundDistance, (line.r0 - p_r).abs());

			if (line.r0 > p_r) {
				continue;
			}
			if (line.r1 < p_r) {
				continue;
			}

			// collision detected
			collisionFree = false;

			// how far can we go?
			if (d.x > 0 && line.a0 >= state.p_a && line.a0 - state.p_a < d.x) {
				d.x = line.a0 - state.p_a;
				p_a = state.p_a + d.x;
			} else if (d.x < 0 && line.a1 <= state.p_a && line.a1 - state.p_a > d.x) {
				d.x = line.a1 - state.p_a;
				p_a = state.p_a + d.x;
			}

			if (d.y > 0 && line.r0 >= state.p_r && line.r0 - state.p_r < d.y) {
				d.y = line.r0 - state.p_r;
				p_r = state.p_r + d.y;
			} else if (d.y < 0 && line.r1 <= state.p_r && line.r1 - state.p_r > d.y) {
				d.y = line.r1 - state.p_r;
				p_r = state.p_r + d.y;
			}
			groundDistance = math.min(groundDistance, (line.r0 - p_r).abs());
		}
		if (groundDistance < TOUCHING_GROUND_THRESHOLD) {
			jumping = false;
		}
		return collisionFree;
	}

	void _updateCamera(double delta) {
		if (delta > double.MAX_FINITE) {
			return;
		}

		double d_a = (state.p_a - state.c_a);
		if ((d_a).abs() > 180) {
			d_a -= (d_a).sign * 360;
		}
		state.c_a += d_a * CAMERA_ANGLE_APPROACH * delta;

		double d_r = (state.p_r + BLOKE_FROM_CAMERA_BOTTOM - state.c_r);
		state.c_r += d_r * CAMERA_RADIUS_APPROACH * delta;

		if (state.c_a >= 360) {
			state.c_a -= 360;
		}
		if (state.c_a < 0) {
			state.c_a += 360;
		}
	}

	void _input(double delta) {
		// debug
		if (inputState.down) {
			state.p_r -= 50;
		}

		if (inputState.up && ! jumping) {
			jumping = true;
			state.p_rv = sParams.jumpAcceleration;
		}

		double controlMultiplier = (jumping ? AIR_CONTROL_MULTIPLIER : 0.02) * delta;
		if (inputState.right) {
			state.p_lv += sParams.userAcceleration * controlMultiplier;
			if (state.p_lv > sParams.maxLinearVelocity) {
				state.p_lv = sParams.maxLinearVelocity;
			}
		} else if (inputState.left) {
			state.p_lv -= sParams.userAcceleration * controlMultiplier;
			if (state.p_lv < -sParams.maxLinearVelocity) {
				state.p_lv = -sParams.maxLinearVelocity;
			}
		}

	}

}
