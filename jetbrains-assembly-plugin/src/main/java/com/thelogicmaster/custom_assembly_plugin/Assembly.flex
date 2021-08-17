package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import com.intellij.psi.TokenType;

%%

%class AssemblyLexer
%implements FlexLexer
%unicode
%ignorecase
%function advance
%type IElementType
%eof{  return;
%eof}

CRLF=\R
LABEL=\w+
LABEL_DEF={LABEL}:
SEPARATOR=,
HEX_CONSTANT=\$[0-9a-fA-F]+
DECIMAL_CONSTANT=#\d+
CHAR_CONSTANT=\'\\?.\'
PORT_CONSTANT=\{\w+}
CONSTANTS={HEX_CONSTANT}|{DECIMAL_CONSTANT}|{CHAR_CONSTANT}|{PORT_CONSTANT}
COMMENT=;[^\r\n]*
STRING=\".*\"
ARRAY=\[\d+\]
REGISTER=[abhlABHL]
CONDITION=n?[zcnvZCNV]
DEFINITION=\w+=({CONSTANTS}|{LABEL}|{STRING}|{ARRAY}|{REGISTER}|{CONDITION})

%state ERROR OPERANDS LABELED

%%

// Reset on newline
{CRLF}                                                  { yybegin(YYINITIAL); return AssemblyTypes.CRLF; }

{COMMENT}                                               { yybegin(YYINITIAL); return AssemblyTypes.COMMENT; }

<YYINITIAL> {LABEL_DEF}                                 { yybegin(LABELED); return AssemblyTypes.LABEL_DEF; }

// Separate case to ensure one label per line
<LABELED> [a-zA-Z]+                                     { yybegin(OPERANDS); return AssemblyTypes.MNEMONIC; }

<YYINITIAL> [a-zA-Z]+                                   { yybegin(OPERANDS); return AssemblyTypes.MNEMONIC; }

<OPERANDS> {
    {SEPARATOR}                                         { return AssemblyTypes.SEPARATOR; }
    {DEFINITION}                                        { return AssemblyTypes.DEFINITION; }
    \[{CONSTANTS}\]|{CONSTANTS}                         { return AssemblyTypes.CONSTANT; }
    \[hl\]|hl                                           { return AssemblyTypes.HL; }
    {REGISTER}                                          { return AssemblyTypes.REGISTER; }
    {CONDITION}                                         { return AssemblyTypes.CONDITION; }
    {ARRAY}                                             { return AssemblyTypes.ARRAY; }
    {STRING}                                            { return AssemblyTypes.STRING; }
    \[{LABEL}\]|=?{LABEL}                               { return AssemblyTypes.LABEL; }
}

// Catch extra whitespace
[\ \t]+                                                 { return TokenType.WHITE_SPACE; }

// Anything not matched is not allowed
[^]                                                     { yybegin(ERROR); return TokenType.BAD_CHARACTER; }
