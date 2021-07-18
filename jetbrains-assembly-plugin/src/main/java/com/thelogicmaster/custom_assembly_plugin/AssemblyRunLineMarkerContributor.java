package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.execution.lineMarker.ExecutorAction;
import com.intellij.execution.lineMarker.RunLineMarkerContributor;
import com.intellij.icons.AllIcons;
import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.util.text.StringUtil;
import com.intellij.psi.PsiElement;
import com.intellij.util.containers.ContainerUtil;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyFile;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import com.intellij.util.Function;

public class AssemblyRunLineMarkerContributor extends RunLineMarkerContributor {

	@Override
	public @Nullable Info getInfo(@NotNull PsiElement element) {
		if (!(element instanceof AssemblyFile))
			return null;

		final AnAction[] actions = ExecutorAction.getActions();
		Function<PsiElement, String> tooltipProvider =
			psiElement -> StringUtil.join(ContainerUtil.mapNotNull(actions, action -> getText(action, psiElement)), "\n");
		return new Info(AllIcons.RunConfigurations.TestState.Run, tooltipProvider, actions);
	}
}
