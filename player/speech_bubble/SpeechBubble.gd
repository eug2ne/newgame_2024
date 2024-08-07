extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer

const MAX_WIDTH = 256

signal _finish_displaying()

# TODO: set visible to true when displaying text >> set visible to false after timer end

func _ready():
	# set visible to false on default
	visible = false

func _display_text(display_text):
	# set visible to true when displaying text
	if visible:
		# reset label
		label.text = ""
	
		custom_minimum_size.x = 0
		await resized
		
		visible = false
	
	visible = true
	label.text = display_text
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		# apply text-wrap
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # wait for x resize
		await resized # wait for y resize
		custom_minimum_size.y = size.y
	
	timer.start(2)

func _on_letter_display_timer_timeout():
	# set visible to false after timer end
	label.text = ""
	
	custom_minimum_size.x = 0
	await resized
	
	visible = false
