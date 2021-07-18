package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.editor.colors.TextAttributesKey;
import com.intellij.openapi.fileTypes.SyntaxHighlighter;
import com.intellij.openapi.options.colors.AttributesDescriptor;
import com.intellij.openapi.options.colors.ColorDescriptor;
import com.intellij.openapi.options.colors.ColorSettingsPage;
import com.intellij.openapi.util.NlsContexts;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;
import java.util.Map;

public class AssemblyColorSettingsPage implements ColorSettingsPage {

	private static final AttributesDescriptor[] DESCRIPTORS = new AttributesDescriptor[]{
		new AttributesDescriptor("Label", AssemblySyntaxHighlighter.LABEL),
		new AttributesDescriptor("Register", AssemblySyntaxHighlighter.REGISTER),
		new AttributesDescriptor("Array", AssemblySyntaxHighlighter.ARRAY),
		new AttributesDescriptor("Comment", AssemblySyntaxHighlighter.COMMENT),
		new AttributesDescriptor("Bad Value", AssemblySyntaxHighlighter.BAD_CHARACTER),
		new AttributesDescriptor("Condition", AssemblySyntaxHighlighter.CONDITION),
		new AttributesDescriptor("Constant", AssemblySyntaxHighlighter.CONSTANT),
		new AttributesDescriptor("Label Definition", AssemblySyntaxHighlighter.LABEL_DEF),
		new AttributesDescriptor("Separator", AssemblySyntaxHighlighter.SEPARATOR),
		new AttributesDescriptor("Mnemonic", AssemblySyntaxHighlighter.MNEMONIC),
		new AttributesDescriptor("String", AssemblySyntaxHighlighter.STRING)
	};

	@Override
	public @Nullable Icon getIcon () {
		return AssemblyIcons.LOGO;
	}

	@Override
	public @NotNull SyntaxHighlighter getHighlighter () {
		return new AssemblySyntaxHighlighter();
	}

	@Override
	public @NotNull String getDemoText () {
		return "; This is a comment\n"
			+ "\tdb \"Hello World\",#0\n"
			+ "\tORG $100\n"
			+ "hello: ; A label\n"
			+ "\tlda $1234\n"
			+ "\tlda hello\n"
			+ "\tina\n"
			+ "\tldr =hello,a\n"
			+ "\tldr #1,a\n"
			+ "\tldr $2,b\n"
			+ "\tldr [HL],a\n"
			+ "\tldr [$1234],b\n"
			+ "\tldr [var],h\n"
			+ "\tstr [HL],a\n"
			+ "\tstr [var],l\n"
			+ "\tand $F\n"
			+ "\tpush a\n"
			+ "\tin {controller_left},a\n"
			+ "\tin a\n"
			+ "\tjmp hello\n"
			+ "\tjr hello\n"
			+ "\tjr hello,z\n"
			+ "\tjr hello,nz\n"
			+ "\tORG $200\n"
			+ "\tBIN \"sprite.bin\"\n"
			+ "\tdata ; Data section\n"
			+ "temp: var ; Variable\n";
	}

	@Override
	public @Nullable Map<String, TextAttributesKey> getAdditionalHighlightingTagToDescriptorMap () {
		return null;
	}

	@Override
	public AttributesDescriptor @NotNull [] getAttributeDescriptors () {
		return DESCRIPTORS;
	}

	@Override
	public ColorDescriptor @NotNull [] getColorDescriptors () {
		return ColorDescriptor.EMPTY_ARRAY;
	}

	@Override
	public @NotNull @NlsContexts.ConfigurableName String getDisplayName () {
		return "Assembly";
	}
}
