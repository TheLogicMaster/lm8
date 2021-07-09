; A snake game using the controller peripheral

    jmp title_screen

; Program loop
loop:
    jsr delay

    jsr move_snake

    jsr check_new_position
    jr no_collision,z
    jmp title_screen
no_collision:

    jsr check_apple

    ldr [new_y],a
    str [y],a
    ldr [new_x],a
    str [x],a

    jsr shift_snake_body

    jsr draw_game

    jmp loop


    ; Display the title screen and wait for user input
title_screen:
    ldr $25,a
    out {clear_screen},a
    lda title_snake
    ldr #50,b
title_screen_draw:
    push b
    ldr [HL],a
    ina
    ldr #8,b
    jsr multiply
    out {graphics_x},a
    ldr [HL],a
    ina
    jsr multiply
    out {graphics_y},a
    ldr #13,a
    out {draw_sprite},a
    pop b
    dec b
    jr title_screen_draw,nz
    ldr #24,a
    out {graphics_x},a
    ldr #16,a
    out {graphics_y},a
    ldr #12,a
    out {draw_sprite},a
    ldr #120,a
    out {graphics_x},a
    ldr #24,a
    out {graphics_y},a
    ldr #14,a
    out {draw_sprite},a
    out {swap_display},a
title_screen_wait_release:
    jsr get_input
    jr title_screen_wait_release,nz
title_screen_wait_press:
    jsr get_input
    jr title_screen_wait_press,z
    ldr #32,a
    str [x],a
    str [y],a
    ldr #2,a
    str [score],a
    lda snake
    str [HL],a
    ina
    str [HL],a
    jsr generate_apple
    jsr draw_game
    jmp loop


    ; Limit game speed with a counter and dummy operations
delay:
    ldr $0,a
    ldr $3,b
    delay_next:
    push a
    jsr get_input
    jr delay_no_input,z
    str [input],a
delay_no_input:
    pop a
    dec a
    jr delay_next,nz
    dec b
    jr delay_next,nz
    ret


    ; Renders the game to the screen
draw_game:
    push a
    ldr $25,a
    out {clear_screen},a
    jsr draw_apple
    jsr draw_snake_head
    jsr draw_snake_body
    out {swap_display},a
    pop a
    ret


    ; Draws the apple
    ; Modifies no registers or variables
draw_apple:
    push a
    ldr [apple_x],a
    out {graphics_x},a
    ldr [apple_y],a
    out {graphics_y},a
    ldr #14,a
    out {draw_sprite},a
    pop a
    ret


    ; Draws the snake head
    ; Modifies no registers or variables
draw_snake_head:
    push a
    ldr [x],a
    out {graphics_x},a
    ldr [y],a
    out {graphics_y},a
    ldr #12,a
    out {draw_sprite},a
    pop a
    ret


    ; Gets the next snake segment position from [HL]
    ; [body_x] and [body_y] are appended with the direction vector
get_snake_segment:
    push a
    ldr [HL],a
    push h
    push l
    ldr [body_x],h
    ldr [body_y],l
    cmp #0
    jr get_snake_segment_not_right,nz
    push h
    pop a
    add #8
    push a
    pop h
    jr get_snake_segment_add
get_snake_segment_not_right:
    cmp #1
    jr get_snake_segment_not_down,nz
    push l
    pop a
    add #8
    push a
    pop l
    jr get_snake_segment_add
get_snake_segment_not_down:
    cmp #2
    jr get_snake_segment_not_left,nz
    push h
    pop a
    sub #8
    push a
    pop h
    jr get_snake_segment_add
get_snake_segment_not_left:
    push l
    pop a
    sub #8
    push a
    pop l
get_snake_segment_add:
    str [body_x],h
    str [body_y],l
    pop l
    pop h
    pop a
    ret


    ; Draws the snake body to the screen
    ; Modifies no registers
    ; Modifies [body_x] and [body_y]
draw_snake_body:
    push a
    push b
    push h
    push l
    ldr [x],a
    str [body_x],a
    ldr [y],a
    str [body_y],a
    lda snake
    ldr [score],b
draw_snake_body_next:
    jr draw_snake_body_done,z
    jsr get_snake_segment
    ldr [body_x],a
    out {graphics_x},a
    ldr [body_y],a
    out {graphics_y},a
    ldr #13,a
    out {draw_sprite},a
    ina
    dec b
    jr draw_snake_body_next
