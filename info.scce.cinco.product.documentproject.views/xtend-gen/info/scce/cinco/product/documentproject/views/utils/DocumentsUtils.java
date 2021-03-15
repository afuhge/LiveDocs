package info.scce.cinco.product.documentproject.views.utils;

import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency;
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.Panel;
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint;
import info.scce.cinco.product.documentproject.generator.Helper;
import info.scce.cinco.product.documentproject.template.template.Field;
import info.scce.cinco.product.documentproject.views.utils.GraphModelUtils;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;

@SuppressWarnings("all")
public class DocumentsUtils extends GraphModelUtils {
  static Helper ex = new Helper();
  
  public DocumentsUtils(final String[] fileExtensions) {
    super(fileExtensions);
  }
  
  public Iterable<Panel> getPanels(final Dependency model) {
    return DocumentsUtils.ex.getAllPanels(model);
  }
  
  public List<FieldConstraint> getFieldConstraints(final Dependency model) {
    return model.getFieldConstraints();
  }
  
  public List<FieldConstraint> getPanelsFieldConstraints(final Panel panel) {
    Dependency model = panel.getRootElement();
    ArrayList<FieldConstraint> panelfieldConstraints = new ArrayList<FieldConstraint>();
    EList<FieldConstraint> allFieldConstraints = model.getFieldConstraints();
    EObject _panel = panel.getPanel();
    info.scce.cinco.product.documentproject.template.template.Panel templPanel = ((info.scce.cinco.product.documentproject.template.template.Panel) _panel);
    EList<Field> templPanelFields = templPanel.getFields();
    for (final FieldConstraint fieldConstraint : allFieldConstraints) {
      for (final Field templPanelField : templPanelFields) {
        boolean _equals = this.getConcreteFieldConstraint(fieldConstraint).equals(templPanelField.getId());
        if (_equals) {
          panelfieldConstraints.add(fieldConstraint);
        }
      }
    }
    return panelfieldConstraints;
  }
  
  public String getConcreteFieldConstraint(final FieldConstraint constraint) {
    String _switchResult = null;
    boolean _matched = false;
    if (constraint instanceof TextFieldConstraint) {
      _matched=true;
      _switchResult = ((TextFieldConstraint) constraint).getLibraryComponentUID();
    }
    if (!_matched) {
      if (constraint instanceof NumberFieldConstraint) {
        _matched=true;
        _switchResult = ((NumberFieldConstraint) constraint).getLibraryComponentUID();
      }
    }
    if (!_matched) {
      if (constraint instanceof DateFieldConstraint) {
        _matched=true;
        _switchResult = ((DateFieldConstraint) constraint).getLibraryComponentUID();
      }
    }
    if (!_matched) {
      if (constraint instanceof CheckBoxFieldConstraint) {
        _matched=true;
        _switchResult = ((CheckBoxFieldConstraint) constraint).getLibraryComponentUID();
      }
    }
    if (!_matched) {
      if (constraint instanceof ChoiceFieldConstraint) {
        _matched=true;
        _switchResult = ((ChoiceFieldConstraint) constraint).getLibraryComponentUID();
      }
    }
    return _switchResult;
  }
}
