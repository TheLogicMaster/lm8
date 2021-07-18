package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.formatting.Alignment;
import com.intellij.formatting.FormattingModel;
import com.intellij.formatting.FormattingModelBuilder;
import com.intellij.formatting.FormattingModelProvider;
import com.intellij.formatting.SpacingBuilder;
import com.intellij.formatting.Wrap;
import com.intellij.formatting.WrapType;
import com.intellij.psi.PsiElement;
import com.intellij.psi.codeStyle.CodeStyleSettings;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.NotNull;

public class AssemblyFormattingModelBuilder implements FormattingModelBuilder {

	private static SpacingBuilder createSpaceBuilder(CodeStyleSettings settings) {
		return new SpacingBuilder(settings, AssemblyLanguage.INSTANCE)
			.after(AssemblyTypes.SEPARATOR)
			.none()

			.before(AssemblyTypes.ARRAY)
			.none()

			.between(AssemblyTypes.LABEL_DEFINITION, AssemblyTypes.INSTRUCTION)
			.spaces(1)

			.before(AssemblyTypes.INSTRUCTION)
			.spaces(4)

			.between(AssemblyTypes.LABEL_DEFINITION, AssemblyTypes.COMMENT)
			.spaces(1)

			.between(AssemblyTypes.INSTRUCTION, AssemblyTypes.COMMENT)
			.spaces(1)

			.after(AssemblyTypes.MNEMONIC)
			.spaces(1)

			.before(AssemblyTypes.COMMENT)
			.none()

			.before(AssemblyTypes.LABEL_DEFINITION)
			.none()

			.after(AssemblyTypes.LABEL_DEFINITION)
			.none()

			.before(AssemblyTypes.CRLF)
			.none();
	}

	@Override
	public @NotNull FormattingModel createModel (PsiElement element, CodeStyleSettings settings) {
		return FormattingModelProvider.createFormattingModelForPsiFile(
			element.getContainingFile(),
			new AssemblyBlock(element.getNode(), Wrap.createWrap(WrapType.NONE, false), Alignment.createAlignment(true), createSpaceBuilder(settings)),
			settings
		);
	}
}
