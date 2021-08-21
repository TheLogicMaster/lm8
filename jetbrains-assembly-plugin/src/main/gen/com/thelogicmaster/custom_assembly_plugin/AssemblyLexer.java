/* The following code was generated by JFlex 1.7.0 tweaked for IntelliJ platform */

package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import com.intellij.psi.TokenType;


/**
 * This class is a scanner generated by 
 * <a href="http://www.jflex.de/">JFlex</a> 1.7.0
 * from the specification file <tt>Assembly.flex</tt>
 */
class AssemblyLexer implements FlexLexer {

  /** This character denotes the end of file */
  public static final int YYEOF = -1;

  /** initial size of the lookahead buffer */
  private static final int ZZ_BUFFERSIZE = 16384;

  /** lexical states */
  public static final int YYINITIAL = 0;
  public static final int ERROR = 2;
  public static final int OPERANDS = 4;
  public static final int LABELED = 6;

  /**
   * ZZ_LEXSTATE[l] is the state in the DFA for the lexical state l
   * ZZ_LEXSTATE[l+1] is the state in the DFA for the lexical state l
   *                  at the beginning of a line
   * l is of the form l = 2*k, k a non negative integer
   */
  private static final int ZZ_LEXSTATE[] = { 
     0,  0,  1,  1,  2,  2,  3, 3
  };

  /** 
   * Translates characters to character classes
   * Chosen bits are [11, 6, 4]
   * Total runtime size is 15648 bytes
   */
  public static int ZZ_CMAP(int ch) {
    return ZZ_CMAP_A[(ZZ_CMAP_Y[(ZZ_CMAP_Z[ch>>10]<<6)|((ch>>4)&0x3f)]<<4)|(ch&0xf)];
  }

  /* The ZZ_CMAP_Z table has 1088 entries */
  static final char ZZ_CMAP_Z[] = zzUnpackCMap(
    "\1\0\1\1\1\2\1\3\1\4\1\5\1\6\1\7\1\10\1\11\1\12\1\13\1\14\6\15\1\16\23\15"+
    "\1\17\1\15\1\20\1\21\12\15\1\22\10\12\1\23\1\24\1\25\1\26\1\27\1\30\1\31\1"+
    "\32\1\33\1\34\1\35\1\36\2\12\1\15\1\37\3\12\1\40\10\12\1\41\1\42\5\15\1\43"+
    "\1\44\11\12\1\45\2\12\1\46\4\12\1\47\1\50\1\51\1\12\1\52\1\12\1\53\1\54\1"+
    "\55\3\12\51\15\1\56\3\15\1\57\1\60\4\15\1\61\12\12\1\62\u02c1\12\1\63\277"+
    "\12");

