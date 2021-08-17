package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.util.TextRange;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiReferenceBase;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelDefinition;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.ArrayList;

public class AssemblyReference extends PsiReferenceBase<PsiElement> {

	private final String label;

	public AssemblyReference(@NotNull PsiElement element, TextRange textRange, String label) {
		super(element, textRange);

		this.label = label;
	}

	@Override
	public @Nullable PsiElement resolve () {
		for (PsiElement e: myElement.getContainingFile().getChildren())
			if (e instanceof AssemblyLabelDefinition && label.equals(((AssemblyLabelDefinition)e).getName()))
				return e;

		ArrayList<AssemblyLabelDefinition> labels = new ArrayList<>();
		AssemblyLanguage.collectVisibleLabels(myElement.getContainingFile(), labels);
		for (AssemblyLabelDefinition definition: labels)
			if (label.equals(definition.getName()))
				return definition;

		return null;
	}
}
