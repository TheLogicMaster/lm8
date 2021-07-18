package com.thelogicmaster.custom_assembly_plugin.psi;

import com.intellij.psi.tree.IElementType;
import com.thelogicmaster.custom_assembly_plugin.AssemblyLanguage;
import org.jetbrains.annotations.NonNls;
import org.jetbrains.annotations.NotNull;

public class AssemblyTokenType extends IElementType {
	public AssemblyTokenType(@NotNull @NonNls String debugName) {
		super(debugName, AssemblyLanguage.INSTANCE);
	}

	@Override
	public String toString() {
		return "AssemblyTokenType." + super.toString();
	}
}
