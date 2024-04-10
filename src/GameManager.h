#ifndef GAMEMANAGER_H
#define GAMEMANAGER_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/vector2.hpp>

namespace godot {

class GameManager : public Node {
	GDCLASS(GameManager, Node)

private:
	double time_passed;
	Vector2 current_position;
	Vector2 target_position;

protected:
	static void _bind_methods();

public:
	GameManager();
	~GameManager();

	void _process(double delta) override;
};

}

#endif