  /* The ZZ_CMAP_Y table has 3328 entries */
  static final char ZZ_CMAP_Y[] = zzUnpackCMap(
    "\1\0\1\1\1\2\1\3\1\4\1\5\1\4\1\6\1\7\1\1\1\10\1\11\1\12\1\13\1\12\1\13\34"+
    "\12\1\14\1\15\1\16\1\1\7\12\1\17\1\20\1\12\1\21\4\12\1\22\10\12\1\21\12\12"+
    "\1\23\1\12\1\24\1\23\1\12\1\25\1\23\1\12\1\26\1\27\1\12\1\30\1\31\1\1\1\30"+
    "\4\12\1\32\6\12\1\33\1\34\1\35\1\1\3\12\1\36\6\12\1\15\1\37\2\12\1\40\2\12"+
    "\1\41\1\1\1\12\1\42\4\1\1\12\1\43\1\1\1\44\1\21\7\12\1\45\1\23\1\33\1\46\1"+
    "\34\1\47\1\50\1\51\1\45\1\15\1\52\1\46\1\34\1\53\1\54\1\55\1\56\1\57\1\60"+
    "\1\21\1\34\1\61\1\62\1\63\1\45\1\64\1\65\1\46\1\34\1\61\1\66\1\67\1\45\1\70"+
    "\1\71\1\72\1\73\1\74\1\75\1\76\1\56\1\1\1\77\1\100\1\34\1\101\1\102\1\103"+
    "\1\45\1\1\1\77\1\100\1\34\1\104\1\102\1\105\1\45\1\106\1\107\1\100\1\12\1"+
    "\36\1\110\1\111\1\45\1\112\1\113\1\114\1\12\1\115\1\116\1\117\1\56\1\120\1"+
    "\23\2\12\1\30\1\121\1\122\2\1\1\123\1\124\1\125\1\126\1\127\1\130\2\1\1\63"+
    "\1\131\1\122\1\132\1\133\1\12\1\134\1\23\1\135\1\133\1\12\1\134\1\136\3\1"+
    "\4\12\1\122\4\12\1\137\2\12\1\140\2\12\1\141\24\12\1\142\1\143\2\12\1\142"+
    "\2\12\1\144\1\145\1\13\3\12\1\145\3\12\1\36\2\1\1\12\1\1\5\12\1\146\1\23\45"+
    "\12\1\147\1\12\1\23\1\30\4\12\1\150\1\151\1\152\1\153\1\12\1\153\1\12\1\154"+
    "\1\152\1\155\5\12\1\156\1\122\1\1\1\157\1\122\5\12\1\25\2\12\1\30\4\12\1\57"+
    "\1\12\1\121\2\42\1\56\1\12\1\41\1\153\2\12\1\42\1\12\1\160\1\122\2\1\1\12"+
    "\1\42\3\12\1\121\1\12\1\147\2\122\1\161\1\121\4\1\4\12\1\42\1\122\1\162\1"+
    "\154\3\12\1\37\3\12\1\154\3\12\1\25\1\163\1\37\1\12\1\41\1\151\4\1\1\164\1"+
    "\12\1\165\17\12\1\166\21\12\1\146\2\12\1\146\1\167\1\12\1\41\3\12\1\170\1"+
    "\171\1\172\1\134\1\171\2\1\1\173\1\174\1\63\1\175\1\1\1\176\1\1\1\134\3\1"+
    "\2\12\1\63\1\177\1\200\1\201\1\202\1\203\1\1\2\12\1\151\62\1\1\204\2\12\1"+
    "\160\161\1\2\12\1\121\2\12\1\121\10\12\1\205\1\154\2\12\1\140\3\12\1\206\1"+
    "\174\1\12\1\207\4\210\2\12\2\1\1\174\35\1\1\211\1\1\1\23\1\212\1\23\4\12\1"+
    "\213\1\23\4\12\1\141\1\214\1\12\1\41\1\23\4\12\1\121\1\1\1\12\1\30\3\1\1\12"+
    "\40\1\133\12\1\57\4\1\135\12\1\57\2\1\10\12\1\134\4\1\2\12\1\41\20\12\1\134"+
    "\1\12\1\215\1\1\3\12\1\216\7\12\1\15\1\1\1\217\1\220\5\12\1\221\1\12\1\121"+
    "\1\25\3\1\1\217\2\12\1\25\1\1\3\12\1\154\4\12\1\57\1\122\1\12\1\222\1\37\1"+
    "\12\1\41\2\12\1\154\1\12\1\134\4\12\1\223\1\122\1\12\1\224\3\12\1\207\1\41"+
    "\1\122\1\12\1\114\4\12\1\31\1\157\1\12\1\225\1\226\1\227\1\210\2\12\1\141"+
    "\1\57\7\12\1\230\1\122\72\12\1\154\1\12\1\231\2\12\1\42\20\1\26\12\1\41\6"+
    "\12\1\160\2\1\1\207\1\232\1\34\1\233\1\234\6\12\1\15\1\1\1\235\25\12\1\41"+
    "\1\1\4\12\1\220\2\12\1\25\2\1\1\42\1\12\1\1\1\12\1\236\1\237\2\1\1\135\7\12"+
    "\1\134\1\1\1\122\1\23\1\240\1\23\1\30\1\204\4\12\1\121\1\241\1\242\2\1\1\243"+
    "\1\12\1\13\1\244\2\41\2\1\7\12\1\30\4\1\3\12\1\153\7\1\1\245\10\1\1\12\1\134"+
    "\3\12\2\63\1\1\2\12\1\1\1\12\1\30\2\12\1\30\1\12\1\41\2\12\1\246\1\247\2\1"+
    "\11\12\1\41\1\122\2\12\1\246\1\12\1\42\2\12\1\25\3\12\1\154\11\1\23\12\1\207"+
    "\1\12\1\57\1\25\11\1\1\250\2\12\1\251\1\12\1\57\1\12\1\207\1\12\1\121\4\1"+
    "\1\12\1\252\1\12\1\57\1\12\1\160\4\1\3\12\1\253\4\1\1\254\1\255\1\12\1\256"+
    "\2\1\1\12\1\134\1\12\1\134\2\1\1\133\1\12\1\207\1\1\3\12\1\57\1\12\1\57\1"+
    "\12\1\31\1\12\1\15\6\1\4\12\1\151\3\1\3\12\1\31\3\12\1\31\60\1\4\12\1\207"+
    "\1\1\1\56\1\174\3\12\1\30\1\1\1\12\1\151\1\122\3\12\1\257\1\1\2\12\1\260\4"+
    "\12\1\261\1\262\2\1\1\12\1\21\1\12\1\263\4\1\1\264\1\26\1\151\3\12\1\30\1"+
    "\122\1\33\1\46\1\34\1\61\1\66\1\265\1\266\1\153\10\1\4\12\1\30\1\122\2\1\4"+
    "\12\1\267\1\122\12\1\3\12\1\270\1\63\1\271\2\1\4\12\1\272\1\122\2\1\3\12\1"+
    "\25\1\122\3\1\1\12\1\101\1\42\1\122\26\1\4\12\1\122\1\174\34\1\3\12\1\151"+
    "\20\1\1\34\2\12\1\13\1\63\1\122\1\1\1\220\1\12\1\220\1\133\1\207\64\1\71\12"+
    "\1\160\6\1\6\12\1\121\1\1\14\12\1\154\53\1\2\12\1\121\75\1\44\12\1\207\33"+
    "\1\43\12\1\151\1\12\1\121\1\122\6\1\1\12\1\41\1\153\3\12\1\207\1\154\1\122"+
    "\1\235\1\273\1\12\67\1\4\12\1\153\2\12\1\121\1\174\1\12\4\1\1\63\1\1\76\12"+
    "\1\134\1\1\57\12\1\31\20\1\1\15\77\1\6\12\1\30\1\134\1\151\1\274\114\1\1\275"+
    "\1\276\1\277\1\1\1\300\11\1\1\301\33\1\5\12\1\135\3\12\1\152\1\302\1\303\1"+
    "\304\3\12\1\305\1\306\1\12\1\307\1\310\1\100\24\12\1\270\1\12\1\100\1\141"+
    "\1\12\1\141\1\12\1\135\1\12\1\135\1\121\1\12\1\121\1\12\1\34\1\12\1\34\1\12"+
    "\1\311\3\312\40\1\3\12\1\231\2\12\1\134\1\313\1\175\1\162\1\23\25\1\1\13\1"+
    "\221\1\314\75\1\14\12\1\153\1\207\2\1\4\12\1\30\1\122\112\1\1\304\1\12\1\315"+
    "\1\316\1\317\1\320\1\321\1\322\1\323\1\42\1\324\1\42\47\1\1\12\1\160\1\12"+
    "\1\160\1\12\1\160\47\1\55\12\1\207\2\1\103\12\1\153\15\12\1\41\150\12\1\15"+
    "\25\1\41\12\1\41\56\1\17\12\41\1");

