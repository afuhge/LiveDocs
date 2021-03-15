package info.scce.m3c.formula.visitor;

import info.scce.m3c.antlr.ModalMuBaseVisitor;
import info.scce.m3c.antlr.ModalMuLexer;
import info.scce.m3c.antlr.ModalMuParser;
import info.scce.m3c.antlr.ModalMuParser.AndContext;
import info.scce.m3c.antlr.ModalMuParser.AtomContext;
import info.scce.m3c.antlr.ModalMuParser.BoxContext;
import info.scce.m3c.antlr.ModalMuParser.DiamondContext;
import info.scce.m3c.antlr.ModalMuParser.EmptyBoxContext;
import info.scce.m3c.antlr.ModalMuParser.EmptyDiamondContext;
import info.scce.m3c.antlr.ModalMuParser.EquivContext;
import info.scce.m3c.antlr.ModalMuParser.FContext;
import info.scce.m3c.antlr.ModalMuParser.FalseContext;
import info.scce.m3c.antlr.ModalMuParser.GfpContext;
import info.scce.m3c.antlr.ModalMuParser.ImplContext;
import info.scce.m3c.antlr.ModalMuParser.LfpContext;
import info.scce.m3c.antlr.ModalMuParser.NotContext;
import info.scce.m3c.antlr.ModalMuParser.OrContext;
import info.scce.m3c.antlr.ModalMuParser.ParenExpContext;
import info.scce.m3c.antlr.ModalMuParser.TrueContext;
import info.scce.m3c.antlr.ModalMuParser.VarContext;
import info.scce.m3c.formula.AndNode;
import info.scce.m3c.formula.AtomicNode;
import info.scce.m3c.formula.BinaryFormulaNode;
import info.scce.m3c.formula.BoxNode;
import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.FalseNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.NotNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;
import info.scce.m3c.formula.modalmu.GfpNode;
import info.scce.m3c.formula.modalmu.LfpNode;
import info.scce.m3c.formula.modalmu.VariableNode;
import java.util.HashSet;
import java.util.Set;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

public class ParserMuCalc extends ModalMuBaseVisitor<FormulaNode> {

    private Set<String> fixedPointVars;

    //TODO: Fix Duplicate Code
    public FormulaNode parse(String modalMuFormula) {
        this.fixedPointVars = new HashSet<>();

        ANTLRInputStream inputStream = new ANTLRInputStream(modalMuFormula);
        ModalMuLexer lexer = new ModalMuLexer(inputStream);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        ModalMuParser parser = new ModalMuParser(tokens);
        return this.visit(parser.f());
    }

    @Override
    public FormulaNode visitEmptyDiamond(EmptyDiamondContext ctx) {
        return visitDiamond("", ctx.expr);
    }

    @Override
    public FormulaNode visitOr(OrContext ctx) {
        OrNode orNode = new OrNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(orNode, leftChild, rightChild);
    }

    @Override
    public FormulaNode visitVar(VarContext ctx) {
        String variable = ctx.getText();
        if (!fixedPointVars.contains(variable)) {
            throw new IllegalArgumentException(
                "Referenced variable " + variable + " is not in scope.");
        }
        VariableNode varNode = new VariableNode(variable);
        return varNode;
    }

    @Override
    public FormulaNode visitFalse(FalseContext ctx) {
        return new FalseNode();
    }

    @Override
    public FormulaNode visitEmptyBox(EmptyBoxContext ctx) {
        return visitBox("", ctx.expr);
    }

    @Override
    public FormulaNode visitBox(BoxContext ctx) {
        return visitBox(ctx.action.getText(), ctx.expr);
    }

    @Override
    public FormulaNode visitGfp(GfpContext ctx) {
        String variable = ctx.var.getText();
        checkIfVarIsAlreadyDefined(variable);
        fixedPointVars.add(variable);
        GfpNode gfpNode = new GfpNode(variable);
        FormulaNode childNode = visit(ctx.expr);
        fixedPointVars.remove(variable);
        gfpNode.setLeftChild(childNode);
        return gfpNode;
    }

