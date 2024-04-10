#ifndef INPUTINTERFACE_H
#define INPUTINTERFACE_H

#include <godot_cpp/classes/static_body2d.hpp>
#include <godot_cpp/classes/cpu_particles2d.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/variant/vector2.hpp>

namespace godot {

class InputInterface : public Node2D {
	GDCLASS(InputInterface, Node2D)

private:
	double time_passed;
  CPUParticles2D _mouse_particle;
  CharacterBody2D _player;
  double speed;
  double fast_speed;
  Vector2 velocity;
	Vector2 current_position;
	Vector2 target_position;

protected:
	static void _bind_methods();

public:
	InputInterface();
	~InputInterface();

  void _ready() override;
	void _process(double delta) override;
  // speed getter/setter
  double get_speed() const;
  void set_speed(const double speed);
  double get_fast_speed() const;
  void set_fast_speed(const double fast_speed);
};

}

#endif