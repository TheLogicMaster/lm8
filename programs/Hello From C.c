// Hello World C program for LM-8 architecture

extern void write(unsigned int port, unsigned int value);
extern unsigned int read(unsigned int port);
extern void draw_sprite(unsigned int x, unsigned int y, char* sprite);
extern void draw_pixel(unsigned int x, unsigned int y, unsigned int color);
extern void print(char* string);

#define PRINTF_BUFFER 64

void printf(char* format, ...) {
    char buffer[PRINTF_BUFFER];
    char *buffer_ptr = buffer;

    char *format_ptr = format;

    int *arg_ptr = (int*)&format - 1;

    int count;
    char digits[5];

    char prev = 0;
    while (*format_ptr) {
        if (prev == '%') {
            if (*format_ptr == '%') {
                *(buffer_ptr++) = '%';
            } else if (*format_ptr == 'd' || *format_ptr == 'i') {
                int value = *(arg_ptr--);
                if (value < 0) {
                    *(buffer_ptr++) = '-';
                    value = -value;
                } else if (value == 0)
                    *(buffer_ptr++) = '0';
                count = 0;
                while (value > 0) {
                    digits[count++] = '0' + value % 10;
                    value /= 10;
                }
                for (int i = 0; i < count; i++)
                    *(buffer_ptr++) = digits[count - 1 - i];
            } else if (*format_ptr == 'u') {
                unsigned int value = *(unsigned int*)(arg_ptr--);
                if (value == 0)
                    *(buffer_ptr++) = '0';
                count = 0;
                while (value > 0) {
                    digits[count++] = '0' + value % 10;
                    value /= 10;
                }
                for (int i = 0; i < count; i++)
                    *(buffer_ptr++) = digits[count - 1 - i];
            } else if (*format_ptr == 'x') {
                unsigned int value = *(unsigned int*)(arg_ptr--);
                if (value == 0)
                    *(buffer_ptr++) = '0';
                count = 0;
                while (value > 0) {
                    unsigned int adjusted = value % 16;
                    digits[count++] = (adjusted < 10 ? '0' : 'A' - 10) + adjusted;
                    value /= 16;
                }
                for (int i = 0; i < count; i++)
                    *(buffer_ptr++) = digits[count - 1 - i];
            } else if (*format_ptr == 'c') {
                *(buffer_ptr++) = *(arg_ptr--);
            } else if (*format_ptr == 's') {
                char *string = *(char**)(arg_ptr--);
                while(*string)
                    *(buffer_ptr++) = *(string++);
            }
        } else if (*format_ptr != '%') {
            *(buffer_ptr++) = *format_ptr;
        }
        prev = *format_ptr;
        format_ptr++;
    }
    *buffer_ptr = 0;

    print(buffer);
}

int main() {
     char *string = "Hello World!";
     printf("%s\nprintf format examples: %d %d %x %u %u %c\n", string, -1, 200, 0xABCD, 100, 0xFF, '!');
}
