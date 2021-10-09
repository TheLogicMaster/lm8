# LM-8 Hardware Interfaces
Hardware interfaces are implemented as a combination of Logisim components, VHDL code, and 
Intel IP components. 

## Timers
Two hardware timers are present in the computer. They are both configurable in terms of the
timer unit being counted and a multiplier to apply to that time unit. A 37 bit counter 
register is used to count up for up to 2550 seconds at 50 MHz. The timers are independent of
the Logisim divided clock speed and directly use one of the dev board timers. The current 
count isn't readable and only the state of being triggered or not is visible to the program.

## Graphics
The VGA driver is implemented entirely in a VHDL file in Logisim. The driver has a single
display buffer that stores RGB332 color data for all pixels of the 160x128 display. The
buffer is upscaled 3x to fit most of the 640x480 resolution VGA output. Writing to the
`draw_sprite` port takes around 64 cycles to draw an entire sprite at the current graphics
register coorinates. The `draw_pixel` port is simpler and doesn't take additional cycles to
simply write a single pixel to the display buffer.

## Audio
There is no dedicated audio hardware, so only CPU driven square wave based audio is 
possible. The music player assembly program does just this by using a Python script to
convert Arduino targeted music code to 8-bit friendly binaries that specify the timer values
for each note.

## UART Serial
UART communication is accomplished using an Intel IP core. A dummy VHDL component exists in
the Logisim circuit which is later patched by the `synthesize.sh` script. The actual 
implementation simply instantiates the UART component and interfaces it with the rest of the
computer. A dual-clock FIFO buffer is present in the VHDL implementation that interfaces with 
the UART IP core and allows the running program to access the buffer at any processor speed.
The first byte transmitted in a program tends to get corrupted for some reason, but sending
a null byte seems to harmlessly prevent this. Uses 115200 baud rate with 2 stop bits and no 
parity. The IP was configured with 1 stop bit, but seems to not work after 11 or so bytes are
sent when using 1, so use 2.

## Pulse Width Modulation
There are 6 PWM drivers on the Arduino Uno header pins in the typical Uno locations of pins
3, 5, 6, 9, 10, and 11. Each PWM channel can be enabled or disabled to control whether they
will override the output GPIO value for each pin. They work off of an 8-bit duty cycle which
works incredibly simply by comparing the state of an always incrementing 8-bit register with
said duty cycle and outputting a 1 if the current value is less than that of the duty cycle. 
The resulting frequency is around 200 KHz, which is fine for dimming LEDs.

## Analog to Digital Converters
The DE10-Lite board has 6 exposed ADC compatible pins which can be accessed using an Intel 
IP core. There is a dummy VHDL component which interfaces with the rest of the computer in
Logisim. The patched code maps the 6 ADC inputs to 6 8-bit busses which are read through
I/O ports by programs. It's a 12-bit ADC, so only the 8 most significant bits are read.
