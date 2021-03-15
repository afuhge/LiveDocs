package info.scce.cinco.product.documentproject.views.utils;


import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.swt.custom.BusyIndicator;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.wizards.IWizardDescriptor;

public class MainUtils {

	public static Display getDisplay() {
		Display display = Display.getCurrent();
		// may be null if outside the UI thread
		if (display == null)
			display = Display.getDefault();
		return display;
	}

	public static IWizard getWizard(String id) {
		// First see if this is a "new wizard".
		IWizardDescriptor descriptor = PlatformUI.getWorkbench()
				.getNewWizardRegistry().findWizard(id);
		// If not check if it is an "import wizard".
		if (descriptor == null) {
			descriptor = PlatformUI.getWorkbench().getImportWizardRegistry()
					.findWizard(id);
		}
		// Or maybe an export wizard
		if (descriptor == null) {
			descriptor = PlatformUI.getWorkbench().getExportWizardRegistry()
					.findWizard(id);
		}
		try {
			// Then if we have a wizard, open it.
			if (descriptor != null) {
				IWizard wizard = descriptor.createWizard();
				return wizard;
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public static void runBusy(Runnable runnable){
		BusyIndicator.showWhile(MainUtils.getDisplay(), runnable);
	}
	
}
