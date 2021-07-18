package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.cacheBuilder.DefaultWordsScanner;
import com.intellij.lang.cacheBuilder.WordsScanner;
import com.intellij.lang.findUsages.FindUsagesProvider;
import com.intellij.psi.PsiElement;
import com.intellij.psi.tree.TokenSet;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.Nls;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class AssemblyFindUsagesProvider implements FindUsagesProvider {

	@Override
	public @Nullable WordsScanner getWordsScanner () {
		return new DefaultWordsScanner(new AssemblyLexerAdaptor(),
			TokenSet.create(AssemblyTypes.LABEL),
			TokenSet.create(AssemblyTypes.COMMENT),
			TokenSet.create(AssemblyTypes.STRING)
		);
	}

	@Override
	public boolean canFindUsagesFor (@NotNull PsiElement psiElement) {
		return psiElement instanceof AssemblyLabelElement;
	}

	@Override
	public @Nullable String getHelpId (@NotNull PsiElement psiElement) {
		return null;
	}

	@Override
	public @Nls @NotNull String getType (@NotNull PsiElement element) {
		if (element instanceof AssemblyLabelElement)
			return "label definition";
		return "";
	}

	@Override
	public @Nls @NotNull String getDescriptiveName (@NotNull PsiElement element) {
		if (!(element instanceof AssemblyLabelElement))
			return "";
		String name = ((AssemblyLabelElement)element).getName();
		if (name == null)
			return "";
		return name;
	}

	@Override
	public @Nls @NotNull String getNodeText (@NotNull PsiElement element, boolean useFullName) {
		return element.getText();
	}
}
