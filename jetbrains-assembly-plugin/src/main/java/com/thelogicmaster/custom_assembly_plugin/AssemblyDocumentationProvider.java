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

public class AssemblyDocumentationProvider extends AbstractDocumentationProvider {

	private static String generateLabelDoc(AssemblyLabelElement element, @Nullable PsiElement originalElement) {
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
		if (contextElement != null && contextElement.getNode().getElementType() == AssemblyTypes.MNEMONIC)
			return new AssemblyDocumentationElement(contextElement);
		return null;
	}
}
