package com.thelogicmaster.custom_assembly_plugin.psi.impl;

import com.intellij.extapi.psi.ASTWrapperPsiElement;
import com.intellij.lang.ASTNode;
import com.intellij.psi.PsiReference;
import com.intellij.psi.impl.source.resolve.reference.ReferenceProvidersRegistry;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyInstructionElement;
import org.jetbrains.annotations.NotNull;

public abstract class AssemblyInstructionElementImpl extends ASTWrapperPsiElement implements AssemblyInstructionElement {

	public AssemblyInstructionElementImpl(@NotNull ASTNode node) {
		super(node);
	}

	@Override
	public PsiReference getReference() {
		PsiReference[] references = ReferenceProvidersRegistry.getReferencesFromProviders(this);
		if (references.length == 0)
			return null;
		return references[0];
	}
}
