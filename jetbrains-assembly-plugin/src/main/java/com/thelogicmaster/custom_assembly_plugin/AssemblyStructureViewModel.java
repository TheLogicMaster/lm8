package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.ide.structureView.StructureViewModel;
import com.intellij.ide.structureView.StructureViewModelBase;
import com.intellij.ide.structureView.StructureViewTreeElement;
import com.intellij.ide.util.treeView.smartTree.Sorter;
import com.intellij.psi.PsiFile;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyFile;
import org.jetbrains.annotations.NotNull;

public class AssemblyStructureViewModel extends StructureViewModelBase implements StructureViewModel.ElementInfoProvider {

	public AssemblyStructureViewModel(PsiFile psiFile) {
		super(psiFile, new AssemblyStructureViewElement(psiFile));
	}

	@NotNull
	public Sorter @NotNull [] getSorters() {
		return new Sorter[]{Sorter.ALPHA_SORTER};
	}


	@Override
	public boolean isAlwaysShowsPlus(StructureViewTreeElement element) {
		return false;
	}

	@Override
	public boolean isAlwaysLeaf(StructureViewTreeElement element) {
		return element instanceof AssemblyFile;
	}
}
