package info.scce.cinco.product.documentproject.views;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;


import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarkerDelta;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.swt.widgets.Display;

import info.scce.cinco.product.documentproject.views.pages.MainPage;
import info.scce.cinco.product.documentproject.views.views.MainView;

@SuppressWarnings("rawtypes")
public class ResourceChangeListener implements IResourceChangeListener {

	public enum ListenerEvents {
		ADDED, REMOVED, CONTENT_CHANGE
	}

	private final MainView view;
	private Map<String, Set<ListenerEvents>> obsDefinition;

	private Set<ListenerEvents> events;

	public ResourceChangeListener(MainView view,
			Map<String, Set<ListenerEvents>> obsDefinition) {
		super();
		this.view = view;
		this.obsDefinition = obsDefinition;
	}

	@Override
	public void resourceChanged(IResourceChangeEvent event) {
		IResourceDelta delta = event.getDelta();
		if (delta == null)
			return;

		// Check if file extension is relevant
		IFile iFile = getFileFromDelta(delta);
		if (iFile == null
				|| !obsDefinition.keySet().contains(iFile.getFileExtension()))
			return;

		// Check if event is relevant for file extension
		getActualListenerEvents(event);
		
		Set<ListenerEvents> retainSet = new HashSet<ListenerEvents>(
				obsDefinition.get(iFile.getFileExtension()));
		retainSet.retainAll(events);
		
//		System.out.println(events);
//		System.out.println(obsDefinition.get(iFile.getFileExtension()));
//		System.out.println(retainSet);
		
		if (retainSet.size() < 1)
			return;

		// Get ProjectName
		String projectName = getProjectNameFromDelta(event.getDelta());
		// Execute refresh
		if (projectName != null) {
			Object obj = view.getPageMap().get(projectName);
			if (obj instanceof MainPage) {
				
//				System.out.println("-> refreshing " + projectName + " because of " + retainSet + " for " + iFile.getFileExtension());
				
				Display.getDefault().asyncExec(new Runnable() {
					public void run() {
						((MainPage) obj).reload();
						view.refreshView();
					}
				});
			}
		}
	}

	private String getProjectNameFromDelta(IResourceDelta delta) {
		for (IResourceDelta child : delta.getAffectedChildren()) {
			IResource res = child.getResource();
			if (res instanceof IProject)
				return ((IProject) res).getName();

			if (res instanceof IFile) {
				IFile file = (IFile) res;
				return file.getProject().getName();
			}
		}
		return null;
	}

	private void getActualListenerEvents(IResourceChangeEvent event) {
		events = new HashSet<ListenerEvents>();

//		System.out.println("------------------------------------------");
//		System.out.println("Trigger ResourceChange for " + view);

		IResource res = event.getResource();
		switch (event.getType()) {
		case IResourceChangeEvent.PRE_CLOSE:
//			System.out.print("PRE_CLOSE: Project ");
//			System.out.print(res.getFullPath());
//			System.out.println(" is about to close.");
			break;
		case IResourceChangeEvent.PRE_DELETE:
//			System.out.print("PRE_DELETE: Project ");
//			System.out.print(res.getFullPath());
//			System.out.println(" is about to be deleted.");
			break;
		case IResourceChangeEvent.POST_CHANGE:
//			System.out.println("POST_CHANGE: Resources have changed.");
			try {
				event.getDelta().accept(new DeltaPrinter());
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;
		case IResourceChangeEvent.PRE_BUILD:
//			System.out.println("PRE_BUILD: Build about to run.");
			try {
				event.getDelta().accept(new DeltaPrinter());
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;
		case IResourceChangeEvent.POST_BUILD:
//			System.out.println("POST_BUILD: Build complete.");
			try {
				event.getDelta().accept(new DeltaPrinter());
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;
		}
	}

	private IFile getFileFromDelta(IResourceDelta delta) {
		for (IResourceDelta child : delta.getAffectedChildren()) {
			IResource res = child.getResource();
			if (res instanceof IFile) {
				IFile file = (IFile) res;
				return file;
			}
			return getFileFromDelta(child);
		}
		return null;
	}

	public class DeltaPrinter implements IResourceDeltaVisitor {
		public boolean visit(IResourceDelta delta) {
			IResource res = delta.getResource();
			switch (delta.getKind()) {
			case IResourceDelta.ADDED:
//				System.out.print("Resource ");
//				System.out.print(res.getFullPath());
//				System.out.println(" was added.");
				events.add(ListenerEvents.ADDED);
				break;
			case IResourceDelta.REMOVED:
//				System.out.print("Resource ");
//				System.out.print(res.getFullPath());
//				System.out.println(" was removed.");
				events.add(ListenerEvents.REMOVED);
				break;
			case IResourceDelta.CHANGED:
//				System.out.print("Resource ");
//				System.out.print(delta.getFullPath());
//				System.out.println(" has changed.");
				int flags = delta.getFlags();
				if ((flags & IResourceDelta.CONTENT) != 0) {
					events.add(ListenerEvents.CONTENT_CHANGE);
//					System.out.println("--> Content Change");
				}
				if ((flags & IResourceDelta.REPLACED) != 0) {
//					System.out.println("--> Content Replaced");
				}
				if ((flags & IResourceDelta.MARKERS) != 0) {
//					System.out.println("--> Marker Change");
					IMarkerDelta[] markers = delta.getMarkerDeltas();
					// if interested in markers, check these deltas
				}
				break;
			}
			return true; // visit the children
		}
	}

}
