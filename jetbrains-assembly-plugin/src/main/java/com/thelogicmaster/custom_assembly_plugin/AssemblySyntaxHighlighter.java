package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lexer.Lexer;
import com.intellij.openapi.editor.DefaultLanguageHighlighterColors;
import com.intellij.openapi.editor.HighlighterColors;
import com.intellij.openapi.editor.colors.TextAttributesKey;
import com.intellij.openapi.fileTypes.SyntaxHighlighterBase;
import com.intellij.psi.TokenType;
import com.intellij.psi.tree.IElementType;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.NotNull;

import static com.intellij.openapi.editor.colors.TextAttributesKey.createTextAttributesKey;

public class AssemblySyntaxHighlighter extends SyntaxHighlighterBase {

	public static final TextAttributesKey SEPARATOR =
		createTextAttributesKey("ASSEMBLY_SEPARATOR", DefaultLanguageHighlighterColors.COMMA);
	public static final TextAttributesKey REGISTER =
		createTextAttributesKey("ASSEMBLY_REGISTER", DefaultLanguageHighlighterColors.GLOBAL_VARIABLE);
	public static final TextAttributesKey HL =
		createTextAttributesKey("ASSEMBLY_HL", DefaultLanguageHighlighterColors.GLOBAL_VARIABLE);
	public static final TextAttributesKey CONSTANT =
		createTextAttributesKey("ASSEMBLY_CONSTANT", DefaultLanguageHighlighterColors.CONSTANT);
	public static final TextAttributesKey DEFINITION =
		createTextAttributesKey("ASSEMBLY_DEFINITION", DefaultLanguageHighlighterColors.CONSTANT);
	public static final TextAttributesKey CONDITION =
		createTextAttributesKey("ASSEMBLY_CONDITION", DefaultLanguageHighlighterColors.GLOBAL_VARIABLE);
	public static final TextAttributesKey MNEMONIC =
		createTextAttributesKey("ASSEMBLY_MNEMONIC", DefaultLanguageHighlighterColors.KEYWORD);
	public static final TextAttributesKey LABEL =
		createTextAttributesKey("ASSEMBLY_LABEL", DefaultLanguageHighlighterColors.FUNCTION_CALL);
	public static final TextAttributesKey LABEL_DEF =
		createTextAttributesKey("ASSEMBLY_LABEL_DEF", DefaultLanguageHighlighterColors.FUNCTION_DECLARATION);
	public static final TextAttributesKey BAD_CHARACTER =
		createTextAttributesKey("ASSEMBLY_BAD_CHARACTER", HighlighterColors.BAD_CHARACTER);
	public static final TextAttributesKey COMMENT =
		createTextAttributesKey("ASSEMBLY_COMMENT", DefaultLanguageHighlighterColors.LINE_COMMENT);
	public static final TextAttributesKey ARRAY =
		createTextAttributesKey("ASSEMBLY_ARRAY", DefaultLanguageHighlighterColors.LOCAL_VARIABLE);
	public static final TextAttributesKey STRING =
		createTextAttributesKey("ASSEMBLY_STRING", DefaultLanguageHighlighterColors.STRING);

	private static final TextAttributesKey[] BAD_CHAR_KEYS = new TextAttributesKey[]{BAD_CHARACTER};
	private static final TextAttributesKey[] SEPARATOR_KEYS = new TextAttributesKey[]{SEPARATOR};
	private static final TextAttributesKey[] COMMENT_KEYS = new TextAttributesKey[]{COMMENT};
	private static final TextAttributesKey[] MNEMONIC_KEYS = new TextAttributesKey[]{MNEMONIC};
	private static final TextAttributesKey[] REGISTER_KEYS = new TextAttributesKey[]{REGISTER};
	private static final TextAttributesKey[] HL_KEYS = new TextAttributesKey[]{HL};
	private static final TextAttributesKey[] CONDITION_KEYS = new TextAttributesKey[]{CONDITION};
	private static final TextAttributesKey[] CONSTANT_KEYS = new TextAttributesKey[]{CONSTANT};
	private static final TextAttributesKey[] DEFINITION_KEYS = new TextAttributesKey[]{DEFINITION};
	private static final TextAttributesKey[] LABEL_KEYS = new TextAttributesKey[]{LABEL};
	private static final TextAttributesKey[] LABEL_DEF_KEYS = new TextAttributesKey[]{LABEL_DEF};
	private static final TextAttributesKey[] ARRAY_KEYS = new TextAttributesKey[]{ARRAY};
	private static final TextAttributesKey[] STRING_KEYS = new TextAttributesKey[]{STRING};
	private static final TextAttributesKey[] EMPTY_KEYS = new TextAttributesKey[0];

	@Override
	public @NotNull Lexer getHighlightingLexer () {
		return new AssemblyLexerAdaptor();
	}

	@Override
	public TextAttributesKey @NotNull [] getTokenHighlights (IElementType tokenType) {
		if (tokenType.equals(AssemblyTypes.CONSTANT))
			return CONSTANT_KEYS;
		else if (tokenType.equals(AssemblyTypes.DEFINITION))
			return DEFINITION_KEYS;
		else if (tokenType.equals(AssemblyTypes.REGISTER))
			return REGISTER_KEYS;
		else if (tokenType.equals(AssemblyTypes.CONDITION))
			return CONDITION_KEYS;
		else if (tokenType.equals(AssemblyTypes.SEPARATOR))
			return SEPARATOR_KEYS;
		else if (tokenType.equals(AssemblyTypes.ARRAY))
			return ARRAY_KEYS;
		else if (tokenType.equals(AssemblyTypes.STRING))
			return STRING_KEYS;
		else if (tokenType.equals(AssemblyTypes.MNEMONIC))
			return MNEMONIC_KEYS;
		else if (tokenType.equals(AssemblyTypes.LABEL))
			return LABEL_KEYS;
		else if (tokenType.equals(AssemblyTypes.LABEL_DEF))
			return LABEL_DEF_KEYS;
		else if (tokenType.equals(AssemblyTypes.COMMENT))
			return COMMENT_KEYS;
		else if (tokenType.equals(AssemblyTypes.HL))
			return HL_KEYS;
		else if (tokenType.equals(TokenType.BAD_CHARACTER))
			return BAD_CHAR_KEYS;
		else
			return EMPTY_KEYS;
	}
}
