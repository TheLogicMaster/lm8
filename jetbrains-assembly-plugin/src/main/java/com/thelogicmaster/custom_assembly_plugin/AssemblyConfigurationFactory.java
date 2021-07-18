package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.execution.configurations.ConfigurationFactory;
import com.intellij.execution.configurations.RunConfiguration;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.project.ProjectUtil;
import com.intellij.openapi.vfs.VirtualFile;
import com.jetbrains.python.run.PythonConfigurationType;
import com.jetbrains.python.run.PythonRunConfiguration;
import org.jetbrains.annotations.NotNull;

import java.nio.file.Paths;

public class AssemblyConfigurationFactory extends ConfigurationFactory {

	protected AssemblyConfigurationFactory () {
		super(PythonConfigurationType.getInstance());
	}

	@Override
	public @NotNull String getId () {
		return "RunProgram";
	}

	@Override
	public @NotNull RunConfiguration createTemplateConfiguration(@NotNull Project project) {
		PythonRunConfiguration config = (PythonRunConfiguration)PythonConfigurationType.getInstance().getFactory().createTemplateConfiguration(project);
		VirtualFile projectDir = ProjectUtil.guessProjectDir(project).getParent();
		config.setScriptName(Paths.get(projectDir.getPath(), "assembler.py").toAbsolutePath().toString());
		config.setWorkingDirectory(projectDir.getPath());
		return config;
	}
}