draw_snake_body_done:
    pop l
    pop h
    pop b
    pop a
    ret


    ; Shifts a new body direction into the front of the snake
    ; The value of [body_shift] is shifted in
    ; No registers are modified
    ; The last snake direction is left in [body_shift]
shift_snake_body:
    push a
    push b
    push h
    push l
    lda snake
    ldr [score],b
shift_snake_body_shift:
    jr shift_snake_body_done,z
    ldr [HL],a
    push a
    ldr [body_shift],a
    str [HL],a
    ina
    pop a
    str [body_shift],a
    dec b
    jr shift_snake_body_shift
shift_snake_body_done:
    pop l
    pop h
    pop b
    pop a
    ret


    ; Check if the position ([check_x], [check_y]) is part of the current snake
    ; Returns 1 in A if a collision occured
    ; Zero flag is set if a collision didn't occur
    ; The last snake direction is left in [body_shift]
check_snake_collision:
    push a
    push b
    push h
    push l
    ldr [x],a
    str [body_x],a
    ldr [y],a
    str [body_y],a
    lda snake
    ldr [score],b
check_snake_collision_next:
    push b
    ldr [check_x],a
    ldr [body_x],b
    cmp b
    jr check_snake_collision_not,nz
    ldr [check_y],a
    ldr [body_y],b
    cmp b
    jr check_snake_collision_not,nz
    pop b
    pop l
    pop h
    pop b
    pop a
    ldr #1,a
    ret
check_snake_collision_not:
    pop b
    jsr get_snake_segment
    ina
    dec b
    jr check_snake_collision_next,nc
    pop l
    pop h
    pop b
    pop a
    ldr #0,a
    ret


    ; Generates the apple at a random non-overlapping position
    ; No registers are modified.
generate_apple:
    push a
    push b
    push h
generate_apple_next:
    ldr #8,b
    in {rand},a ; Todo: Improve X random with modulus?
    and $F
    push a
    pop h
    in {rand},a
    and $3
    add h
    push a
    pop h
    in {rand},a
    and $1
    add h
    jsr multiply
    push a
    pop h
    in {rand},a
    and $F
    jsr multiply
    ; Ensure apple isn't in same position
    ldr [new_y],b
    cmp b
    jr generate_apple_not_head,nz
    push a
    ldr [new_x],a
    cmp h
    pop a
    jr generate_apple_not_head,nz
    jr generate_apple_next
generate_apple_not_head:
    ; Ensure apple isn't in snake
    str [check_x],h
    str [check_y],a
    push a
    jsr check_snake_collision
    pop a
    jr generate_apple_next,nz
    str [apple_x],h
    str [apple_y],a
    pop h
    pop b
    pop a
    ret


    ; Check for a collision between the new head position and the walls/body
    ; Returns a boolean in A for whether a collision occured or not
    ; Z Flag is set if no collision occured
check_new_position:
    ldr [new_x],a
    cmp #160
    jr check_new_position_collided,nc
    ldr [new_y],a
    cmp #128
    jr check_new_position_collided,nc
    ldr [new_x],a
    str [check_x],a
    ldr [new_y],a
    str [check_y],a
    jsr check_snake_collision
    jr check_new_position_collided,nz
    ldr #0,a
    ret
check_new_position_collided:
    ldr #1,a
    ret


    ; Check for an apple at new head position
    ; Increments score if apple is present and respawns apple
    ; Doesn't modify any registers
check_apple:
    push a
    push b
    ldr [new_x],a
    ldr [apple_x],b
    cmp b
    jr check_apple_done,nz
    ldr [new_y],a
    ldr [apple_y],b
    cmp b
    jr check_apple_done,nz
    ldr [score],a
    inc a
    str [score],a
    jsr generate_apple
check_apple_done:
    pop b
    pop a
    ret


    ; Sets the new snake position based on Controller input
move_snake:
    push a
    push b
    ldr [input],a
    jr move_snake_no_input,z
    dec a
    ldr [snake],b
    cmp b
    jr move_snake_dir,nz
move_snake_no_input:
    ldr [snake],a
    jsr get_opposite_direction
