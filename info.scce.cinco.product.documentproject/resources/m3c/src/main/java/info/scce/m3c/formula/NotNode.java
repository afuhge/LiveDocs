package info.scce.m3c.formula;

import info.scce.m3c.formula.ctl.CTLNodeVisitor;
import info.scce.m3c.formula.modalmu.MuCalcNodeVisitor;
import info.scce.m3c.formula.visitor.FormulaNodeVisitor;

public class NotNode extends UnaryFormulaNode {

    public NotNode() {

    }

    public NotNode(FormulaNode node) {
        super(node);
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