    private void checkIfVarIsAlreadyDefined(String variable) {
        if (fixedPointVars.contains(variable)) {
            throw new IllegalArgumentException(
                "Input formula is not valid. The variable " + variable
                    + " is defined multiple times.");
        }
    }

    @Override
    public FormulaNode visitImpl(ImplContext ctx) {
        /* a => b == not a or b */
        OrNode orNode = new OrNode();
        NotNode leftChildNegated = new NotNode();
        leftChildNegated.setLeftChild(visit(ctx.leftChild));
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(orNode, leftChildNegated, rightChild);
    }

    @Override
    public FormulaNode visitNot(NotContext ctx) {
        NotNode notNode = new NotNode();
        FormulaNode childNode = visit(ctx.expr);
        notNode.setLeftChild(childNode);
        return notNode;
    }

    @Override
    public FormulaNode visitDiamond(DiamondContext ctx) {
        return visitDiamond(ctx.action.getText(), ctx.expr);
    }

    @Override
    public FormulaNode visitEquiv(EquivContext ctx) {
        /* a <=> b == (a => b) AND (b => a) == (not a OR b) AND (not b OR a) */
        AndNode andNode = new AndNode();

        OrNode leftOrNode = new OrNode();
        OrNode rightOrNode = new OrNode();

        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);

        NotNode leftChildNegated = new NotNode();
        leftChildNegated.setLeftChild(leftChild);

        /* Sets children of leftOrNode */
        visitBinaryNode(leftOrNode, leftChildNegated, rightChild);

        NotNode rightChildNegated = new NotNode();
        rightChildNegated.setLeftChild(rightChild);

        /* Sets children of rightOrNode */
        visitBinaryNode(rightOrNode, rightChildNegated, leftChild);

        return visitBinaryNode(andNode, leftOrNode, rightOrNode);
    }

    @Override
    public FormulaNode visitAnd(AndContext ctx) {
        AndNode andNode = new AndNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(andNode, leftChild, rightChild);
    }

    @Override
    public FormulaNode visitLfp(LfpContext ctx) {
        String variable = ctx.var.getText();
        checkIfVarIsAlreadyDefined(variable);
        fixedPointVars.add(variable);
        LfpNode lfpNode = new LfpNode(variable);
        FormulaNode childNode = visit(ctx.expr);
        fixedPointVars.remove(variable);
        lfpNode.setLeftChild(childNode);
        return lfpNode;
    }

    @Override
    public FormulaNode visitTrue(TrueContext ctx) {
        return new TrueNode();
    }

    @Override
    public FormulaNode visitParenExp(ParenExpContext ctx) {
        return visit(ctx.expr);
    }

    @Override
    public FormulaNode visitAtom(AtomContext ctx) {
        String quotedAtomicProp = ctx.getText();
        String atomicProp = quotedAtomicProp.substring(1, quotedAtomicProp.length() - 1);
        AtomicNode atomicNode = new AtomicNode(atomicProp);
        return atomicNode;

    }

    private FormulaNode visitBinaryNode(BinaryFormulaNode binaryNode, FormulaNode leftChild,
        FormulaNode rightChild) {
        binaryNode.setLeftChild(leftChild);
        binaryNode.setRightChild(rightChild);
        return binaryNode;
    }

    private FormulaNode visitDiamond(String action, FContext ctx) {
        DiamondNode diamondNode = new DiamondNode(action);
        FormulaNode childNode = visit(ctx);
        diamondNode.setLeftChild(childNode);
        return diamondNode;
    }

    private FormulaNode visitBox(String action, FContext ctx) {
        BoxNode boxNode = new BoxNode(action);
        FormulaNode childNode = visit(ctx);
        boxNode.setLeftChild(childNode);
        return boxNode;
    }
}
