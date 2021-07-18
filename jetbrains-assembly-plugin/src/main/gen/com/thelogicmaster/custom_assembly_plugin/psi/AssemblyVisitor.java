// This is a generated file. Not intended for manual editing.
package com.thelogicmaster.custom_assembly_plugin.psi;

import org.jetbrains.annotations.*;
import com.intellij.psi.PsiElementVisitor;
import com.intellij.psi.PsiElement;

public class AssemblyVisitor extends PsiElementVisitor {

  public void visitInstruction(@NotNull AssemblyInstruction o) {
    visitInstructionElement(o);
  }

  public void visitLabelDefinition(@NotNull AssemblyLabelDefinition o) {
    visitLabelElement(o);
  }

  public void visitInstructionElement(@NotNull AssemblyInstructionElement o) {
    visitPsiElement(o);
  }

  public void visitLabelElement(@NotNull AssemblyLabelElement o) {
    visitPsiElement(o);
  }

  public void visitPsiElement(@NotNull PsiElement o) {
    visitElement(o);
  }

}
