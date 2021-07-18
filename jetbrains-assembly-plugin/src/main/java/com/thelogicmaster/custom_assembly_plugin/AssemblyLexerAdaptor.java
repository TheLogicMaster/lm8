package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lexer.FlexAdapter;

public class AssemblyLexerAdaptor extends FlexAdapter {

	public AssemblyLexerAdaptor() {
		super(new AssemblyLexer(null));
	}
}
