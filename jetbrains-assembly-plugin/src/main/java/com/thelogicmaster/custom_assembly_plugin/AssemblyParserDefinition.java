package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.lang.ASTNode;
import com.intellij.lang.ParserDefinition;
import com.intellij.lang.PsiParser;
import com.intellij.lexer.Lexer;
import com.intellij.openapi.project.Project;
import com.intellij.psi.FileViewProvider;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiFile;
import com.intellij.psi.TokenType;
import com.intellij.psi.tree.IFileElementType;
import com.intellij.psi.tree.TokenSet;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyFile;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyTypes;
import org.jetbrains.annotations.NotNull;

public class AssemblyParserDefinition implements ParserDefinition {

	public static final TokenSet WHITE_SPACES = TokenSet.create(TokenType.WHITE_SPACE);
	public static final TokenSet COMMENTS = TokenSet.create(AssemblyTypes.COMMENT);

	public static final IFileElementType FILE = new IFileElementType(AssemblyLanguage.INSTANCE);

	@NotNull
	@Override
	public Lexer createLexer(Project project) {
		return new AssemblyLexerAdaptor();
	}

	@NotNull
	@Override
	public TokenSet getWhitespaceTokens() {
		return WHITE_SPACES;
	}

	@NotNull
	@Override
	public TokenSet getCommentTokens() {
		return COMMENTS;
	}

	@NotNull
	@Override
	public TokenSet getStringLiteralElements() {
		return TokenSet.EMPTY;
	}

	@NotNull
	@Override
	public PsiParser createParser(final Project project) {
		return new AssemblyParser();
	}

	@Override
	public @NotNull IFileElementType getFileNodeType() {
		return FILE;
	}

	@Override
	public @NotNull PsiFile createFile(@NotNull FileViewProvider viewProvider) {
		return new AssemblyFile(viewProvider);
	}

	@Override
	public @NotNull SpaceRequirements spaceExistenceTypeBetweenTokens(ASTNode left, ASTNode right) {
		return SpaceRequirements.MAY;
	}

	@NotNull
	@Override
	public PsiElement createElement(ASTNode node) {
		return AssemblyTypes.Factory.createElement(node);
	}
}
