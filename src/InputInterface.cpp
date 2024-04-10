#include <iostream>
#include "InputInterface.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void InputInterface::_bind_methods() {
  ClassDB::bind_method(D_METHOD("get_speed"), &InputInterface::get_speed);
  ClassDB::bind_method(D_METHOD("set_speed"), &InputInterface::set_speed);
  ClassDB::add_property("InputInterface", PropertyInfo(Variant::FLOAT, "speed"), "set_speed", "get_speed");

  ClassDB::bind_method(D_METHOD("get_fast_speed"), &InputInterface::get_fast_speed);
  ClassDB::bind_method(D_METHOD("set_fast_speed"), &InputInterface::set_fast_speed);
  ClassDB::add_property("InputInterface", PropertyInfo(Variant::FLOAT, "fast_speed"), "set_fast_speed", "get_fast_speed");
}

InputInterface::InputInterface() {
  if (Engine::get_singleton()->is_editor_hint()) {
    // disable process in editor mode
    set_process_mode(Node::ProcessMode::PROCESS_MODE_DISABLED);
  }

  UtilityFunctions::print("hello world");
}

InputInterface::~InputInterface() {
	// Add your cleanup here.
}

void InputInterface::_ready() {
  // Initialize any variables here.
	time_passed = 0.0;
  // CharacterBody2D _player = get_node(NodePath("Player"));
  // CPUParticles2D _mouse_particle = get_node(NodePath("mouse_particle"));
  current_position = _player.get_position();
}

void InputInterface::_process(double delta) {
  // handle input event
  Input& inputSingleton = *Input::get_singleton();

  // wasd input event
  if (inputSingleton.is_action_pressed("d")) {
    velocity.x += 1.0f;
  }
  if (inputSingleton.is_action_pressed("a")) {
    velocity.x -= 1.0f;
  }
  if (inputSingleton.is_action_pressed("w")) {
    velocity.y -= 1.0f;
  }
  if (inputSingleton.is_action_pressed("s")) {
    velocity.y += 1.0f;
  }
  set_position(get_position() + (velocity * speed * delta));
  
  if (inputSingleton.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) {
    // get mouse-click position
    set_position(get_position() + (velocity * speed * delta));
    // particle effect
  }
}

void InputInterface::set_speed(const double speed) {
  this->speed = speed;
}

double InputInterface::get_speed() const {
  return speed;
}

void InputInterface::set_fast_speed(const double fast_speed) {
  this->fast_speed = fast_speed;
}

double InputInterface::get_fast_speed() const {
  return fast_speed;
}