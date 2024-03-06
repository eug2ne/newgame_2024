#include "GameManager.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/input_event.hpp>

using namespace godot;

void GameManager::_bind_methods() {
}

GameManager::GameManager() {
	// Initialize any variables here.
	time_passed = 0.0;
}

GameManager::~GameManager() {
	// Add your cleanup here.
}

void GameManager::_process(double delta) {
}

void _input(InputEvent event) {
}