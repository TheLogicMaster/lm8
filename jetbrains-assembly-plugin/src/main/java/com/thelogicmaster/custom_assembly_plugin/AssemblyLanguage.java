package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.ASTNode;
import com.intellij.lang.Language;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiFile;
import com.intellij.psi.PsiManager;
import com.intellij.psi.search.FileTypeIndex;
import com.intellij.psi.search.GlobalSearchScope;
import com.intellij.psi.util.PsiTreeUtil;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyFile;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyInstructionElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelDefinition;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;

import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AssemblyLanguage extends Language {
	public static final AssemblyLanguage INSTANCE = new AssemblyLanguage();
	public static final String[] INSTRUCTIONS;
	public static final Map<String, Integer> PORTS;
	public static final Map<String, Integer> CONSTANTS;
	public static final String[] TIMER_UNITS = new String[]{
		"microseconds", "centimilliseconds", "decimilliseconds", "milliseconds", "centiseconds", "deciseconds", "seconds", "decaseconds"
	};
	public static final Map<String, String[]> DOCUMENTATION;

	private static final int MAX_INCLUDE_DEPTH = 100;

	static {
		PORTS = new HashMap<>();
		PORTS.put("serial", 0);
		PORTS.put("serial_available", 1);
		PORTS.put("graphics_x", 30);
		PORTS.put("graphics_y", 31);
		PORTS.put("draw_pixel", 32);
		PORTS.put("draw_sprite", 33);
		PORTS.put("clear_screen", 34);
		PORTS.put("rand", 93);
		PORTS.put("swap_display", 94);
		PORTS.put("gpio_output", 95);
		PORTS.put("gpio_input", 96);
		PORTS.put("arduino_output", 97);
		PORTS.put("arduino_input", 98);
		PORTS.put("pwm_enable", 99);
		PORTS.put("pwm_disable", 100);
		PORTS.put("pwm_3", 101);
		PORTS.put("pwm_5", 102);
		PORTS.put("pwm_6", 103);
		PORTS.put("pwm_9", 104);
		PORTS.put("pwm_10", 105);
		PORTS.put("pwm_11", 106);
		PORTS.put("serial_enable", 107);
		for (int i = 0; i < 6; i++)
			PORTS.put("seven_segment_" + i, 2 + i);
		for (int i = 0; i < 2; i++)
			PORTS.put("button_" + i, 8 + i);
		for (int i = 0; i < 10; i++)
			PORTS.put("led_" + i, 10 + i);
		for (int i = 0; i < 10; i++)
			PORTS.put("switch_" + i, 20 + i);
		for (int i = 0; i < 36; i++)
			PORTS.put("gpio_" + i, 35 + i);
		for (int i = 0; i < 16; i++)
			PORTS.put("arduino_" + i, 71 + i);
		for (int i = 0; i < 6; i++)
			PORTS.put("adc_" + i, 87 + 1);
		for (int i = 0; i < 2; i++)
			PORTS.put("timer_unit_" + i, 108 + i);
		for (int i = 0; i < 2; i++)
			PORTS.put("timer_count_" + i, 110 + i);
		for (int i = 0; i < 2; i++)
			PORTS.put("timer_" + i, 112 + i);

		CONSTANTS = new HashMap<>(PORTS);
		CONSTANTS.put("controller_up", 35);
		CONSTANTS.put("controller_down", 36);
		CONSTANTS.put("controller_left", 37);
		CONSTANTS.put("controller_right", 38);
		CONSTANTS.put("microseconds", 0);
		for (int i = 0; i < TIMER_UNITS.length; i++)
			CONSTANTS.put(TIMER_UNITS[i], i);

		DOCUMENTATION = new HashMap<>();
		DOCUMENTATION.put("org", new String[]{
			"Set assembly origin",
			"ORG $1234"
		});
		DOCUMENTATION.put("include", new String[]{
			"Include an assembly file",
			"INCLUDE \"libraries/Math.asm\""
		});
		DOCUMENTATION.put("def", new String[]{
			"Define a constant",
			"DEF constant=$1"
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

	/**
	 * Collects all Assembly program files in the project
	 * @param project to collect from
	 * @return List of collected files
	 */
	public static List<AssemblyFile> getProjectFiles(Project project) {
		ArrayList<AssemblyFile> files = new ArrayList<>();
		Collection<VirtualFile> virtualFiles = FileTypeIndex.getFiles(AssemblyFileType.INSTANCE, GlobalSearchScope.allScope(project));
		for (VirtualFile virtualFile: virtualFiles) {
			AssemblyFile assemblyFile = (AssemblyFile)PsiManager.getInstance(project).findFile(virtualFile);
			if (assemblyFile == null)
				continue;
			files.add(assemblyFile);
		}
		return files;
	}

	private static void extractDefinition(AssemblyInstructionElement instructionElement, Map<String, String> constants) {
		Matcher matcher = Pattern.compile("def\\W+(\\w+)=(.+)").matcher(instructionElement.getText());
		if (!matcher.matches())
			return;
		constants.put(matcher.group(1), matcher.group(2));
	}

	private static void collectVisibleConstants(PsiElement file, PsiElement operand, Map<String, String> constants, Set<String> includes, int depth) {
		if (depth > MAX_INCLUDE_DEPTH)
			return;

		AssemblyInstructionElement[] instructions = PsiTreeUtil.getChildrenOfType(file, AssemblyInstructionElement.class);
		if (instructions == null)
			return;

		for (AssemblyInstructionElement instruction: instructions) {
			if (instruction == operand.getParent())
				return;
			String mnemonic = instruction.getMnemonic();

			if ("include".equals(mnemonic)) {
				ASTNode includeNode = instruction.getNode().findChildByType(AssemblyTypes.STRING);
				if (includeNode == null)
					continue;
				String include = includeNode.getText().replace("\"", "");
				String includePath = Paths.get(operand.getContainingFile().getVirtualFile().getParent().getPath(), include).toAbsolutePath().toString();
				if (!includes.add(includePath))
					continue;

				for (AssemblyFile assemblyFile : getProjectFiles(operand.getProject()))
					if (includePath.equals(assemblyFile.getVirtualFile().getPath()))
						collectVisibleConstants(assemblyFile, operand, constants, includes, depth + 1);
			} else if ("def".equals(mnemonic))
				extractDefinition(instruction, constants);
		}
	}

	/**
	 * Attempts to parse a constant within an operand node.
	 * Upon failing to do so, just returns the source node text
	 * @param operand to parse
	 * @return String of parsed operand
	 */
	public static String evaluateOperandConstant(ASTNode operand) {
		Pattern pattern = Pattern.compile("\\{(\\w+)}");

		HashMap<String, String> constants = new HashMap<>();
		for (Map.Entry<String, Integer> entry: CONSTANTS.entrySet())
			constants.put(entry.getKey(), "#" + entry.getValue());
		collectVisibleConstants(operand.getPsi().getContainingFile(), operand.getPsi().getParent(), constants, new HashSet<>(), 0);

		String current = operand.getText();

		for (int i = 0; i < 10; i++) {
			Matcher matcher = pattern.matcher(current);
			if (!matcher.matches())
				break;
			String constant = matcher.group(1);
			if (!constants.containsKey(constant))
				break;
			current = constants.get(constant);
		}

		return current;
	}

	private static void collectVisibleLabels(PsiFile file, Collection<AssemblyLabelDefinition> definitions, Set<String> collected, Set<String> duplicates, Set<String> includes, int depth) {
		if (depth > MAX_INCLUDE_DEPTH)
			return;

		AssemblyLabelDefinition[] labels = PsiTreeUtil.getChildrenOfType(file, AssemblyLabelDefinition.class);
		if (labels != null)
			for (AssemblyLabelDefinition label: labels) {
				definitions.add(label);
				String labelName = label.getName();
				if (!collected.add(labelName))
					duplicates.add(labelName);
			}

		AssemblyInstructionElement[] instructions = PsiTreeUtil.getChildrenOfType(file, AssemblyInstructionElement.class);
		if (instructions != null)
			for (AssemblyInstructionElement instruction: instructions) {
				if (!"include".equals(instruction.getMnemonic()))
					continue;

				ASTNode include = instruction.getNode().findChildByType(AssemblyTypes.STRING);
				if (include == null)
					continue;
				String includeText = include.getText().replace("\"", "");
				String includePath = Paths.get(file.getVirtualFile().getParent().getPath(), includeText).toAbsolutePath().toString();
				if (!includes.add(includePath))
					continue;

				for (AssemblyFile assemblyFile : getProjectFiles(file.getProject()))
					if (includePath.equals(assemblyFile.getVirtualFile().getPath()))
						collectVisibleLabels(assemblyFile, definitions, collected, duplicates, includes, depth + 1);
			}
	}

	/**
	 * Collects all visible labels in an Assembly program
	 * @param file to collect labels from
	 * @param definitions collection to store results
	 * @return A set of duplicate label names
	 */
	public static Set<String> collectVisibleLabels(PsiFile file, Collection<AssemblyLabelDefinition> definitions) {
		Set<String> duplicates = new HashSet<>();
		collectVisibleLabels(file, definitions, new HashSet<>(), duplicates, new HashSet<>(), 0);
		return duplicates;
	}

	private AssemblyLanguage() {
		super("Assembly");
	}
}
