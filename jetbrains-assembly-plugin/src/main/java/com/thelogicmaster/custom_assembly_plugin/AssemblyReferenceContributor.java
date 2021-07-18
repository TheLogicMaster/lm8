package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.ASTNode;
import com.intellij.openapi.util.TextRange;
import com.intellij.patterns.PlatformPatterns;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiReference;
import com.intellij.psi.PsiReferenceContributor;
import com.intellij.psi.PsiReferenceProvider;
import com.intellij.psi.PsiReferenceRegistrar;
import com.intellij.util.ProcessingContext;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyInstructionElement;
import org.jetbrains.annotations.NotNull;

public class AssemblyReferenceContributor extends PsiReferenceContributor {

	@Override
	public void registerReferenceProviders (@NotNull PsiReferenceRegistrar registrar) {
		registrar.registerReferenceProvider(PlatformPatterns.psiElement(AssemblyInstructionElement.class),
			new PsiReferenceProvider() {
				@NotNull
				@Override
				public PsiReference[] getReferencesByElement(@NotNull PsiElement element, @NotNull ProcessingContext context) {
					ASTNode label = ((AssemblyInstructionElement)element).getLabelNode();
					if (label == null)
						return PsiReference.EMPTY_ARRAY;
					int offset = label.getStartOffsetInParent();
					return new PsiReference[]{
						new AssemblyReference(element, new TextRange(offset, offset + label.getTextLength()), label.getText().replaceAll("[=\\[\\]]", ""))
					};
				}
			});
	}
}
