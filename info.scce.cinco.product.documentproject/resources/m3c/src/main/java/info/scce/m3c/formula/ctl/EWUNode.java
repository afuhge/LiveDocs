package info.scce.m3c.formula.ctl;

import info.scce.m3c.formula.BinaryFormulaNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.modalmu.MuCalcNodeVisitor;
import info.scce.m3c.formula.visitor.FormulaNodeVisitor;

public class EWUNode extends BinaryFormulaNode {

    public EWUNode() {
    }

    public EWUNode(FormulaNode leftChild, FormulaNode rightChild) {
        super(leftChild, rightChild);
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
        throw new UnsupportedOperationException("EWUNode represents a CTLFormula.");
    }

}
