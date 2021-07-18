package com.thelogicmaster.custom_assembly_plugin.psi;

import com.intellij.lang.documentation.DocumentationMarkup;
import com.intellij.psi.PsiElement;
import com.intellij.psi.impl.FakePsiElement;
import com.thelogicmaster.custom_assembly_plugin.AssemblyLanguage;
import org.jetbrains.annotations.Nullable;

public class AssemblyDocumentationElement extends FakePsiElement {
	private final PsiElement element;

	public AssemblyDocumentationElement(PsiElement element) {
		this.element = element;
	}

	@Override
	public PsiElement getParent() {
		return element;
	}

	@Nullable
	public String getDocumentation() {
		String mnemonic = element.getText().toLowerCase();
		if (!AssemblyLanguage.DOCUMENTATION.containsKey(mnemonic))
			return null;
		String[] docs = AssemblyLanguage.DOCUMENTATION.get(mnemonic);

		StringBuilder builder = new StringBuilder();
		builder.append(DocumentationMarkup.DEFINITION_START);
		builder.append(mnemonic.toUpperCase());
		builder.append(DocumentationMarkup.DEFINITION_END);
		builder.append(DocumentationMarkup.CONTENT_START);
		builder.append(docs[0]);

		builder.append(DocumentationMarkup.SECTIONS_START);
		for (int i = 1; i < docs.length; i++) {
			builder.append(DocumentationMarkup.SECTION_HEADER_START);
			builder.append(DocumentationMarkup.SECTION_START);
			builder.append(docs[i]);
			builder.append(DocumentationMarkup.SECTION_END);
		}
		builder.append(DocumentationMarkup.SECTIONS_END);

		builder.append(DocumentationMarkup.CONTENT_END);
		return builder.toString();
	}
}
