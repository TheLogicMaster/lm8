package com.thelogicmaster.custom_assembly_plugin.psi.impl;

import com.intellij.lang.ASTNode;
import com.intellij.navigation.ItemPresentation;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiFile;
import com.thelogicmaster.custom_assembly_plugin.AssemblyIcons;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyElementFactory;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyInstruction;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyInstructionElement;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelDefinition;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

public class AssemblyPsiImplUtil {

	public static String getMnemonic(AssemblyInstruction element) {
		//noinspection ConstantConditions
		return element.getNode().findChildByType(AssemblyTypes.MNEMONIC).getText().toLowerCase();
	}

	@Nullable
	public static ASTNode getLabelNode(AssemblyInstruction element) {
		return element.getNode().findChildByType(AssemblyTypes.LABEL);
	}

	public static String getName(AssemblyLabelDefinition element) {
		ASTNode node = element.getNode().findChildByType(AssemblyTypes.LABEL_DEF);
		if (node == null)
			return null;
		return node.getText().split(":")[0];
	}

	public static PsiElement setName(AssemblyLabelDefinition element, String newName) {
		return AssemblyElementFactory.createLabel(element.getProject(), newName);
	}

	public static PsiElement getNameIdentifier(AssemblyLabelDefinition element) {
		ASTNode keyNode = element.getNode().findChildByType(AssemblyTypes.LABEL_DEF);
		if (keyNode != null)
			return keyNode.getPsi();
		return null;
	}

	public static ItemPresentation getPresentation(final AssemblyLabelDefinition element) {
		return new ItemPresentation() {
			@Nullable
			@Override
			public String getPresentableText() {
				return element.getName();
			}

			@Nullable
			@Override
			public String getLocationString() {
				PsiFile containingFile = element.getContainingFile();
				return containingFile == null ? null : containingFile.getName();
			}

			@Override
			public Icon getIcon(boolean unused) {
				PsiElement next = element.getNextSibling();
				String instruction = "";
				while (next != null) {
					if (next instanceof AssemblyInstructionElement) {
						instruction = ((AssemblyInstructionElement)next).getMnemonic();
						break;
					}
					next = next.getNextSibling();
				}
				switch (instruction) {
				case "var":
					return AssemblyIcons.VARIABLE;
				case "db":
				case "bin":
					return AssemblyIcons.CONSTANT;
				default:
					return AssemblyIcons.LABEL;
				}
			}
		};
	}
}
