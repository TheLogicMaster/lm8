package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.Language;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class AssemblyLanguage extends Language {
	public static final AssemblyLanguage INSTANCE = new AssemblyLanguage();
	public static final String[] INSTRUCTIONS;
	public static final String[] PORTS;
	public static final Map<String, String[]> DOCUMENTATION;

	static {
		ArrayList<String> ports = new ArrayList<>(Arrays.asList(
			"print_char", "print_string", "graphics_x", "graphics_y", "draw_pixel", "draw_sprite", "clear_screen", "rand", "swap_display"
		));
		for (int i = 0; i < 6; i++)
			ports.add("seven_segment_" + i);
		for (int i = 0; i < 2; i++)
			ports.add("button_" + i);
		for (int i = 0; i < 10; i++)
			ports.add("led_" + i);
		for (int i = 0; i < 10; i++)
			ports.add("switch_" + i);
		for (int i = 0; i < 36; i++)
			ports.add("gpio_" + i);
		for (int i = 0; i < 16; i++)
			ports.add("arduino_" + i);
		for (int i = 0; i < 6; i++)
			ports.add("adc_" + i);
		PORTS = ports.toArray(new String[0]);

		DOCUMENTATION = new HashMap<>();
		DOCUMENTATION.put("org", new String[]{
			"Set assembly origin",
			"ORG $1234"
		});
		DOCUMENTATION.put("data", new String[]{
			"Enter variable data section",
			"DATA"
		});
		DOCUMENTATION.put("var", new String[]{
			"Variable placeholder for byte or byte array",
			"label: VAR",
			"label: VAR[n]"
		});
		DOCUMENTATION.put("db", new String[]{
			"Define byte, accepts immediate values and String literals",
			"label: DB \"Hello World!\\n\",$0"
		});
		DOCUMENTATION.put("bin", new String[]{
			"Define binary blob from file",
			"BIN \"sprite.bin\""
		});
		DOCUMENTATION.put("nop", new String[]{
			"No operation",
			"NOP"
		});
		DOCUMENTATION.put("ldr", new String[]{
			"Load register with immediate or memory",
			"LDR $FF,A",
			"LDR =label,H",
			"LDR [$1234],L",
			"LDR [label],A",
			"LDR [HL],B"
		});
		DOCUMENTATION.put("str", new String[]{
			"Store register in memory",
			"STR [$1234],H",
			"STR [label],L",
			"STR [HL],A"
		});
		DOCUMENTATION.put("lda", new String[]{
			"Load HL address register from immediate",
			"LDA $1234",
			"LDA label"
		});
		DOCUMENTATION.put("in", new String[]{
			"Read value from port into register. Port can be specified by immediate or in register A",
			"IN #35,A",
			"IN {controller_up},B",
			"IN H"
		});
		DOCUMENTATION.put("out", new String[]{
			"Write a value to a port from a register. Port can be specified by immediate or in register A",
			"OUT #1,A",
			"OUT {print_string},B",
			"OUT H"
		});
		DOCUMENTATION.put("inc", new String[]{
			"Increments a register. Sets Zero and Carry flags",
			"INC A"
		});
		DOCUMENTATION.put("dec", new String[]{
			"Decrements a register. Sets Zero and Carry flags",
			"DEC A"
		});
		DOCUMENTATION.put("ina", new String[]{
			"Increments the HL address register",
			"INA"
		});
		DOCUMENTATION.put("dea", new String[]{
			"Decrements the HL address register",
			"DEA"
		});
		DOCUMENTATION.put("add", new String[]{
			"Adds an immediate or register to A. Sets Zero, Carry, Negative, and Overflow flags",
			"ADD $FF",
			"ADD B"
		});
		DOCUMENTATION.put("adc", new String[]{
			"Adds an immediate or register and Carry to A. Sets Zero, Carry, Negative, and Overflow flags",
			"ADC $FF",
			"ADC B"
		});
		DOCUMENTATION.put("sub", new String[]{
			"Subtracts an immediate or register from A. Sets Zero, Carry, Negative, and Overflow flags",
			"SUB $FF",
			"SUB B"
		});
		DOCUMENTATION.put("sbc", new String[]{
			"Subtracts an immediate or register and Carry from A. Sets Zero, Carry, Negative, and Overflow flags",
			"SBC $FF",
			"SBC B"
		});
		DOCUMENTATION.put("and", new String[]{
			"Bitwise ANDs register A with an immediate or register. Sets Zero, Carry, Negative, and Overflow flags",
			"AND $FF",
			"AND B"
		});
		DOCUMENTATION.put("or", new String[]{
			"Bitwise ORs register A with an immediate or register. Sets Zero, Carry, Negative, and Overflow flags",
			"OR $FF",
			"OR B"
		});
		DOCUMENTATION.put("xor", new String[]{
			"Bitwise XORs register A with an immediate or register. Sets Zero, Carry, Negative, and Overflow flags",
			"XOR $FF",
			"XOR B"
		});
		DOCUMENTATION.put("cmp", new String[]{
			"Sets the Zero, Carry, Negative, and Overflow flags for SUB without modifying register A",
			"CMP $FF",
			"CMP B"
		});
		DOCUMENTATION.put("jmp", new String[]{
			"Jump to address",
			"JMP label",
			"JMP $1234"
		});
		DOCUMENTATION.put("jr", new String[]{
			"Relative jump. Takes an optional condition to jump only if flag is set or unset",
			"JR #-4",
			"JR label",
			"JR label,Z",
			"JR label,nZ"
		});
		DOCUMENTATION.put("push", new String[]{
			"Push a register to the stack",
			"PUSH A"
		});
		DOCUMENTATION.put("pop", new String[]{
			"Pop a register from the stack",
			"POP A"
		});
		DOCUMENTATION.put("jsr", new String[]{
			"Jump to subroutine",
			"JSR label",
			"JSR $1234"
		});
		DOCUMENTATION.put("ret", new String[]{
			"Return from subroutine",
			"RET"
		});
		DOCUMENTATION.put("halt", new String[]{
			"Halt CPU",
			"HALT"
		});

		INSTRUCTIONS = DOCUMENTATION.keySet().toArray(new String[0]);
	}

	private AssemblyLanguage() {
		super("Assembly");
	}
}
