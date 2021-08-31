package com.thelogicmaster.custom_assembly_plugin;

import com.intellij.ide.projectView.PresentationData;
import com.intellij.ide.structureView.StructureViewTreeElement;
import com.intellij.ide.util.treeView.smartTree.SortableTreeElement;
import com.intellij.ide.util.treeView.smartTree.TreeElement;
import com.intellij.navigation.ItemPresentation;
import com.intellij.psi.NavigatablePsiElement;
import com.intellij.psi.util.PsiTreeUtil;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyFile;
import com.thelogicmaster.custom_assembly_plugin.psi.AssemblyLabelElement;
import com.thelogicmaster.custom_assembly_plugin.psi.impl.AssemblyLabelElementImpl;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

public class AssemblyStructureViewElement implements StructureViewTreeElement, SortableTreeElement {

	private final NavigatablePsiElement element;

	public AssemblyStructureViewElement(NavigatablePsiElement element) {
		this.element = element;
	}

	@Override
	public Object getValue() {
		return element;
	}

	@Override
	public void navigate(boolean requestFocus) {
		element.navigate(requestFocus);
	}

	@Override
	public boolean canNavigate() {
		return element.canNavigate();
	}

	@Override
	public boolean canNavigateToSource() {
		return element.canNavigateToSource();
	}

	@NotNull
	@Override
	public String getAlphaSortKey() {
		String name = element.getName();
		return name != null ? name : "";
	}

	@NotNull
	@Override
	public ItemPresentation getPresentation() {
		ItemPresentation presentation = element.getPresentation();
		return presentation != null ? presentation : new PresentationData();
	}

	@NotNull
	@Override
	public TreeElement @NotNull [] getChildren() {
		if (element instanceof AssemblyFile) {
			List<AssemblyLabelElement> properties = PsiTreeUtil.getChildrenOfTypeAsList(element, AssemblyLabelElement.class);
			List<TreeElement> treeElements = new ArrayList<>(properties.size());
			for (AssemblyLabelElement property : properties)
				if (property.getName() != null && !property.getName().endsWith("_"))
					treeElements.add(new AssemblyStructureViewElement((AssemblyLabelElementImpl)property));
			return treeElements.toArray(new TreeElement[0]);
		}
		return EMPTY_ARRAY;
	}
}