  /* The ZZ_CMAP_A table has 3408 entries */
  static final char ZZ_CMAP_A[] = zzUnpackCMap(
    "\11\0\1\36\1\2\2\1\1\3\22\0\1\36\1\0\1\23\1\11\1\7\1\14\1\0\1\16\4\0\1\6\3"+
    "\0\2\15\10\13\1\5\1\22\1\0\1\33\3\0\2\27\1\32\3\10\1\34\1\35\3\34\1\26\1\34"+
    "\1\30\7\34\1\31\3\34\1\31\1\24\1\17\1\25\1\0\1\4\6\34\1\31\3\34\1\31\1\20"+
    "\1\0\1\21\7\0\1\1\24\0\1\4\12\0\1\4\4\0\1\4\5\0\27\4\1\0\12\4\4\0\14\4\16"+
    "\0\5\4\7\0\1\4\1\0\1\4\1\0\5\4\1\0\2\4\2\0\4\4\1\0\1\4\6\0\1\4\1\0\3\4\1\0"+
    "\1\4\1\0\4\4\1\0\23\4\1\0\11\4\1\0\26\4\2\0\1\4\6\0\10\4\10\0\16\4\1\0\1\4"+
    "\1\0\2\4\1\0\2\4\1\0\1\4\10\0\13\4\5\0\3\4\15\0\12\12\4\0\6\4\1\0\10\4\2\0"+
    "\12\4\1\0\6\4\12\12\3\4\2\0\14\4\2\0\3\4\12\12\14\4\4\0\1\4\5\0\16\4\2\0\14"+
    "\4\4\0\5\4\1\0\10\4\6\0\20\4\2\0\12\12\1\4\2\0\16\4\1\0\1\4\3\0\4\4\2\0\11"+
    "\4\2\0\2\4\2\0\4\4\10\0\1\4\4\0\2\4\1\0\1\4\1\0\3\4\1\0\6\4\4\0\2\4\1\0\2"+
    "\4\1\0\2\4\1\0\2\4\2\0\1\4\1\0\5\4\4\0\2\4\2\0\3\4\3\0\1\4\7\0\4\4\1\0\1\4"+
    "\7\0\12\12\6\4\13\0\3\4\1\0\11\4\1\0\2\4\1\0\2\4\1\0\5\4\2\0\12\4\1\0\3\4"+
    "\1\0\3\4\2\0\1\4\30\0\1\4\7\0\3\4\1\0\10\4\2\0\6\4\2\0\2\4\2\0\3\4\10\0\2"+
    "\4\4\0\2\4\1\0\1\4\1\0\1\4\20\0\2\4\1\0\6\4\3\0\3\4\1\0\4\4\3\0\2\4\1\0\1"+
    "\4\1\0\2\4\3\0\2\4\3\0\3\4\3\0\14\4\4\0\5\4\3\0\3\4\1\0\4\4\2\0\1\4\6\0\1"+
    "\4\10\0\4\4\1\0\10\4\1\0\3\4\1\0\30\4\3\0\10\4\1\0\3\4\1\0\4\4\7\0\2\4\1\0"+
    "\3\4\5\0\4\4\1\0\5\4\2\0\4\4\5\0\2\4\7\0\1\4\2\0\2\4\16\0\3\4\1\0\10\4\1\0"+
    "\7\4\1\0\3\4\1\0\5\4\5\0\4\4\7\0\1\4\12\0\6\4\2\0\2\4\1\0\22\4\3\0\10\4\1"+
    "\0\11\4\1\0\1\4\2\0\7\4\3\0\1\4\4\0\6\4\1\0\1\4\1\0\10\4\2\0\2\4\14\0\17\4"+
    "\1\0\12\12\7\0\2\4\1\0\1\4\2\0\2\4\1\0\1\4\2\0\1\4\6\0\4\4\1\0\7\4\1\0\3\4"+
    "\1\0\1\4\1\0\1\4\2\0\2\4\1\0\15\4\1\0\3\4\2\0\5\4\1\0\1\4\1\0\6\4\2\0\12\12"+
    "\2\0\4\4\10\0\2\4\13\0\1\4\1\0\1\4\1\0\1\4\4\0\12\4\1\0\24\4\3\0\5\4\1\0\12"+
    "\4\6\0\1\4\11\0\12\12\4\4\2\0\6\4\1\0\1\4\5\0\1\4\2\0\13\4\1\0\15\4\1\0\4"+
    "\4\2\0\7\4\1\0\1\4\1\0\4\4\2\0\1\4\1\0\4\4\2\0\7\4\1\0\1\4\1\0\4\4\2\0\16"+
    "\4\2\0\6\4\2\0\15\4\2\0\14\4\3\0\13\4\7\0\15\4\1\0\7\4\13\0\4\4\14\0\1\4\1"+
    "\0\2\4\14\0\4\4\3\0\1\4\4\0\2\4\15\0\3\4\2\0\12\4\15\0\1\4\23\0\5\4\12\12"+
    "\3\0\6\4\1\0\23\4\1\0\2\4\6\0\6\4\5\0\15\4\1\0\1\4\1\0\1\4\1\0\1\4\1\0\6\4"+
    "\1\0\7\4\1\0\1\4\3\0\3\4\1\0\7\4\3\0\4\4\2\0\6\4\14\0\2\1\25\0\1\4\4\0\1\4"+
    "\14\0\1\4\15\0\1\4\2\0\1\4\4\0\1\4\2\0\12\4\1\0\1\4\3\0\5\4\6\0\1\4\1\0\1"+
    "\4\1\0\1\4\1\0\4\4\1\0\13\4\2\0\4\4\5\0\5\4\4\0\1\4\7\0\17\4\6\0\15\4\7\0"+
    "\10\4\11\0\7\4\1\0\7\4\6\0\3\4\11\0\5\4\2\0\5\4\3\0\7\4\2\0\2\4\2\0\3\4\5"+
    "\0\13\4\12\12\2\4\4\0\3\4\1\0\12\4\1\0\1\4\7\0\11\4\2\0\27\4\2\0\15\4\3\0"+
    "\1\4\1\0\1\4\2\0\1\4\16\0\1\4\12\12\5\4\3\0\5\4\12\0\6\4\2\0\6\4\2\0\6\4\11"+
    "\0\13\4\1\0\2\4\2\0\7\4\4\0\5\4\3\0\5\4\5\0\12\4\1\0\5\4\1\0\1\4\1\0\2\4\1"+
    "\0\2\4\1\0\12\4\3\0\15\4\3\0\2\4\30\0\16\4\4\0\1\4\2\0\6\4\2\0\6\4\2\0\6\4"+
    "\2\0\3\4\3\0\14\4\1\0\16\4\1\0\2\4\1\0\1\4\15\0\1\4\2\0\4\4\4\0\10\4\1\0\5"+
    "\4\12\0\6\4\2\0\1\4\1\0\14\4\1\0\2\4\3\0\1\4\2\0\4\4\1\0\2\4\12\0\10\4\6\0"+
    "\6\4\1\0\2\4\5\0\10\4\1\0\3\4\1\0\13\4\4\0\3\4\4\0\6\4\1\0\12\12\4\4\2\0\1"+
    "\4\11\0\5\4\5\0\3\4\3\0\12\12\1\4\1\0\1\4\3\0\10\4\6\0\1\4\1\0\7\4\1\0\1\4"+
    "\1\0\4\4\1\0\2\4\6\0\1\4\5\0\7\4\2\0\7\4\3\0\6\4\1\0\1\4\10\0\6\4\2\0\10\4"+
    "\10\0\6\4\2\0\1\4\3\0\1\4\13\0\10\4\5\0\15\4\3\0\2\4\6\0\5\4\3\0\6\4\10\0"+
    "\10\4\2\0\7\4\16\0\4\4\4\0\3\4\15\0\1\4\2\0\2\4\2\0\4\4\1\0\14\4\1\0\1\4\1"+
    "\0\7\4\1\0\21\4\1\0\4\4\2\0\10\4\1\0\7\4\1\0\14\4\1\0\4\4\1\0\5\4\1\0\1\4"+
    "\3\0\11\4\1\0\10\4\2\0\22\12\5\0\1\4\12\0\2\4\1\0\2\4\1\0\5\4\6\0\2\4\1\0"+
    "\1\4\2\0\1\4\1\0\12\4\1\0\4\4\1\0\1\4\1\0\1\4\6\0\1\4\4\0\1\4\1\0\1\4\1\0"+
    "\1\4\1\0\3\4\1\0\2\4\1\0\1\4\2\0\1\4\1\0\1\4\1\0\1\4\1\0\1\4\1\0\1\4\1\0\2"+
    "\4\1\0\1\4\2\0\4\4\1\0\7\4\1\0\4\4\1\0\4\4\1\0\1\4\1\0\12\4\1\0\5\4\1\0\3"+
    "\4\1\0\5\4\1\0\5\4");

