package info.scce.m3c.formula.modalmu;

import info.scce.m3c.formula.AndNode;
import info.scce.m3c.formula.AtomicNode;
import info.scce.m3c.formula.BoxNode;
import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.FalseNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.NotNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;

public abstract class MuCalcNodeVisitor<T> {

    public T visit(FormulaNode formulaNode) {
        return formulaNode.accept(this);
    }

    public abstract T visit(GfpNode node);

    public abstract T visit(LfpNode node);

    public abstract T visit(AndNode node);

    public abstract T visit(AtomicNode node);

    public abstract T visit(BoxNode node);

    public abstract T visit(DiamondNode node);

    public abstract T visit(FalseNode node);

    public abstract T visit(NotNode node);

    public abstract T visit(OrNode node);

    public abstract T visit(TrueNode node);
}
