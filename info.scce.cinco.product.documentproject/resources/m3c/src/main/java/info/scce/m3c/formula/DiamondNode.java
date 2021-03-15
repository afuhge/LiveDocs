package info.scce.m3c.formula;

import info.scce.m3c.formula.ctl.CTLNodeVisitor;
import info.scce.m3c.formula.modalmu.MuCalcNodeVisitor;
import info.scce.m3c.formula.visitor.FormulaNodeVisitor;

public class DiamondNode extends ModalFormulaNode {

    public DiamondNode(String action) {
        super(action);
    }

    public DiamondNode(String action, FormulaNode node) {
        super(action, node);
    }

    @Override
    public <T> T accept(FormulaNodeVisitor<T> visitor) {
        return visitor.visit(this);
    }

    @Override
    public <T> T accept(CTLNodeVisitor<T> visitor) {
        return visitor.visit(this);
    }

    @Override
    public <T> T accept(MuCalcNodeVisitor<T> visitor) {
        return visitor.visit(this);
    }

}
