extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer

const MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punc_time = 0.2

signal _finish_displaying()

# TODO: set visible to false on _ready()
# TODO: set visible to true when displaying text >> set visible to false after timer end

func _ready():
	# set visible to false on default
	visible = false

func _display_text(display_text):
	text = display_text
	label.text = display_text
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		# apply text-wrap
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # wait for x resize
		await resized # wait for y resize
		custom_minimum_size.y = size.y
