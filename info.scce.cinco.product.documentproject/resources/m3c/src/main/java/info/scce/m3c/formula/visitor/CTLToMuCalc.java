package info.scce.m3c.formula.visitor;

import info.scce.m3c.formula.AndNode;
import info.scce.m3c.formula.AtomicNode;
import info.scce.m3c.formula.BoxNode;
import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.FalseNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.NotNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;
import info.scce.m3c.formula.ctl.AFNode;
import info.scce.m3c.formula.ctl.AGNode;
import info.scce.m3c.formula.ctl.AUNode;
import info.scce.m3c.formula.ctl.AWUNode;
import info.scce.m3c.formula.ctl.EFNode;
import info.scce.m3c.formula.ctl.EGNode;
import info.scce.m3c.formula.ctl.EUNode;
import info.scce.m3c.formula.ctl.EWUNode;
import info.scce.m3c.formula.modalmu.GfpNode;
import info.scce.m3c.formula.modalmu.LfpNode;
import info.scce.m3c.formula.modalmu.VariableNode;

public class CTLToMuCalc extends FormulaNodeVisitor<FormulaNode> {

    private int numFixedPointVars;

    public CTLToMuCalc() {
    }

    public FormulaNode toMuCalc(FormulaNode ctlFormula) {
        numFixedPointVars = 0;
        return visit(ctlFormula);
    }

    private String getFixedPointVar() {
        return "Z" + numFixedPointVars++;
    }

    @Override
    public FormulaNode visit(AFNode node) {
        /* AF p = !EG(!p) */
        FormulaNode p = visit(node.getLeftChild());
        NotNode notNode = new NotNode(new EGNode(new NotNode(p)));
        return visit(notNode);
    }

    @Override
    public FormulaNode visit(AGNode node) {
        /* AG p = !EF(!p) = !E[true U !p] */
        FormulaNode p = visit(node.getLeftChild());
        NotNode notNode = new NotNode(new EUNode(new TrueNode(), new NotNode(p)));
        return visit(notNode);
    }

    @Override
    public FormulaNode visit(AUNode node) {
        //TODO: Differs from GEAR?
        /* A[p U q] = !(E[!q U !(p | q)] | EG(!q)) */
        FormulaNode p = visit(node.getLeftChild());
        FormulaNode q = visit(node.getRightChild());
        EUNode euNode = new EUNode(new NotNode(q),
            new NotNode(new OrNode(p, visit(node.getRightChild()))));
        EGNode egNode = new EGNode(new NotNode(visit(node.getRightChild())));
        return visit(new AndNode(new NotNode(euNode), new NotNode(egNode)));
    }

    @Override
    public FormulaNode visit(AWUNode node) {
        /* A[p WU q] = !E[!q U (!p & !q)] */
        FormulaNode p = visit(node.getLeftChild());
        FormulaNode q = visit(node.getRightChild());
        AndNode and = new AndNode(new NotNode(p), new NotNode(q));
        EUNode ewu = new EUNode(new NotNode(visit(node.getRightChild())), and);
        return visit(new NotNode(ewu));
    }

    @Override
    public FormulaNode visit(EFNode node) {
        /* EF p = E[true U p]*/
        EUNode euNode = new EUNode(new TrueNode(), node.getLeftChild());
        return visit(euNode);
    }

    @Override
    public FormulaNode visit(EGNode node) {
        /* EG p => nu X.(toMu(p) & <>X)*/
        String fixedPointVar = getFixedPointVar();
        GfpNode gfpNode = new GfpNode(fixedPointVar);
        FormulaNode childNode = visit(node.getLeftChild());
        AndNode andNode = new AndNode(childNode,
            new DiamondNode("", new VariableNode(fixedPointVar)));
        gfpNode.setLeftChild(andNode);
        return gfpNode;
    }

    @Override
    public FormulaNode visit(EUNode node) {
        /* E[p U q] => mu X.(toMu(q) | (toMu(p) & <>X)) */
        String fixedPointVar = getFixedPointVar();
        LfpNode lfpNode = new LfpNode(fixedPointVar);
        FormulaNode p = visit(node.getLeftChild());
        FormulaNode q = visit(node.getRightChild());
        AndNode andNode = new AndNode(p,
            new DiamondNode("", new VariableNode(fixedPointVar)));
        OrNode orNode = new OrNode(q, andNode);
        lfpNode.setLeftChild(orNode);
        return lfpNode;
    }

    @Override
    public FormulaNode visit(EWUNode node) {
        /* E[p WU q] = E[p U q] | EG p */
        FormulaNode p = visit(node.getLeftChild());
        FormulaNode q = visit(node.getRightChild());
        EUNode until = new EUNode(p, q);
        EGNode egNode = new EGNode(visit(node.getLeftChild()));
        return visit(new OrNode(until, egNode));
    }

    @Override
    public FormulaNode visit(AndNode node) {
        FormulaNode leftChild = visit(node.getLeftChild());
        FormulaNode rightChild = visit(node.getRightChild());
        AndNode newAndNode = new AndNode(leftChild, rightChild);
        return newAndNode;
    }

    @Override
    public FormulaNode visit(AtomicNode node) {
        AtomicNode newAtomicNode = new AtomicNode(node.getProposition());
        return newAtomicNode;
    }

    @Override
    public FormulaNode visit(BoxNode node) {
        FormulaNode childNode = visit(node.getLeftChild());
        BoxNode newBoxNode = new BoxNode(node.getAction(), childNode);
        return newBoxNode;
    }

    @Override
    public FormulaNode visit(DiamondNode node) {
        FormulaNode childNode = visit(node.getLeftChild());
        DiamondNode newDiamondNode = new DiamondNode(node.getAction(), childNode);
        return newDiamondNode;
    }

    @Override
    public FormulaNode visit(FalseNode node) {
        return new FalseNode();
    }

    @Override
    public FormulaNode visit(NotNode node) {
        FormulaNode childNode = visit(node.getLeftChild());
        NotNode newNotNode = new NotNode(childNode);
        return newNotNode;
    }

    @Override
    public FormulaNode visit(OrNode node) {
        FormulaNode leftChild = visit(node.getLeftChild());
        FormulaNode rightChild = visit(node.getRightChild());
        OrNode newOrNode = new OrNode(leftChild, rightChild);
        return newOrNode;
    }

    @Override
    public FormulaNode visit(TrueNode node) {
        return new TrueNode();
    }

    @Override
    public FormulaNode visit(GfpNode node) {
        GfpNode newGfpNode = new GfpNode(node.getVariable(), node.getLeftChild());
        return newGfpNode;
    }

    @Override
    public FormulaNode visit(LfpNode node) {
        LfpNode newLfpNode = new LfpNode(node.getVariable(), node.getLeftChild());
        return newLfpNode;
    }

    @Override
    public FormulaNode visit(VariableNode node) {
        VariableNode newVariableNode = new VariableNode(node.getVariable());
        return newVariableNode;
    }
}
