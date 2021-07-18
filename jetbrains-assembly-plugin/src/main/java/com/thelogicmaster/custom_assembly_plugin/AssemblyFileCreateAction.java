package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.ide.actions.CreateFileFromTemplateAction;
import com.intellij.ide.actions.CreateFileFromTemplateDialog;
import com.intellij.openapi.project.Project;
import com.intellij.psi.PsiDirectory;
import org.jetbrains.annotations.NotNull;

public class AssemblyFileCreateAction extends CreateFileFromTemplateAction {

	private static final String NAME = "Create Assembly Program";

	public AssemblyFileCreateAction() {
		super(NAME, "Create an assembly program file", AssemblyIcons.LOGO);
	}

	@Override
	protected void buildDialog(@NotNull Project project, @NotNull PsiDirectory directory, CreateFileFromTemplateDialog.Builder builder) {
		builder
			.setTitle(NAME)
			.addKind("", AssemblyIcons.LOGO, "Assembly Program");
	}

	@Override
	protected String getActionName(PsiDirectory directory, @NotNull String newName, String templateName) {
		return NAME;
	}
}
