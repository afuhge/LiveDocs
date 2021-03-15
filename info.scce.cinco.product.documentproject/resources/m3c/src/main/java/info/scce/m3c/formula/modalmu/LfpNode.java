package info.scce.m3c.formula.modalmu;

import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.ctl.CTLNodeVisitor;
import info.scce.m3c.formula.visitor.FormulaNodeVisitor;

public class LfpNode extends FixedPointFormulaNode {

    public LfpNode(String variable) {
        super(variable);
    }

    public LfpNode(String variable, FormulaNode node) {
        super(variable, node);
    }

    public String getLabel() {
        return "Lfp.";
    }

    @Override
    public <T> T accept(FormulaNodeVisitor<T> visitor) {
        return visitor.visit(this);
    }

    @Override
    public <T> T accept(CTLNodeVisitor<T> visitor) {
        throw new UnsupportedOperationException("GfpNode represents a ModalMuFormula");
    }

    @Override
    public <T> T accept(MuCalcNodeVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
