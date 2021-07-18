package com.thelogicmaster.custom_assembly_plugin.psi;

import com.intellij.openapi.project.Project;
import com.intellij.psi.PsiFileFactory;
import com.thelogicmaster.custom_assembly_plugin.AssemblyFileType;

public class AssemblyElementFactory {

	public static AssemblyFile createFile(Project project, String text) {
		String name = "dummy.asm";
		return (AssemblyFile) PsiFileFactory.getInstance(project).createFileFromText(name, AssemblyFileType.INSTANCE, text);
	}

	public static AssemblyLabelDefinition createLabel(Project project, String name) {
		final AssemblyFile file = createFile(project, name + ":");
		return (AssemblyLabelDefinition) file.getFirstChild();
	}
}