  /** 
   * Translates DFA states to action switch labels.
   */
  private static final int [] ZZ_ACTION = zzUnpackAction();

  private static final String ZZ_ACTION_PACKED_0 =
    "\4\0\1\1\2\2\1\1\1\3\1\4\1\5\1\6"+
    "\1\7\7\1\1\10\2\11\1\1\1\10\1\3\1\0"+
    "\1\12\1\0\3\13\4\0\1\14\10\0\1\6\1\15"+
    "\1\16\7\0\2\13\1\6\2\0\1\17\5\0\3\16"+
    "\3\0\1\16\3\0\1\15\2\16";

  private static int [] zzUnpackAction() {
    int [] result = new int[79];
    int offset = 0;
    offset = zzUnpackAction(ZZ_ACTION_PACKED_0, offset, result);
    return result;
  }

  private static int zzUnpackAction(String packed, int offset, int [] result) {
    int i = 0;       /* index in packed string  */
    int j = offset;  /* index in unpacked array */
    int l = packed.length();
    while (i < l) {
      int count = packed.charAt(i++);
      int value = packed.charAt(i++);
      do result[j++] = value; while (--count > 0);
    }
    return j;
  }


  /** 
   * Translates a state to a row index in the transition table
   */
  private static final int [] ZZ_ROWMAP = zzUnpackRowMap();

