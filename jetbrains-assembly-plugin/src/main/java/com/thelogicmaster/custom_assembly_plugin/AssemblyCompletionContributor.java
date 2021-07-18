package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.codeInsight.completion.CompletionContributor;
import com.intellij.codeInsight.completion.CompletionParameters;
import com.intellij.codeInsight.completion.CompletionResultSet;
import com.intellij.codeInsight.lookup.LookupElementBuilder;
import com.intellij.psi.PsiElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyInstructionElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelDefinition;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.NotNull;

import java.util.regex.Pattern;

public class AssemblyCompletionContributor extends CompletionContributor {

	private static void fillRegisterVariants(CompletionResultSet result) {
		for (String register: "A,B,H,L".split(","))
			result.addElement(LookupElementBuilder.create(register).withCaseSensitivity(false));
	}

	@Override
	public void fillCompletionVariants (@NotNull CompletionParameters parameters, @NotNull CompletionResultSet result) {
		PsiElement pos = parameters.getPosition();
		PsiElement orig = parameters.getOriginalPosition();
		if (orig == null)
			return;
		if (pos.getNode().getElementType() == AssemblyTypes.MNEMONIC)
			for (String instruction: AssemblyLanguage.INSTRUCTIONS)
				result.addElement(LookupElementBuilder.create(instruction).withCaseSensitivity(false));

		PsiElement parent = pos.getParent();
		if (!(parent instanceof AssemblyInstructionElement))
			return;
		AssemblyInstructionElement instruction = ((AssemblyInstructionElement)parent);
		String mnemonic = instruction.getMnemonic();

		int parameter = 0;
		PsiElement prev = pos.getPrevSibling();
		while (prev != null) {
			if (prev.getNode().getElementType() == AssemblyTypes.SEPARATOR)
				parameter++;
			prev = prev.getPrevSibling();
		}

		if (parameter == 0) {
			if (Pattern.matches("^(ldr|str|lda|jmp|jr|jsr)$", mnemonic)) {
				boolean loadOrStore = Pattern.matches("^(ldr|str)$", mnemonic);
				if (loadOrStore)
					result.addElement(LookupElementBuilder.create("[HL]").withCaseSensitivity(false));
				for (PsiElement element: parameters.getOriginalFile().getChildren()) {
					if (!(element instanceof AssemblyLabelDefinition))
						continue;
					AssemblyLabelDefinition label = (AssemblyLabelDefinition)element;
					String name = label.getName();
					if (name == null)
						continue;
					if (loadOrStore)
						name = "[" + name + "]";
					result.addElement(LookupElementBuilder.create(name).withCaseSensitivity(false));
				}
			}

			if (Pattern.matches("^(inc|dec|add|adc|sub|sbc|and|or|xor|cmp|in|out)$", mnemonic))
				fillRegisterVariants(result);

			if (Pattern.matches("^(in|out)$", mnemonic))
				for (String port: AssemblyLanguage.PORTS)
					result.addElement(LookupElementBuilder.create("{" + port + "}").withCaseSensitivity(false));
		} else if (parameter == 1) {
			if (Pattern.matches("^(jr)$", mnemonic))
				for (String register: "Z,C,N,V,nZ,nC,nN,nV".split(","))
					result.addElement(LookupElementBuilder.create(register).withCaseSensitivity(false));

			if (Pattern.matches("^(ldr|str|lda|in|out)$", mnemonic))
				fillRegisterVariants(result);
		}
	}
}
