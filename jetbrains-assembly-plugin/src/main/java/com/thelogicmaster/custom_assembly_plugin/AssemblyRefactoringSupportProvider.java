package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.refactoring.RefactoringSupportProvider;
import com.intellij.psi.PsiElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelDefinition;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class AssemblyRefactoringSupportProvider extends RefactoringSupportProvider {

	@Override
	public boolean isMemberInplaceRenameAvailable(@NotNull PsiElement elementToRename, @Nullable PsiElement context) {
		return (elementToRename instanceof AssemblyLabelDefinition);
	}
}