  private static final String ZZ_ROWMAP_PACKED_0 =
    "\0\0\0\37\0\76\0\135\0\174\0\174\0\233\0\272"+
    "\0\331\0\370\0\u0117\0\u0136\0\174\0\u0155\0\u0174\0\u0193"+
    "\0\u01b2\0\u01d1\0\u01f0\0\u020f\0\u0136\0\u022e\0\u0136\0\u024d"+
    "\0\u026c\0\u028b\0\272\0\174\0\u02aa\0\u0155\0\u0174\0\u0193"+
    "\0\u02c9\0\u02e8\0\u0307\0\u01f0\0\u01f0\0\u0326\0\u0345\0\u0364"+
    "\0\u0383\0\u03a2\0\u03c1\0\u03e0\0\u03ff\0\u024d\0\u0136\0\u041e"+
    "\0\u043d\0\u045c\0\u047b\0\u049a\0\u04b9\0\u04d8\0\u04f7\0\174"+
    "\0\u02c9\0\174\0\u0516\0\u0535\0\174\0\u0554\0\u0573\0\u0592"+
    "\0\u05b1\0\u05d0\0\u043d\0\u045c\0\u047b\0\u05ef\0\u060e\0\u062d"+
    "\0\u04d8\0\u064c\0\u066b\0\u068a\0\174\0\174\0\u05ef";

  private static int [] zzUnpackRowMap() {
    int [] result = new int[79];
    int offset = 0;
    offset = zzUnpackRowMap(ZZ_ROWMAP_PACKED_0, offset, result);
    return result;
  }

  private static int zzUnpackRowMap(String packed, int offset, int [] result) {
    int i = 0;  /* index in packed string  */
    int j = offset;  /* index in unpacked array */
    int l = packed.length();
    while (i < l) {
      int high = packed.charAt(i++) << 16;
      result[j++] = high | packed.charAt(i++);
    }
    return j;
  }

  /** 
   * The transition table of the DFA
   */
  private static final int [] ZZ_TRANS = zzUnpackTrans();

