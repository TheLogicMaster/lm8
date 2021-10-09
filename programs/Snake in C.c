// Snake C program for LM-8 architecture

extern void write(unsigned int port, unsigned int value);
extern unsigned int read(unsigned int port);
extern void draw_sprite(unsigned int x, unsigned int y, char* sprite);
extern void draw_pixel(unsigned int x, unsigned int y, unsigned int color);
extern void print(char* string);

static const char snake_head[64] = {
    0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x00, 0x38, 0x38, 0x00, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0xE0, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0xE0, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0xE0, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0xE0, 0x38, 0xE0, 0x38, 0x0C,
    0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C,
};

static const char snake_body[64] = {
    0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x0C,
    0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C,
};

static const char apple[64] = {
    0x00, 0x14, 0x14, 0x00, 0x00, 0x14, 0x14, 0x00,
    0x00, 0xE0, 0x14, 0x14, 0x14, 0xE0, 0xE0, 0x00,
    0xE0, 0xE0, 0xE0, 0xE0, 0x14, 0xE0, 0xE0, 0xE0,
    0xE0, 0xFF, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0,
    0xFF, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0,
    0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0,
    0x00, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0x00,
    0x00, 0x00, 0xE0, 0xE0, 0xE0, 0xE0, 0x00, 0x00,
};

static const unsigned char snake_title[100] = {
    0, 6, 1, 7, 2, 7, 3, 6, 3, 5, 2, 4, 1, 4, 0, 3, 0, 2, 1, 1, 2, 1, // S
    5, 7, 5, 6, 5, 5, 5, 4, 5, 3, 6, 4, 7, 5, 7, 6, 7, 7, // N
    9, 7, 9, 6, 9, 5, 9, 4, 10, 5, 10, 3, 11, 7, 11, 6, 11, 5, 11, 4, // A
    13, 2, 13, 3, 13, 4, 13, 5, 13, 6, 13, 7, 14, 6, 15, 7, 15, 5, 15, 4, // K
    17, 3, 17, 4, 17, 5, 17, 6, 17, 7, 18, 3, 19, 3, 18, 5, 18, 7, 19, 7, // E
};

int poll_controls() {
    if (read(38)) // D
        return 1;
    if (read(36)) // S
        return 2;
    if (read(37)) // A
        return 3;
    if (read(35)) // W
        return 4;
    return 0;

}

int check_body_collision(int x, int y, char* segments, int size) {
    int current_x = x;
    int current_y = y;

    for (int i = 0; i < size; i++) {
        if (segments[i] == 0)
            current_x += 1;
        else if (segments[i] == 1)
            current_y += 1;
        else if (segments[i] == 2)
            current_x -= 1;
        else
            current_y -= 1;
        if (x == current_x && y == current_y)
            return 1;
    }

    return 0;
}

void generate_apple(int *apple_x, int *apple_y, int snake_x, int snake_y, char *segments, int size) {
    int x, y;

    while (1) {
        x = read(93) % 20;
        y = read(93) % 16;

        if (snake_x == x && snake_y == y)
            continue;

        if (!check_body_collision(x, y, segments, size))
            break;
    }

    *apple_x = x;
    *apple_y = y;
}

void snake_game() {
    char segments[320] = {2, 2}; // Put first or VBCC breaks
    int score = 2;
    int x = 4;
    int y = 4;
    int apple_x;
    int apple_y;
    int input = 0;

    generate_apple(&apple_x, &apple_y, x, y, segments, score);

    while(1) {
        // Draw game
        write(34, 0x25); // Clear screen with BG color
        draw_sprite(x * 8, y * 8, snake_head);
        draw_sprite(apple_x * 8, apple_y * 8, apple);
        int current_x = x;
        int current_y = y;
        for (int i = 0; i < score; i++) {
            if (segments[i] == 0)
                current_x += 1;
            else if (segments[i] == 1)
                current_y += 1;
            else if (segments[i] == 2)
                current_x -= 1;
            else
                current_y -= 1;

            draw_sprite(current_x * 8, current_y * 8, snake_body);
        }
        write(94, 0); // Swap buffers

        // Movement delay
        write(112, 0); // Clear timer
        while(!read(112)) {
            int polled = poll_controls();
            if (polled && (!input || polled - 1 != (input - 1 + 2) % 4))
                input = polled;
        }

        // Move snake
        int direction = input ? input - 1 : (segments[0] + 2) % 4;
        if (direction == 0)
            x += 1;
        else if (direction == 1)
            y += 1;
        else if (direction == 2)
            x -= 1;
        else
            y -= 1;
        if (check_body_collision(x, y, segments, score) || x < 0 || x >= 20 || y < 0 || y >= 16)
            return;
        int needs_apple = 0;
        if (apple_x == x && apple_y == y) {
            score++;
            needs_apple = 1;
        }
        int shift = (direction + 2) % 4;
        for (int i = 0; i < score; i++) {
            int temp = segments[i];
            segments[i] = shift;
            shift = temp;
        }
        if (needs_apple)
            generate_apple(&apple_x, &apple_y, x, y, segments, score);
    }
}

int main() {
    // Setup timer
    write(108, 5); // Deciseconds
    write(110, 2); // 2 deciseconds

    while (1) {
        // Title screem
        write(34, 0x25); // Clear screen with BG color
        for (int i = 0; i < 100 - 1; i += 2)
            draw_sprite(snake_title[i] * 8, snake_title[i + 1] * 8, snake_body);
        draw_sprite(24, 16, snake_head);
        draw_sprite(120, 24, apple);
        write(94, 0); // Swap buffers

        // Wait for input to start game
        while(poll_controls());
        while(!poll_controls());

        snake_game();
    }
}
