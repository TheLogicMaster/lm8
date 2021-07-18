package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.openapi.fileTypes.SyntaxHighlighter;
import com.intellij.openapi.fileTypes.SyntaxHighlighterFactory;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class AssemblySyntaxHighlighterFactory  extends SyntaxHighlighterFactory {

	@Override
	public @NotNull SyntaxHighlighter getSyntaxHighlighter (@Nullable Project project, @Nullable VirtualFile virtualFile) {
		return new AssemblySyntaxHighlighter();
	}
}
