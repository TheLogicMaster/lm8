package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.fileChooser.FileChooserDescriptor;
import com.intellij.openapi.ui.TextBrowseFolderListener;
import com.intellij.openapi.ui.TextFieldWithBrowseButton;
import com.intellij.ui.components.JBLabel;
import com.intellij.ui.components.JBTextField;
import com.intellij.util.ui.FormBuilder;

import javax.swing.*;

public class AssemblySettingsComponent {

	private final JPanel panel;
	private final TextFieldWithBrowseButton assemblerField = new TextFieldWithBrowseButton(new JBTextField());
	private final TextFieldWithBrowseButton emulatorField = new TextFieldWithBrowseButton(new JBTextField());

	public AssemblySettingsComponent() {
		panel = FormBuilder.createFormBuilder()
			.addLabeledComponent(new JBLabel("Assembler path: "), assemblerField, 1, false)
			.addLabeledComponent(new JBLabel("Emulator path: "), emulatorField, 1, false)
			.addComponentFillVertically(new JPanel(), 0)
			.getPanel();

		FileChooserDescriptor descriptor = new FileChooserDescriptor(true, false, false, false, false, false);
		assemblerField.addBrowseFolderListener(new TextBrowseFolderListener(descriptor));
		emulatorField.addBrowseFolderListener(new TextBrowseFolderListener(descriptor));
	}

	public JPanel getPanel() {
		return panel;
	}

	public JComponent getPreferredFocusedComponent() {
		return assemblerField;
	}

	public String getEmulatorPath() {
		return emulatorField.getText();
	}

	public void setEmulatorPath(String path) {
		emulatorField.setText(path);
	}

	public String getAssemblerPath() {
		return assemblerField.getText();
	}

	public void setAssemblerPath(String path) {
		assemblerField.setText(path);
	}
}
