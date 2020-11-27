extends Node2D

const SnekPart = preload("res://SnakePart.tscn")
const Food = preload("res://Food.tscn")
const Wall = preload("res://Wall.tscn")

export (int) var SNEKPART_SIZE = 10
export (int) var SNEK_GROW = 2
export (int) var SNEK_LEN = 5
export (Vector2) var SNEK_POS = Vector2 (10, 15)
export (Vector2) var WINDOW = Vector2 (40, 30)

const NORTH = 0
const EAST = 1
const SOUTH = 2
const WEST = 3

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

onready var facing: int = EAST
onready var grow: int = 0
onready var dirchange: int = 0
onready var food:Node2D = null
onready var dead: bool = false

export (Color) var headColor
export (Color) var bodyColor
export (Color) var foodColor
export (Color) var wallColor

var Snek = []

func _physics_process(_delta):
	if Input.is_action_just_released("ui_left"):
		dirchange = 3
	elif Input.is_action_just_released("ui_right"):
		dirchange = 1
	elif Input.is_action_just_released("ui_EAST"):
		facing = EAST
	elif Input.is_action_just_released("ui_WEST"):
		facing = WEST
	elif Input.is_action_just_released("ui_NORTH"):
		facing = NORTH
	elif Input.is_action_just_released("ui_SOUTH"):
		facing = SOUTH

func _ready():
	randomize()
	draw_walls()
	start_game()
	
func start_game():
	for x in range(SNEK_POS.x, SNEK_POS.x + SNEK_LEN):
		var snekPart = SnekPart.instance()
		place_part(snekPart, Vector2(x * SNEKPART_SIZE, SNEK_POS.y * SNEKPART_SIZE), bodyColor)
		Snek.append(snekPart)
	Snek[-1].connect("snake_dead", self, "on_snake_dead")	
	place_food()
	$Timer.start()
	
func draw_walls():
	for x in range(0, WINDOW.x):
		place_part(Wall.instance(), Vector2(x * SNEKPART_SIZE, 0), wallColor)
		place_part(Wall.instance(), Vector2(x * SNEKPART_SIZE, (WINDOW.y - 1) * SNEKPART_SIZE), wallColor)
	for y in range(0, WINDOW.y):
		place_part(Wall.instance(), Vector2(0 , y * SNEKPART_SIZE), wallColor)
		place_part(Wall.instance(), Vector2((WINDOW.x - 1) * SNEKPART_SIZE, y * SNEKPART_SIZE), wallColor)

func place_part(part_instance: Node2D, pos: Vector2, color: Color):
	part_instance.position = Vector2(pos)
	add_child(part_instance)
	part_instance.setColor(color)
	
func in_snek(pos: Vector2):
	for snekPart in Snek:
		if int(pos.x) == snekPart.position.x and int(pos.y == snekPart.position.y):
			return true
	return false
	
func update_snake():
	if(grow > 0):
		grow -= 1
	else:
		Snek.pop_front().queue_free()

	#place new head
	var head_pos = Snek[-1].position
	Snek[-1].setColor(bodyColor)
	Snek[-1].disconnect("snake_dead", self, "on_snake_dead")

	facing = (facing + dirchange) % 4
	dirchange = 0
	var posx = head_pos.x + (directions[facing].x * SNEKPART_SIZE)
	var posy = head_pos.y + (directions[facing].y * SNEKPART_SIZE)

	var newHead = SnekPart.instance()
	place_part(newHead, Vector2(posx, posy), headColor)
	Snek.append(newHead)
	newHead.connect("snake_dead", self, "on_snake_dead")	

func _on_Timer_timeout():
	$Timer.stop()
	if not dead:
		update_snake()
		$Timer.start()
	else:
		restart_game()

func place_food():
	food = Food.instance()
# warning-ignore:return_value_discarded
	food.connect("food_eaten", self, "on_food_eaten")	
	move_food()
	add_child(food)
	food.setColor(foodColor)
	
func move_food():
	var pos:Vector2 = get_random_pos()
	while in_snek(pos):
		pos = get_random_pos()
	food.position = pos

func get_random_pos():
	return Vector2(SNEKPART_SIZE * (randi() % int(WINDOW.x)), SNEKPART_SIZE * (randi() % int(WINDOW.y)))
		
func on_food_eaten():
	$Timer.stop()
	move_food()
	grow += SNEK_GROW
	$Timer.start()
	
func on_snake_dead():
	dead=true

func restart_game():
	food.queue_free()
	for snekPart in Snek:
		snekPart.queue_free()
	Snek.resize(0)
	dead = false
	facing = EAST
	grow = 0
	dirchange = 0
	food = null
	start_game()
