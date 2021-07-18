// This is a generated file. Not intended for manual editing.
package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.PsiBuilder;
import com.intellij.lang.PsiBuilder.Marker;
import static com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes.*;
import static com.intellij.lang.parser.GeneratedParserUtilBase.*;
import com.intellij.psi.tree.IElementType;
import com.intellij.lang.ASTNode;
import com.intellij.psi.tree.TokenSet;
import com.intellij.lang.PsiParser;
import com.intellij.lang.LightPsiParser;

@SuppressWarnings({"SimplifiableIfStatement", "UnusedAssignment"})
public class AssemblyParser implements PsiParser, LightPsiParser {

  public ASTNode parse(IElementType t, PsiBuilder b) {
    parseLight(t, b);
    return b.getTreeBuilt();
  }

  public void parseLight(IElementType t, PsiBuilder b) {
    boolean r;
    b = adapt_builder_(t, b, this, null);
    Marker m = enter_section_(b, 0, _COLLAPSE_, null);
    r = parse_root_(t, b);
    exit_section_(b, 0, m, t, r, true, TRUE_CONDITION);
  }

  protected boolean parse_root_(IElementType t, PsiBuilder b) {
    return parse_root_(t, b, 0);
  }

  static boolean parse_root_(IElementType t, PsiBuilder b, int l) {
    return assemblyFile(b, l + 1);
  }

  /* ********************************************************** */
  // item_*
  static boolean assemblyFile(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "assemblyFile")) return false;
    while (true) {
      int c = current_position_(b);
      if (!item_(b, l + 1)) break;
      if (!empty_element_parsed_guard_(b, "assemblyFile", c)) break;
    }
    return true;
  }

  /* ********************************************************** */
  // MNEMONIC (operand (SEPARATOR operand)*)?
  public static boolean instruction(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "instruction")) return false;
    if (!nextTokenIs(b, MNEMONIC)) return false;
    boolean r;
    Marker m = enter_section_(b);
    r = consumeToken(b, MNEMONIC);
    r = r && instruction_1(b, l + 1);
    exit_section_(b, m, INSTRUCTION, r);
    return r;
  }

  // (operand (SEPARATOR operand)*)?
  private static boolean instruction_1(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "instruction_1")) return false;
    instruction_1_0(b, l + 1);
    return true;
  }

  // operand (SEPARATOR operand)*
  private static boolean instruction_1_0(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "instruction_1_0")) return false;
    boolean r;
    Marker m = enter_section_(b);
    r = operand(b, l + 1);
    r = r && instruction_1_0_1(b, l + 1);
    exit_section_(b, m, null, r);
    return r;
  }

  // (SEPARATOR operand)*
  private static boolean instruction_1_0_1(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "instruction_1_0_1")) return false;
    while (true) {
      int c = current_position_(b);
      if (!instruction_1_0_1_0(b, l + 1)) break;
      if (!empty_element_parsed_guard_(b, "instruction_1_0_1", c)) break;
    }
    return true;
  }

  // SEPARATOR operand
  private static boolean instruction_1_0_1_0(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "instruction_1_0_1_0")) return false;
    boolean r;
    Marker m = enter_section_(b);
    r = consumeToken(b, SEPARATOR);
    r = r && operand(b, l + 1);
    exit_section_(b, m, null, r);
    return r;
  }

  /* ********************************************************** */
  // label_definition|instruction|COMMENT|CRLF
  static boolean item_(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "item_")) return false;
    boolean r;
    r = label_definition(b, l + 1);
    if (!r) r = instruction(b, l + 1);
    if (!r) r = consumeToken(b, COMMENT);
    if (!r) r = consumeToken(b, CRLF);
    return r;
  }

  /* ********************************************************** */
  // LABEL_DEF
  public static boolean label_definition(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "label_definition")) return false;
    if (!nextTokenIs(b, LABEL_DEF)) return false;
    boolean r;
    Marker m = enter_section_(b);
    r = consumeToken(b, LABEL_DEF);
    exit_section_(b, m, LABEL_DEFINITION, r);
    return r;
  }

  /* ********************************************************** */
  // CONSTANT|LABEL|REGISTER|CONDITION|ARRAY|STRING|HL
  static boolean operand(PsiBuilder b, int l) {
    if (!recursion_guard_(b, l, "operand")) return false;
    boolean r;
    r = consumeToken(b, CONSTANT);
    if (!r) r = consumeToken(b, LABEL);
    if (!r) r = consumeToken(b, REGISTER);
    if (!r) r = consumeToken(b, CONDITION);
    if (!r) r = consumeToken(b, ARRAY);
    if (!r) r = consumeToken(b, STRING);
    if (!r) r = consumeToken(b, HL);
    return r;
  }

}
