package info.scce.m3c.formula.ctl;

import info.scce.m3c.formula.AndNode;
import info.scce.m3c.formula.AtomicNode;
import info.scce.m3c.formula.BoxNode;
import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.FalseNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.NotNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;

public abstract class CTLNodeVisitor<T> {

    public T visit(FormulaNode node) {
        return node.accept(this);
    }

    public abstract T visit(AFNode node);

    public abstract T visit(AGNode node);

    public abstract T visit(AUNode node);

    public abstract T visit(AWUNode node);

    public abstract T visit(EFNode node);

    public abstract T visit(EGNode node);

    public abstract T visit(EUNode node);

    public abstract T visit(EWUNode node);

    public abstract T visit(AndNode node);

    public abstract T visit(AtomicNode node);

    public abstract T visit(BoxNode node);

    public abstract T visit(DiamondNode node);

    public abstract T visit(FalseNode node);

    public abstract T visit(NotNode node);

    public abstract T visit(OrNode node);

    public abstract T visit(TrueNode node);

}
