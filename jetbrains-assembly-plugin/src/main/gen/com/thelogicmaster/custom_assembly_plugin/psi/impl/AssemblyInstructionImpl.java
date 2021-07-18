// This is a generated file. Not intended for manual editing.
package com.thelogicmaster.custom_assembly_plugin.psi.impl;

import java.util.List;
import org.jetbrains.annotations.*;
import com.intellij.lang.ASTNode;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiElementVisitor;
import com.intellij.psi.util.PsiTreeUtil;
import static com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes.*;
import com.thelogicmaster.custom_assembly_plugin.psi.*;

public class AssemblyInstructionImpl extends AssemblyInstructionElementImpl implements AssemblyInstruction {

  public AssemblyInstructionImpl(@NotNull ASTNode node) {
    super(node);
  }

  public void accept(@NotNull AssemblyVisitor visitor) {
    visitor.visitInstruction(this);
  }

  @Override
  public void accept(@NotNull PsiElementVisitor visitor) {
    if (visitor instanceof AssemblyVisitor) accept((AssemblyVisitor)visitor);
    else super.accept(visitor);
  }

  @Override
  public String getMnemonic() {
    return AssemblyPsiImplUtil.getMnemonic(this);
  }

  @Override
  public @Nullable ASTNode getLabelNode() {
    return AssemblyPsiImplUtil.getLabelNode(this);
  }

}
