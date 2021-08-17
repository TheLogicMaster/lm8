package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.documentation.AbstractDocumentationProvider;
import com.intellij.lang.documentation.DocumentationMarkup;
import com.intellij.openapi.editor.Editor;
import com.intellij.psi.PsiComment;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiFile;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyDocumentationElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.regex.Pattern;

public class AssemblyDocumentationProvider extends AbstractDocumentationProvider {

	private String generateLabelDoc(AssemblyLabelElement element, @Nullable PsiElement originalElement) {
		if (originalElement != null && originalElement.getNode().getElementType() == AssemblyTypes.LABEL_DEF)
			return null;

		ArrayList<String> docs = new ArrayList<>();
		PsiElement previous = element.getPrevSibling();
		while (previous != null) {
			if (previous instanceof PsiComment)
				docs.add(previous.getText().split(";")[1]);
			else if (previous.getNode().getElementType() != AssemblyTypes.CRLF)
				break;
			previous = previous.getPrevSibling();
		}
		if (docs.size() == 0)
			return null;
		Collections.reverse(docs);

		StringBuilder builder = new StringBuilder();
		builder.append(DocumentationMarkup.DEFINITION_START);
		builder.append(element.getName());
		builder.append(DocumentationMarkup.DEFINITION_END);
		builder.append(DocumentationMarkup.CONTENT_START);
		for (String line: docs)
			builder.append(line);
		builder.append(DocumentationMarkup.CONTENT_END);
		return builder.toString();
	}

	private String generateInstructionDoc(PsiElement element) {
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

	private String generateConstantDoc(PsiElement element) {
		return "'" + element.getText() + "' evaluates to: " + AssemblyLanguage.evaluateOperandConstant(element.getNode());
	}

	@Override
	public @Nullable String generateDoc(PsiElement element, @Nullable PsiElement originalElement) {
		if (element instanceof AssemblyDocumentationElement)
			return (((AssemblyDocumentationElement)element)).getDocumentation();
		else if (element instanceof AssemblyLabelElement)
			return generateLabelDoc((AssemblyLabelElement)element, originalElement);
		else
			return null;
	}

	@Override
	public @Nullable PsiElement getCustomDocumentationElement(@NotNull Editor editor, @NotNull PsiFile file, @Nullable PsiElement contextElement, int targetOffset) {
		if (contextElement == null)
			return null;

		if (contextElement.getNode().getElementType() == AssemblyTypes.MNEMONIC)
			return new AssemblyDocumentationElement(contextElement, generateInstructionDoc(contextElement));
		else if (contextElement.getNode().getElementType() == AssemblyTypes.CONSTANT && Pattern.matches("\\{\\w+}", contextElement.getText()))
			return new AssemblyDocumentationElement(contextElement, generateConstantDoc(contextElement));
		return null;
	}
}
