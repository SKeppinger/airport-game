extends TileMap

## CONSTANTS

# The piece atlases
const i_piece_atlas = 2
const j_piece_atlas = 3
const l_piece_atlas = 4
const o_piece_atlas = 5
const s_piece_atlas = 6
const z_piece_atlas = 7

const starting_position = Vector2(5, 0) # The starting position for new pieces
const pieces_to_place = 30 # The number of pieces that must be placed to win
const moving_interval = 8 # The number of frames to wait between moving left and right
const falling_interval = 11 # The number of frames before the current piece falls one tile
const scrolling_interval = 540 # The number of frames before the placed pieces move down one tile

## VARIABLES

var current_piece = [] # The current piece and its position/rotation in the form [x, y, piece, rot]
var placed_pieces = [] # All the placed pieces and their positions/rotations in the form [x, y, piece, rot, layer]
var fall_frame = 0 # The number of frames that have gone by since the current piece fell
var scroll_frame = 0 # The number of frames that have gone by since the place pieces scrolled
var move_frame = moving_interval # The number of frames that have gone by since the current piece last moved left/right
var lose = false # Flag for whether the player has lost the game
var win = false # Flag for whether the player has won the game

## FUNCTIONS

## Ready
# Set up
func _ready():
	# Select a random piece
	current_piece = [starting_position.x, starting_position.y, randi_range(2, 7), 0]

## Process
# Main game functions
func _process(_delta):
	if not lose and not win:
		# Player input
		if move_frame >= moving_interval:
			if Input.is_action_pressed("move_left"):
				var can_move = true
				var current_pos = Vector2(current_piece[0], current_piece[1])
				for piece in placed_pieces:
					var pos = Vector2(piece[0], piece[1])
					for tile in get_occupied_space(piece[2], piece[3]):
						for current_tile in get_occupied_space(current_piece[2], current_piece[3]):
							if pos + tile == current_pos + current_tile - Vector2(1, 0):
								can_move = false
				if can_move:
					if current_piece[0] > 1:
						current_piece[0] -= 1
						move_frame = 0
			if Input.is_action_pressed("move_right"):
				var can_move = true
				var current_pos = Vector2(current_piece[0], current_piece[1])
				for tile in get_occupied_space(current_piece[2], current_piece[3]):
					if (Vector2(current_piece[0], current_piece[1]) + tile).x == 10:
						can_move = false
				for piece in placed_pieces:
					var pos = Vector2(piece[0], piece[1])
					for tile in get_occupied_space(piece[2], piece[3]):
						for current_tile in get_occupied_space(current_piece[2], current_piece[3]):
							if pos + tile == current_pos + current_tile + Vector2(1, 0):
								can_move = false
				if can_move:
					current_piece[0] += 1
					move_frame = 0
		if Input.is_action_just_pressed("button_a"):
			rotate_current_piece()
		# Move the current piece downward if it is time
		if fall_frame == falling_interval:
			fall_frame = 0
			# Check if the piece is placed
			if placed():
				# Check for loss condition
				for tile in get_occupied_space(current_piece[0], current_piece[1]):
					if (Vector2(current_piece[0], current_piece[1]) + tile).y <= 0:
						print("lose")
						lose = true
				var layer = current_piece[0]
				var intended_layer = check_piece_below()
				if intended_layer:
					layer = intended_layer
				current_piece.append(layer)
				placed_pieces.append(current_piece)
				# Check for win condition
				if len(placed_pieces) == pieces_to_place:
					win = true
				else:
					# Select a random piece
					current_piece = [starting_position.x, starting_position.y, randi_range(2, 7), 0]
					# If overlapping, lose
					if overlapping():
						lose = true
			# Otherwise, move it
			else:
				current_piece[1] += 1
		# Move all placed pieces downward if it is time
		if scroll_frame == scrolling_interval:
			scroll_frame = 0
			for piece in placed_pieces:
				piece[1] += 1
		# Update the frames
		fall_frame += 1
		move_frame += 1
		if len(placed_pieces) > 0:
			scroll_frame += 1
		# Clear layers and draw all pieces
		for layer in range(1, 11):
			for x in range(0, 12): # Need to make sure to clear sides
				for y in range(-2, 15): # Need to make sure to clear top and bottom
					set_cell(layer, Vector2(x, y), -1)
		for piece in placed_pieces:
			draw_piece(piece[2], Vector2(piece[0], piece[1]), piece[3], piece[4])
		draw_piece(current_piece[2], Vector2(current_piece[0], current_piece[1]), current_piece[3])

## Draw Piece
# atlas: the piece to draw (use one of the defined constants)
# pos: the position of the leftmost topmost square of the tile, given as a vector (x:1-10, y:0-13)
# rot: the rotation, given as a number 0-3 (0: 0 deg, 1: 90 deg, 2: 180 deg, 3: 270 deg)
# lyr: if given, this overrides the automatic layer choice (for already placed pieces)
func draw_piece(atlas, pos, rot, lyr=-1):
	var layer = pos.x
	if lyr:
		layer = lyr
	else:
		var intended_layer = check_piece_below()
		if intended_layer:
			layer = intended_layer
	if rot == 0:
		set_cell(layer, pos, atlas, Vector2(rot, 0))
	else:
		set_cell(layer, pos, atlas, Vector2(rot, 0), 1)

