package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.execution.actions.ConfigurationContext;
import com.intellij.execution.actions.LazyRunConfigurationProducer;
import com.intellij.execution.configurations.ConfigurationFactory;
import com.intellij.openapi.util.Ref;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiFile;
import com.jetbrains.python.run.PythonRunConfiguration;
import org.jetbrains.annotations.NotNull;

public class AssemblyRunConfigurationProducer extends LazyRunConfigurationProducer<PythonRunConfiguration> {

	private final AssemblyConfigurationFactory factory = new AssemblyConfigurationFactory();

	@NotNull
	@Override
	public ConfigurationFactory getConfigurationFactory () {
		return factory;
	}

	@Override
	protected boolean setupConfigurationFromContext(@NotNull PythonRunConfiguration configuration, @NotNull ConfigurationContext context, @NotNull Ref<PsiElement> sourceElement) {
		if (!AssemblySettingsState.getInstance().isConfigured(configuration.getProject()))
			return false;

		AssemblySettingsState settings = AssemblySettingsState.getInstance();
		if (!settings.assemblerPath.isEmpty())
			configuration.setScriptName(settings.assemblerPath);

		if (sourceElement.get().getContainingFile() == null || sourceElement.get().getContainingFile().getVirtualFile().getParent() == null)
			return false;

		configuration.setWorkingDirectory(sourceElement.get().getContainingFile().getVirtualFile().getParent().getPath());

		String params = "-r \"" + sourceElement.get().getContainingFile().getVirtualFile().getPath() + "\"";
		if (!settings.emulatorPath.isEmpty())
			params = params + " -e \"" + settings.emulatorPath + "\"";
		if (!settings.simulatorPath.isEmpty())
			params = params + " -s \"" + settings.simulatorPath + "\"";

		configuration.setScriptParameters(params);
		configuration.setName("Run " + sourceElement.get().getContainingFile().getName().split("\\.")[0]);
		PsiFile program = sourceElement.get().getContainingFile();
		return program.getFileType() == AssemblyFileType.INSTANCE;
	}

	@Override
	public boolean isConfigurationFromContext(@NotNull PythonRunConfiguration configuration, @NotNull ConfigurationContext context) {
		return false;
	}
}