  private static final String ZZ_TRANS_PACKED_0 =
    "\1\5\2\6\1\7\1\10\3\5\1\11\1\5\2\10"+
    "\1\5\1\10\4\5\1\12\3\5\5\11\1\5\2\11"+
    "\1\13\1\5\2\6\1\7\16\5\1\12\13\5\1\13"+
    "\1\5\2\6\1\7\1\14\1\5\1\15\1\16\1\14"+
    "\1\17\2\14\1\20\1\14\1\21\1\5\1\22\1\5"+
    "\1\12\1\23\1\24\1\5\2\25\1\26\2\27\1\30"+
    "\1\14\1\31\1\13\1\5\2\6\1\7\4\5\1\32"+
    "\11\5\1\12\3\5\5\32\1\5\2\32\1\13\41\0"+
    "\1\6\40\0\1\33\1\34\2\0\1\33\1\0\2\33"+
    "\1\0\1\33\10\0\5\33\1\0\2\33\5\0\1\33"+
    "\1\34\2\0\1\11\1\0\2\33\1\0\1\33\10\0"+
    "\5\11\1\0\2\11\1\0\2\12\2\0\33\12\36\0"+
    "\1\13\4\0\1\14\3\0\1\14\1\0\2\14\1\0"+
    "\1\14\10\0\5\14\1\35\2\14\11\0\1\36\2\0"+
    "\1\36\1\0\1\36\11\0\1\36\2\0\1\36\16\0"+
    "\2\37\1\0\1\37\36\0\1\40\21\0\1\41\3\0"+
    "\13\41\1\42\17\41\4\0\1\43\3\0\1\43\1\0"+
    "\2\43\1\0\1\43\10\0\5\43\1\0\2\43\1\0"+
    "\1\44\3\0\17\44\1\45\13\44\4\0\1\46\2\0"+
    "\1\47\1\46\1\50\2\51\1\52\1\51\1\53\1\0"+
    "\1\54\5\0\5\46\1\0\1\46\1\55\5\0\1\14"+
    "\3\0\1\14\1\0\2\14\1\0\1\14\10\0\2\14"+
    "\3\27\1\35\2\14\5\0\1\56\3\0\1\56\1\0"+
    "\2\56\1\0\1\56\10\0\5\56\1\0\2\56\5\0"+
    "\1\14\3\0\1\14\1\0\2\14\1\0\1\14\10\0"+
    "\1\57\4\14\1\35\2\14\11\0\1\32\15\0\5\32"+
    "\1\0\2\32\5\0\1\60\2\0\1\61\1\60\1\62"+
    "\2\60\1\63\1\60\1\64\1\0\1\65\2\0\1\66"+
    "\1\67\1\0\5\60\1\0\2\60\17\0\1\70\20\0"+
    "\1\41\3\0\12\41\1\71\20\41\4\0\1\43\3\0"+
    "\1\43\1\0\2\43\1\0\1\43\3\0\1\70\4\0"+
    "\5\43\1\0\2\43\5\0\1\46\3\0\1\46\1\0"+
    "\2\46\1\0\1\46\7\0\1\72\5\46\1\0\2\46"+
    "\11\0\1\73\2\0\1\73\1\0\1\73\11\0\1\73"+
    "\2\0\1\73\16\0\2\74\1\0\1\74\25\0\1\46"+
    "\3\0\1\46\1\0\2\51\1\0\1\51\7\0\1\75"+
    "\5\46\1\0\2\46\16\0\1\76\21\0\1\77\3\0"+
    "\13\77\1\100\17\77\4\0\1\101\3\0\1\101\1\0"+
    "\2\101\1\0\1\101\10\0\5\101\1\0\2\101\5\0"+
    "\1\46\3\0\1\46\1\0\2\46\1\0\1\46\7\0"+
    "\1\72\1\102\4\46\1\0\2\46\5\0\1\60\3\0"+
    "\1\60\1\0\2\60\1\0\1\60\10\0\5\60\1\0"+
    "\2\60\11\0\1\103\2\0\1\103\1\0\1\103\11\0"+
    "\1\103\2\0\1\103\16\0\2\104\1\0\1\104\36\0"+
    "\1\105\21\0\1\106\3\0\13\106\1\107\17\106\4\0"+
    "\1\110\3\0\1\110\1\0\2\110\1\0\1\110\10\0"+
    "\5\110\1\0\2\110\1\0\1\66\3\0\17\66\1\111"+
    "\13\66\12\0\2\112\1\0\1\112\31\0\1\73\2\0"+
    "\1\73\1\0\1\73\7\0\1\70\1\0\1\73\2\0"+
    "\1\73\16\0\2\74\1\0\1\74\7\0\1\70\26\0"+
    "\1\76\7\0\1\70\27\0\1\113\20\0\1\77\3\0"+
    "\12\77\1\114\20\77\4\0\1\101\3\0\1\101\1\0"+
    "\2\101\1\0\1\101\3\0\1\113\4\0\5\101\1\0"+
    "\2\101\5\0\1\46\3\0\1\46\1\0\2\46\1\0"+
    "\1\46\7\0\1\115\5\46\1\0\2\46\17\0\1\116"+
    "\20\0\1\106\3\0\12\106\1\117\20\106\4\0\1\110"+
    "\3\0\1\110\1\0\2\110\1\0\1\110\3\0\1\116"+
    "\4\0\5\110\1\0\2\110\13\0\2\112\1\0\1\112"+
    "\7\0\1\116\36\0\1\70\27\0\1\113\6\0\1\70"+
    "\11\0";

  private static int [] zzUnpackTrans() {
    int [] result = new int[1705];
    int offset = 0;
    offset = zzUnpackTrans(ZZ_TRANS_PACKED_0, offset, result);
    return result;
  }

  private static int zzUnpackTrans(String packed, int offset, int [] result) {
    int i = 0;       /* index in packed string  */
    int j = offset;  /* index in unpacked array */
    int l = packed.length();
    while (i < l) {
      int count = packed.charAt(i++);
      int value = packed.charAt(i++);
      value--;
      do result[j++] = value; while (--count > 0);
    }
    return j;
  }


  /* error codes */
  private static final int ZZ_UNKNOWN_ERROR = 0;
  private static final int ZZ_NO_MATCH = 1;
  private static final int ZZ_PUSHBACK_2BIG = 2;

  /* error messages for the codes above */
  private static final String[] ZZ_ERROR_MSG = {
    "Unknown internal scanner error",
    "Error: could not match input",
    "Error: pushback value was too large"
  };

  /**
   * ZZ_ATTRIBUTE[aState] contains the attributes of state <code>aState</code>
   */
  private static final int [] ZZ_ATTRIBUTE = zzUnpackAttribute();

  private static final String ZZ_ATTRIBUTE_PACKED_0 =
    "\4\0\2\11\6\1\1\11\15\1\1\0\1\11\1\0"+
    "\3\1\4\0\1\1\10\0\3\1\7\0\1\11\1\1"+
    "\1\11\2\0\1\11\5\0\3\1\3\0\1\1\3\0"+
    "\2\11\1\1";

