#ifndef GAMEMANAGER_H
#define GAMEMANAGER_H

#include <godot_cpp/classes/node.hpp>

namespace godot {

class GameManager : public Node {
	GDCLASS(GameManager, Node)

private:
	double time_passed;

protected:
	static void _bind_methods();

public:
	GameManager();
	~GameManager();

	void _process(double delta) override;
};

}

#endif