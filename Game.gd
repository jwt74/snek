extends Node2D

const SnakePart = preload("res://SnakePart.tscn")
const Food = preload("res://Food.tscn")
const Wall = preload("res://Wall.tscn")

export (int) var SNAKEPART_SIZE = 10
export (int) var SNAKE_GROW = 2
export (int) var SNAKE_LEN = 5
export (Vector2) var SNAKE_POS = Vector2 (10, 15)
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

var Snake = []

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
	for x in range(SNAKE_POS.x, SNAKE_POS.x + SNAKE_LEN):
		var snakePart = SnakePart.instance()
		place_part(snakePart, Vector2(x * SNAKEPART_SIZE, SNAKE_POS.y * SNAKEPART_SIZE), bodyColor)
		Snake.append(snakePart)
	Snake[-1].connect("snake_dead", self, "on_snake_dead")	
	place_food()
	$Timer.start()
	
func draw_walls():
	for x in range(0, WINDOW.x):
		place_part(Wall.instance(), Vector2(x * SNAKEPART_SIZE, 0), wallColor)
		place_part(Wall.instance(), Vector2(x * SNAKEPART_SIZE, (WINDOW.y - 1) * SNAKEPART_SIZE), wallColor)
	for y in range(0, WINDOW.y):
		place_part(Wall.instance(), Vector2(0 , y * SNAKEPART_SIZE), wallColor)
		place_part(Wall.instance(), Vector2((WINDOW.x - 1) * SNAKEPART_SIZE, y * SNAKEPART_SIZE), wallColor)

func place_part(part_instance: Node2D, pos: Vector2, color: Color):
	part_instance.position = Vector2(pos)
	add_child(part_instance)
	part_instance.setColor(color)
	
func update_snake():
	if(grow > 0):
		grow -= 1
	else:
		Snake.pop_front().queue_free()

	#place new head
	var head_pos = Snake[-1].position
	Snake[-1].setColor(bodyColor)
	Snake[-1].disconnect("snake_dead", self, "on_snake_dead")

	facing = (facing + dirchange) % 4
	dirchange = 0
	var posx = head_pos.x + (directions[facing].x * SNAKEPART_SIZE)
	var posy = head_pos.y + (directions[facing].y * SNAKEPART_SIZE)

	var newHead = SnakePart.instance()
	place_part(newHead, Vector2(posx, posy), headColor)
	Snake.append(newHead)
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
	food.position = Vector2(SNAKEPART_SIZE * (randi() % int(WINDOW.x)), SNAKEPART_SIZE * (randi() % int(WINDOW.y)))
	
func on_food_eaten():
	$Timer.stop()
	move_food()
	grow += SNAKE_GROW
	$Timer.start()
	
func on_snake_dead():
	dead=true

func restart_game():
	food.queue_free()
	for snakePart in Snake:
		snakePart.queue_free()
	Snake.resize(0)
	dead = false
	facing = EAST
	grow = 0
	dirchange = 0
	food = null
	start_game()