## Placed
# Returns true if the current piece is resting on another piece or the bottom, and false otherwise
func placed():
	var pos = Vector2(current_piece[0], current_piece[1])
	# If the piece is on the bottom
	for tile in get_occupied_space(current_piece[2], current_piece[3]):
		if (pos + tile).y == 13:
			return true
		for piece in placed_pieces:
			var other_pos = Vector2(piece[0], piece[1])
			for other_tile in get_occupied_space(piece[2], piece[3]):
				if (pos + tile).x == (other_pos + other_tile).x and (pos + tile).y == (other_pos + other_tile).y - 1:
					return true

## Overlapping
# Returns true if the current piece is overlapping another piece or the bottom (after rotating)
func overlapping():
	var pos = Vector2(current_piece[0], current_piece[1])
	for tile in get_occupied_space(current_piece[2], current_piece[3]):
		if (pos + tile).y == 14:
			return true
		for piece in placed_pieces:
			var other_pos = Vector2(piece[0], piece[1])
			for other_tile in get_occupied_space(piece[2], piece[3]):
				if pos + tile == other_pos + other_tile:
					return true
	return false

## Check Piece Below
# Checks for a piece below the current piece
# Returns -1 if no piece below
# Otherwise, returns the layer of the highest piece below the current piece
func check_piece_below():
	var pos = Vector2(current_piece[0], current_piece[1])
	# Get the max x value of the current piece's occupied space to determine its length
	var max_x = 0
	for tile in get_occupied_space(current_piece[2], current_piece[3]):
		if tile.x > max_x:
			max_x = tile.x
	var length = 1 + max_x
	var highest_occupied_y = 14 # 14 is below the screen
	var layer = pos.x # The default layer is the piece's x position
	# i know this nested loop is incomprehensible but trust me im a genius
	for i in range(length):
		for piece in placed_pieces:
			var piece_pos = Vector2(piece[0], piece[1])
			for tile in get_occupied_space(piece[2], piece[3]):
				if (piece_pos + tile).x == pos.x + i and (piece_pos + tile).y < highest_occupied_y:
					highest_occupied_y = (piece_pos + tile).y
					layer = piece[4]
	if highest_occupied_y == 14:
		return -1
	else:
		return layer
	

## Rotate Current Piece
# Rotates the current piece
func rotate_current_piece():
	current_piece[3] += 1
	if current_piece[3] == 4:
		current_piece[3] = 0
	# Special cases
	if current_piece[2] == j_piece_atlas:
		match current_piece[3]:
			0:
				current_piece[1] += 2
			1:
				current_piece[1] -= 2
	if current_piece[2] == l_piece_atlas:
		match current_piece[3]:
			0:
				current_piece[1] -= 1
			3:
				current_piece[1] += 1
	if current_piece[2] == s_piece_atlas:
		match current_piece[3]:
			0:
				current_piece[1] -= 1
			1:
				current_piece[1] += 1
			2:
				current_piece[1] -= 1
			3:
				current_piece[1] += 1
	if current_piece[2] == z_piece_atlas:
		match current_piece[3]:
			0:
				current_piece[1] += 1
			1:
				current_piece[1] -= 1
			2:
				current_piece[1] += 1
			3:
				current_piece[1] -= 1
	# If too far to the right after rotating, move left
	for tile in get_occupied_space(current_piece[2], current_piece[3]):
		if (Vector2(current_piece[0], current_piece[1]) + tile).x > 10:
			current_piece[0] -= 1
	# If overlapping a piece or the bottom after rotating, move up
	if overlapping():
		current_piece[1] -= 1
	# If placed after rotating, place it
	if placed():
		fall_frame = 0
		var layer = current_piece[0]
		var intended_layer = check_piece_below()
		if intended_layer:
			layer = intended_layer
		current_piece.append(layer)
		placed_pieces.append(current_piece)
		# Select a random piece
		current_piece = [starting_position.x, starting_position.y, randi_range(2, 7), 0]

## Get Occupied Space
# Returns the coordinates of space occupied by the given piece/rotation, relative to its position
func get_occupied_space(piece, rot):
	var space = []
	match piece:
		i_piece_atlas:
			match rot:
				0:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)]
				1:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)]
				2:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)]
				3:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)]
		j_piece_atlas:
			match rot:
				0:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(1, -2)]
				1:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)]
				2:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, 2)]
				3:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(2, 1)]
		l_piece_atlas:
			match rot:
				0:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(1, 2)]
				1:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(2, 0)]
				2:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)]
				3:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(2, -1)]
		o_piece_atlas:
			space = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
		s_piece_atlas:
			match rot:
				0:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 2)]
				1:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(2, -1)]
				2:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 2)]
				3:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(2, -1)]
		z_piece_atlas:
			match rot:
				0:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, -1)]
				1:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)]
				2:
					space = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, -1)]
				3:
					space = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)]
	return space
