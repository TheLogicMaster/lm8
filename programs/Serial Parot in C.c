// Serial Parrot C program for LM-8 architecture

extern void write(unsigned int port, unsigned int value);
extern unsigned int read(unsigned int port);
extern void draw_sprite(unsigned int x, unsigned int y, char* sprite);
extern void draw_pixel(unsigned int x, unsigned int y, unsigned int color);
extern void print(char* string);

int main() {
    // Echo serial input
    while (1) {
        if (read(1)) {
            write(0, read(0)); // Echo character
            write(1, 0); // Pop char from input buffer
        }
    }
}