  private static int [] zzUnpackAttribute() {
    int [] result = new int[79];
    int offset = 0;
    offset = zzUnpackAttribute(ZZ_ATTRIBUTE_PACKED_0, offset, result);
    return result;
  }

  private static int zzUnpackAttribute(String packed, int offset, int [] result) {
    int i = 0;       /* index in packed string  */
    int j = offset;  /* index in unpacked array */
    int l = packed.length();
    while (i < l) {
      int count = packed.charAt(i++);
      int value = packed.charAt(i++);
      do result[j++] = value; while (--count > 0);
    }
    return j;
  }

  /** the input device */
  private java.io.Reader zzReader;

  /** the current state of the DFA */
  private int zzState;

  /** the current lexical state */
  private int zzLexicalState = YYINITIAL;

  /** this buffer contains the current text to be matched and is
      the source of the yytext() string */
  private CharSequence zzBuffer = "";

  /** the textposition at the last accepting state */
  private int zzMarkedPos;

  /** the current text position in the buffer */
  private int zzCurrentPos;

  /** startRead marks the beginning of the yytext() string in the buffer */
  private int zzStartRead;

  /** endRead marks the last character in the buffer, that has been read
      from input */
  private int zzEndRead;

  /**
   * zzAtBOL == true <=> the scanner is currently at the beginning of a line
   */
  private boolean zzAtBOL = true;

  /** zzAtEOF == true <=> the scanner is at the EOF */
  private boolean zzAtEOF;

  /** denotes if the user-EOF-code has already been executed */
  private boolean zzEOFDone;


  /**
   * Creates a new scanner
   *
   * @param   in  the java.io.Reader to read input from.
   */
  AssemblyLexer(java.io.Reader in) {
    this.zzReader = in;
  }


  /** 
   * Unpacks the compressed character translation table.
   *
   * @param packed   the packed character translation table
   * @return         the unpacked character translation table
   */
  private static char [] zzUnpackCMap(String packed) {
    int size = 0;
    for (int i = 0, length = packed.length(); i < length; i += 2) {
      size += packed.charAt(i);
    }
    char[] map = new char[size];
    int i = 0;  /* index in packed string  */
    int j = 0;  /* index in unpacked array */
    while (i < packed.length()) {
      int  count = packed.charAt(i++);
      char value = packed.charAt(i++);
      do map[j++] = value; while (--count > 0);
    }
    return map;
  }

  public final int getTokenStart() {
    return zzStartRead;
  }

  public final int getTokenEnd() {
    return getTokenStart() + yylength();
  }

  public void reset(CharSequence buffer, int start, int end, int initialState) {
    zzBuffer = buffer;
    zzCurrentPos = zzMarkedPos = zzStartRead = start;
    zzAtEOF  = false;
    zzAtBOL = true;
    zzEndRead = end;
    yybegin(initialState);
  }

  /**
   * Refills the input buffer.
   *
   * @return      {@code false}, iff there was new input.
   *
   * @exception   java.io.IOException  if any I/O-Error occurs
   */
  private boolean zzRefill() throws java.io.IOException {
    return true;
  }


  /**
   * Returns the current lexical state.
   */
  public final int yystate() {
    return zzLexicalState;
  }


  /**
   * Enters a new lexical state
   *
   * @param newState the new lexical state
   */
  public final void yybegin(int newState) {
    zzLexicalState = newState;
  }


  /**
   * Returns the text matched by the current regular expression.
   */
  public final CharSequence yytext() {
    return zzBuffer.subSequence(zzStartRead, zzMarkedPos);
  }


  /**
   * Returns the character at position {@code pos} from the
   * matched text.
   *
   * It is equivalent to yytext().charAt(pos), but faster
   *
   * @param pos the position of the character to fetch.
   *            A value from 0 to yylength()-1.
   *
   * @return the character at position pos
   */
  public final char yycharat(int pos) {
    return zzBuffer.charAt(zzStartRead+pos);
  }


  /**
   * Returns the length of the matched text region.
   */
  public final int yylength() {
    return zzMarkedPos-zzStartRead;
  }


  /**
   * Reports an error that occurred while scanning.
   *
   * In a wellformed scanner (no or only correct usage of
   * yypushback(int) and a match-all fallback rule) this method
   * will only be called with things that "Can't Possibly Happen".
   * If this method is called, something is seriously wrong
   * (e.g. a JFlex bug producing a faulty scanner etc.).
   *
   * Usual syntax/scanner level error handling should be done
   * in error fallback rules.
   *
   * @param   errorCode  the code of the errormessage to display
   */
  private void zzScanError(int errorCode) {
    String message;
    try {
      message = ZZ_ERROR_MSG[errorCode];
    }
    catch (ArrayIndexOutOfBoundsException e) {
      message = ZZ_ERROR_MSG[ZZ_UNKNOWN_ERROR];
    }

    throw new Error(message);
  }


  /**
   * Pushes the specified amount of characters back into the input stream.
   *
   * They will be read again by then next call of the scanning method
   *
   * @param number  the number of characters to be read again.
   *                This number must not be greater than yylength()!
   */
  public void yypushback(int number)  {
    if ( number > yylength() )
      zzScanError(ZZ_PUSHBACK_2BIG);

    zzMarkedPos -= number;
  }


