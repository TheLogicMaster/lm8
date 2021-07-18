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
import com.intellij.navigation.ItemPresentation;

public class AssemblyLabelDefinitionImpl extends AssemblyLabelElementImpl implements AssemblyLabelDefinition {

  public AssemblyLabelDefinitionImpl(@NotNull ASTNode node) {
    super(node);
  }

  public void accept(@NotNull AssemblyVisitor visitor) {
    visitor.visitLabelDefinition(this);
  }

  @Override
  public void accept(@NotNull PsiElementVisitor visitor) {
    if (visitor instanceof AssemblyVisitor) accept((AssemblyVisitor)visitor);
    else super.accept(visitor);
  }

  @Override
  public String getName() {
    return AssemblyPsiImplUtil.getName(this);
  }

  @Override
  public PsiElement setName(String newName) {
    return AssemblyPsiImplUtil.setName(this, newName);
  }

  @Override
  public PsiElement getNameIdentifier() {
    return AssemblyPsiImplUtil.getNameIdentifier(this);
  }

  @Override
  public ItemPresentation getPresentation() {
    return AssemblyPsiImplUtil.getPresentation(this);
  }

}
