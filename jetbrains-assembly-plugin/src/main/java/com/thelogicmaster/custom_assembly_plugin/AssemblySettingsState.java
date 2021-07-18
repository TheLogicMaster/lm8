package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.components.PersistentStateComponent;
import com.intellij.openapi.components.State;
import com.intellij.openapi.components.Storage;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.project.ProjectUtil;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.util.xmlb.XmlSerializerUtil;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@State(
	name = "com.thelogicmaster.jetbrains_plugin.AssemblySettingsState",
	storages = {@Storage("CustomAssemblyPlugin.xml")}
)
public class AssemblySettingsState implements PersistentStateComponent<AssemblySettingsState> {

	public String assemblerPath = "";
	public String emulatorPath = "";

	public static AssemblySettingsState getInstance() {
		return ApplicationManager.getApplication().getService(AssemblySettingsState.class);
	}

	public boolean isConfigured(Project project) {
		VirtualFile projectDir = ProjectUtil.guessProjectDir(project);
		Path rootPath = null;
		if (projectDir != null)
			rootPath = Paths.get(projectDir.getParent().getPath());

		if (!assemblerPath.isEmpty()) {
			if (!Files.exists(Paths.get(assemblerPath)))
				return false;
		} else if (rootPath != null) {
			if (!Files.exists(rootPath.resolve("assembler.py").toAbsolutePath()))
				return false;
		} else
			return false;

		if (!emulatorPath.isEmpty()) {
			return Files.exists(Paths.get(emulatorPath));
		} else if (rootPath != null) {
			return Files.exists(rootPath.resolve("emulator/build/Emulator").toAbsolutePath());
		} else
			return false;
	}

	@Override
	public @Nullable AssemblySettingsState getState () {
		return this;
	}

	@Override
	public void loadState (@NotNull AssemblySettingsState state) {
		XmlSerializerUtil.copyBean(state, this);
	}
}
