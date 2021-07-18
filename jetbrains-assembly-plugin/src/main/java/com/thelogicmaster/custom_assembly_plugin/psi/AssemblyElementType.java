package com.thelogicmaster.custom_assembly_plugin.psi;

import com.intellij.psi.tree.IElementType;
import com.thelogicmaster.custom_assembly_plugin.AssemblyLanguage;
import org.jetbrains.annotations.NonNls;
import org.jetbrains.annotations.NotNull;

public class AssemblyElementType extends IElementType {

	public AssemblyElementType(@NotNull @NonNls String debugName) {
		super(debugName, AssemblyLanguage.INSTANCE);
	}
}