move_snake_dir:
    push a
    cmp #0
    jr move_snake_not_right,nz
    ldr [x],a
    add #8
    str [new_x],a
    ldr [y],a
    str [new_y],a
    jr move_snake_move
move_snake_not_right:
    cmp #1
    jr move_snake_not_down,nz
    ldr [x],a
    str [new_x],a
    ldr [y],a
    add #8
    str [new_y],a
    jr move_snake_move
move_snake_not_down:
    cmp #2
    jr move_snake_not_left,nz
    ldr [x],a
    sub #8
    str [new_x],a
    ldr [y],a
    str [new_y],a
    jr move_snake_move
move_snake_not_left:
    ldr [x],a
    str [new_x],a
    ldr [y],a
    sub #8
    str [new_y],a
move_snake_move:
    pop a
    jsr get_opposite_direction
    str [body_shift],a
    pop b
    pop a
    ret


    ; Retrieves an integer direction from the Controller input
    ; Returns the CW ordinal in A with 1 being East
    ; Returns zero if no inputs are detected
    ; Only modifies register A
get_input: ; Todo: Make iterative if not difficult
    in {controller_right},a
    jr get_input_not_right,z
    ldr #1,a
    ret
get_input_not_right:
    in {controller_down},a
    jr get_input_not_down,z
    ldr #2,a
    ret
get_input_not_down:
    in {controller_left},a
    jr get_input_not_left,z
    ldr #3,a
    ret
get_input_not_left:
    in {controller_up},a
    jr get_input_not_up,z
    ldr #4,a
get_input_not_up:
    ret


    ; Performs A mod B and stores the result in A
    ; Only register A is modified
modulus:
    cmp b
    jr modulus_done,c
    sub b
    jr modulus
modulus_done:
    ret


    ; Calculates the opposite direction of A and returns it in A
    ; Only register A is modified
get_opposite_direction:
    push b
    ldr #4,b
    add #2
    jsr modulus
    pop b
    ret


    ; Multiplies A by B and stores the result in A
    ; Only register A is modified
multiply:
    push h
    push b
    push a
    pop h
    ldr #0,a
    cmp b
multiply_next:
    jr multiply_done,z
    add h
    dec b
    jr multiply_next
multiply_done:
    pop b
    pop h
    ret


    org $300 ; Start sprites at ID 12
    bin "sprites/snake_head.bin"
    bin "sprites/snake_body.bin"
    bin "sprites/apple.bin"


    org $400
title_snake:
    ; S
    db #0,#6
    db #1,#7
    db #2,#7
    db #3,#6
    db #3,#5
    db #2,#4
    db #1,#4
    db #0,#3
    db #0,#2
    db #1,#1
    db #2,#1
    ; N
    db #5,#7
    db #5,#6
    db #5,#5
    db #5,#4
    db #5,#3
    db #6,#4
    db #7,#5
    db #7,#6
    db #7,#7
    ; A
    db #9,#7
    db #9,#6
    db #9,#5
    db #9,#4
    db #10,#5
    db #10,#3
    db #11,#7
    db #11,#6
    db #11,#5
    db #11,#4
    ; K
    db #13,#2
    db #13,#3
    db #13,#4
    db #13,#5
    db #13,#6
    db #13,#7
    db #14,#6
    db #15,#7
    db #15,#5
    db #15,#4
    ; E
    db #17,#3
    db #17,#4
    db #17,#5
    db #17,#6
    db #17,#7
    db #18,#3
    db #19,#3
    db #18,#5
    db #18,#7
    db #19,#7

    data ; Enter data section
score:      var         ; Number of apples collected
input:      var         ; The last input from the user or zero
apple_x:    var         ; The apple's X coordinate
apple_y:    var         ; The apple's Y coordinate
x:          var         ; X coordinate of head
y:          var         ; Y coordinate of head
body_x:     var         ; X coordinate of current body segment
body_y:     var         ; Y coordinate of current body segment
body_shift: var         ; A direction to be shifted into the body
check_x:    var         ; The X value used for snake collision checking
check_y:    var         ; The Y value used for snake collision checking
new_x:      var         ; The new head X coordinate for collision checking
new_y:      var         ; The new head Y coordinate for collision checking
snake:      var[320]    ; Array of snake body directions starting from head
