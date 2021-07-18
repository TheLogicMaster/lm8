package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.fileTypes.LanguageFileType;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

public class AssemblyFileType extends LanguageFileType {
	public static final AssemblyFileType INSTANCE = new AssemblyFileType();

	private AssemblyFileType() {
		super(AssemblyLanguage.INSTANCE);
	}

	@NotNull
	@Override
	public String getName() {
		return "Assembly File";
	}

	@NotNull
	@Override
	public String getDescription() {
		return "Assembly language file";
	}

	@NotNull
	@Override
	public String getDefaultExtension() {
		return "asm";
	}

	@Nullable
	@Override
	public Icon getIcon() {
		return AssemblyIcons.LOGO;
	}
}
