package com.thelogicmaster.custom_assembly_plugin.psi;

import com.intellij.psi.PsiElement;
import com.intellij.psi.impl.FakePsiElement;
import org.jetbrains.annotations.Nullable;

public class AssemblyDocumentationElement extends FakePsiElement {
	private final PsiElement element;
	private final String documentation;

	public AssemblyDocumentationElement(PsiElement element, String documentation) {
		this.element = element;
		this.documentation = documentation;
	}

	@Override
	public PsiElement getParent() {
		return element;
	}

	@Nullable
	public String getDocumentation() {
		return documentation;
	}
}
