package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.fileEditor.FileEditor;
import com.intellij.openapi.options.ShowSettingsUtil;
import com.intellij.openapi.project.DumbAware;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.util.Key;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.ui.EditorNotificationPanel;
import com.intellij.ui.EditorNotifications;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyFile;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class AssemblyNotificationProvider extends EditorNotifications.Provider<EditorNotificationPanel> implements DumbAware {

	private static final Key<EditorNotificationPanel> KEY = Key.create("AssemblySdkNotification");

	@Override
	public @NotNull Key<EditorNotificationPanel> getKey() {
		return KEY;
	}

	@Override
	public @Nullable EditorNotificationPanel createNotificationPanel(@NotNull VirtualFile file, @NotNull FileEditor fileEditor, @NotNull Project project) {
		if (!(file.getFileType() instanceof AssemblyFileType))
			return null;

		if (AssemblySettingsState.getInstance().isConfigured(project))
			return null;

		EditorNotificationPanel panel = new EditorNotificationPanel();
		panel.setText("Set Assembler and Emulator paths for program runner support");
		panel.setProject(project);
		panel.setProviderKey(KEY);
		panel.createActionLabel("Open settings", () -> ShowSettingsUtil.getInstance().showSettingsDialog(project, AssemblySettingsConfigurable.class));
		return panel;
	}
}
