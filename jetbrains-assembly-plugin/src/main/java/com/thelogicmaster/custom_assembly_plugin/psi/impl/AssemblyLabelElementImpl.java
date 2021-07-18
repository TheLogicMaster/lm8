package com.thelogicmaster.custom_assembly_plugin.psi.impl;

import com.intellij.extapi.psi.ASTWrapperPsiElement;
import com.intellij.lang.ASTNode;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelElement;
import org.jetbrains.annotations.NotNull;

public abstract class AssemblyLabelElementImpl extends ASTWrapperPsiElement implements AssemblyLabelElement {

	public AssemblyLabelElementImpl (@NotNull ASTNode node) {
		super(node);
	}
}