  /**
   * Contains user EOF-code, which will be executed exactly once,
   * when the end of file is reached
   */
  private void zzDoEOF() {
    if (!zzEOFDone) {
      zzEOFDone = true;
    
    }
  }


  /**
   * Resumes scanning until the next regular expression is matched,
   * the end of input is encountered or an I/O-Error occurs.
   *
   * @return      the next token
   * @exception   java.io.IOException  if any I/O-Error occurs
   */
  public IElementType advance() throws java.io.IOException {
    int zzInput;
    int zzAction;

    // cached fields:
    int zzCurrentPosL;
    int zzMarkedPosL;
    int zzEndReadL = zzEndRead;
    CharSequence zzBufferL = zzBuffer;

    int [] zzTransL = ZZ_TRANS;
    int [] zzRowMapL = ZZ_ROWMAP;
    int [] zzAttrL = ZZ_ATTRIBUTE;

    while (true) {
      zzMarkedPosL = zzMarkedPos;

      zzAction = -1;

      zzCurrentPosL = zzCurrentPos = zzStartRead = zzMarkedPosL;

      zzState = ZZ_LEXSTATE[zzLexicalState];

      // set up zzAction for empty match case:
      int zzAttributes = zzAttrL[zzState];
      if ( (zzAttributes & 1) == 1 ) {
        zzAction = zzState;
      }


      zzForAction: {
        while (true) {

          if (zzCurrentPosL < zzEndReadL) {
            zzInput = Character.codePointAt(zzBufferL, zzCurrentPosL/*, zzEndReadL*/);
            zzCurrentPosL += Character.charCount(zzInput);
          }
          else if (zzAtEOF) {
            zzInput = YYEOF;
            break zzForAction;
          }
          else {
            // store back cached positions
            zzCurrentPos  = zzCurrentPosL;
            zzMarkedPos   = zzMarkedPosL;
            boolean eof = zzRefill();
            // get translated positions and possibly new buffer
            zzCurrentPosL  = zzCurrentPos;
            zzMarkedPosL   = zzMarkedPos;
            zzBufferL      = zzBuffer;
            zzEndReadL     = zzEndRead;
            if (eof) {
              zzInput = YYEOF;
              break zzForAction;
            }
            else {
              zzInput = Character.codePointAt(zzBufferL, zzCurrentPosL/*, zzEndReadL*/);
              zzCurrentPosL += Character.charCount(zzInput);
            }
          }
          int zzNext = zzTransL[ zzRowMapL[zzState] + ZZ_CMAP(zzInput) ];
          if (zzNext == -1) break zzForAction;
          zzState = zzNext;

          zzAttributes = zzAttrL[zzState];
          if ( (zzAttributes & 1) == 1 ) {
            zzAction = zzState;
            zzMarkedPosL = zzCurrentPosL;
            if ( (zzAttributes & 8) == 8 ) break zzForAction;
          }

        }
      }

      // store back cached position
      zzMarkedPos = zzMarkedPosL;

      if (zzInput == YYEOF && zzStartRead == zzCurrentPos) {
        zzAtEOF = true;
        zzDoEOF();
        return null;
      }
      else {
        switch (zzAction < 0 ? zzAction : ZZ_ACTION[zzAction]) {
          case 1: 
            { yybegin(ERROR); return TokenType.BAD_CHARACTER;
            } 
            // fall through
          case 16: break;
          case 2: 
            { yybegin(YYINITIAL); return AssemblyTypes.CRLF;
            } 
            // fall through
          case 17: break;
          case 3: 
            { yybegin(OPERANDS); return AssemblyTypes.MNEMONIC;
            } 
            // fall through
          case 18: break;
          case 4: 
            { yybegin(YYINITIAL); return AssemblyTypes.COMMENT;
            } 
            // fall through
          case 19: break;
          case 5: 
            { return TokenType.WHITE_SPACE;
            } 
            // fall through
          case 20: break;
          case 6: 
            { return AssemblyTypes.LABEL;
            } 
            // fall through
          case 21: break;
          case 7: 
            { return AssemblyTypes.SEPARATOR;
            } 
            // fall through
          case 22: break;
          case 8: 
            { return AssemblyTypes.REGISTER;
            } 
            // fall through
          case 23: break;
          case 9: 
            { return AssemblyTypes.CONDITION;
            } 
            // fall through
          case 24: break;
          case 10: 
            { yybegin(LABELED); return AssemblyTypes.LABEL_DEF;
            } 
            // fall through
          case 25: break;
          case 11: 
            { return AssemblyTypes.CONSTANT;
            } 
            // fall through
          case 26: break;
          case 12: 
            { return AssemblyTypes.STRING;
            } 
            // fall through
          case 27: break;
          case 13: 
            { return AssemblyTypes.HL;
            } 
            // fall through
          case 28: break;
          case 14: 
            { return AssemblyTypes.DEFINITION;
            } 
            // fall through
          case 29: break;
          case 15: 
            { return AssemblyTypes.ARRAY;
            } 
            // fall through
          case 30: break;
          default:
            zzScanError(ZZ_NO_MATCH);
          }
      }
    }
  }


}
