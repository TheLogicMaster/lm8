// This is a generated file. Not intended for manual editing.
package com.thelogicmaster.custom_assembly_plugin.psi;

import com.intellij.psi.tree.IElementType;
import com.intellij.psi.PsiElement;
import com.intellij.lang.ASTNode;
import com.thelogicmaster.custom_assembly_plugin.psi.impl.*;

public interface AssemblyTypes {

  IElementType INSTRUCTION = new AssemblyElementType("INSTRUCTION");
  IElementType LABEL_DEFINITION = new AssemblyElementType("LABEL_DEFINITION");

  IElementType ARRAY = new AssemblyTokenType("ARRAY");
  IElementType COMMENT = new AssemblyTokenType("COMMENT");
  IElementType CONDITION = new AssemblyTokenType("CONDITION");
  IElementType CONSTANT = new AssemblyTokenType("CONSTANT");
  IElementType CRLF = new AssemblyTokenType("CRLF");
  IElementType DEFINITION = new AssemblyTokenType("DEFINITION");
  IElementType HL = new AssemblyTokenType("HL");
  IElementType LABEL = new AssemblyTokenType("LABEL");
  IElementType LABEL_DEF = new AssemblyTokenType("LABEL_DEF");
  IElementType MNEMONIC = new AssemblyTokenType("MNEMONIC");
  IElementType REGISTER = new AssemblyTokenType("REGISTER");
  IElementType SEPARATOR = new AssemblyTokenType("SEPARATOR");
  IElementType STRING = new AssemblyTokenType("STRING");

  class Factory {
    public static PsiElement createElement(ASTNode node) {
      IElementType type = node.getElementType();
      if (type == INSTRUCTION) {
        return new AssemblyInstructionImpl(node);
      }
      else if (type == LABEL_DEFINITION) {
        return new AssemblyLabelDefinitionImpl(node);
      }
      throw new AssertionError("Unknown element type: " + type);
    }
  }
}
