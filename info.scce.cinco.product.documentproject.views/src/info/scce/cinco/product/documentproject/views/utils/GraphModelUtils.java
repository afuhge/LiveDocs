package info.scce.cinco.product.documentproject.views.utils;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.internal.resources.Container;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry;
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;
import graphmodel.GraphModel;
import graphmodel.ModelElement;

@SuppressWarnings("restriction")

public class GraphModelUtils {
	private ResourceExtension resourceHelper = new ResourceExtension();
	private String[] fileExtensions;

	public GraphModelUtils(String[] fileExtensions) {
		super();
		this.fileExtensions = fileExtensions;
	}

	public List<IResource> loadRecursive(IResource res) {
		ArrayList<IResource> contents = new ArrayList<IResource>();

		if (isModelResource(res))
			contents.add(res);

		if (res instanceof IFolder)
			try {
				contents.add(res);
				for (IResource iResource : ((Container) res).members()) {
					contents.addAll(loadRecursive(iResource));
				}
			} catch (CoreException e) {
				e.printStackTrace();
			}
		return contents;
	}

	public boolean isModelResource(IResource iResource) {
		if (iResource instanceof IFile)
			if (Arrays.asList(fileExtensions).isEmpty())
				return true;
			if (Arrays.asList(fileExtensions).contains(
					iResource.getFileExtension()))
				return true;
		return false;
	}

	public boolean hasModelResource(IContainer container) {
		List<IResource> resList = loadRecursive(container);
		for (IResource res : resList) {
			if (isModelResource(res))
				return true;
		}
		return false;
	}

	public EObject loadModel(IResource res) {
		File file = new File(res.getLocation().toOSString());
		ResourceSet resSet = new ResourceSetImpl();
		URI uri = URI.createFileURI(file.getAbsolutePath());
		
		if (uri == null)
			return null;
		
		EObject model = ReferenceRegistry.getInstance().getGraphModelFromURI(uri);
		if (model != null)
			return model;
		
		Resource resource = resSet.getResource(uri, true);
		
		model = resourceHelper.getGraphModel(resource);
		if (model != null)
			return model;
//		
//		model = resourceHelper.getContent(resource, SIBLibrary.class);
//		if (model != null)
//			return model;
//		
//		model = resourceHelper.getContent(resource, Plugins.class);
//		if (model != null)
//			return model;
		
		System.out.println("Model " + file.getName() + " not found");
		return null;
	}
	
	public void collectReferences(EObject eObj,
			HashMap<String, ArrayList<EObject>> map) {
		if (eObj instanceof GraphModel == false)
			return;

		GraphModel gModel = (GraphModel) eObj;

		TreeIterator<EObject> it = gModel.eAllContents();
		while (it.hasNext()) {
			Object obj = it.next();
			if (obj instanceof ModelElement == false)
				continue;
			ModelElement me = (ModelElement) obj;
			EStructuralFeature libCompFeature = me.eClass()
					.getEStructuralFeature("libraryComponentUID");
			if (libCompFeature != null) {
				Object val = me.eGet(libCompFeature);
				if (val != null && val instanceof String) {
					String refId = (String) val;
					if (map.get(refId) == null)
						map.put(refId, new ArrayList<EObject>());
					map.get(refId).add(me);
				}
			}
		}
	}
	
//	public GUI getGuiWrapperFromEditor(IEditorPart editorPart) {
//		Resource res = null;
//		Diagram diagram = null;
//		GUI model = null;
//
//		if (editorPart instanceof DiagramEditor) {
//			DiagramEditor deditor = (DiagramEditor) editorPart;
//			TransactionalEditingDomain ed = deditor.getEditingDomain();
//			ResourceSet rs = ed.getResourceSet();
//			res = rs.getResources().get(0);
//		}
//
//		for (EObject obj : res.getContents()) {
//			if (obj instanceof Diagram)
//				diagram = (Diagram) obj;
//			if (obj instanceof GUI)
//				model = (GUI) obj;
//		}
//
//		if (model != null && diagram != null)
//			try {
//				return model;
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		return null;
//	}
	
//	public DAD getDADWrapperFromEditor(IEditorPart editorPart) {
//		Resource res = null;
//		Diagram diagram = null;
//		DAD model = null;
//
//		if (editorPart instanceof DiagramEditor) {
//			DiagramEditor deditor = (DiagramEditor) editorPart;
//			TransactionalEditingDomain ed = deditor.getEditingDomain();
//			ResourceSet rs = ed.getResourceSet();
//			res = rs.getResources().get(0);
//		}
//
//		for (EObject obj : res.getContents()) {
//			if (obj instanceof Diagram)
//				diagram = (Diagram) obj;
//			if (obj instanceof DAD)
//				model = (DAD) obj;
//		}
//
//		if (model != null && diagram != null)
//			try {
//				return model;
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		return null;
//	}
//	
//	public Process getProcessWrapperFromEditor(IEditorPart editorPart) {
//		Resource res = null;
//		Diagram diagram = null;
//		Process model = null;
//
//		if (editorPart instanceof DiagramEditor) {
//			DiagramEditor deditor = (DiagramEditor) editorPart;
//			TransactionalEditingDomain ed = deditor.getEditingDomain();
//			ResourceSet rs = ed.getResourceSet();
//			res = rs.getResources().get(0);
//		}
//
//		for (EObject obj : res.getContents()) {
//			if (obj instanceof Diagram)
//				diagram = (Diagram) obj;
//			if (obj instanceof Process)
//				model = (Process) obj;
//		}
//
//		if (model != null && diagram != null)
//			try {
//				return model;
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		return null;
//	}
//	
//	public Data getDataWrapperFromEditor(IEditorPart editorPart) {
//		Resource res = null;
//		Diagram diagram = null;
//		Data model = null;
//
//		if (editorPart instanceof DiagramEditor) {
//			DiagramEditor deditor = (DiagramEditor) editorPart;
//			TransactionalEditingDomain ed = deditor.getEditingDomain();
//			ResourceSet rs = ed.getResourceSet();
//			res = rs.getResources().get(0);
//		}
//
//		for (EObject obj : res.getContents()) {
//			if (obj instanceof Diagram)
//				diagram = (Diagram) obj;
//			if (obj instanceof Data)
//				model = (Data) obj;
//		}
//
//		if (model != null && diagram != null)
//			try {
//				return model;
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
//		return null;
//	}
}
