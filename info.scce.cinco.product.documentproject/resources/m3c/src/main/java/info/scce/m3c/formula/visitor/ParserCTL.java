package info.scce.m3c.formula.visitor;

import info.scce.m3c.antlr.CTLBaseVisitor;
import info.scce.m3c.antlr.CTLLexer;
import info.scce.m3c.antlr.CTLParser;
import info.scce.m3c.antlr.CTLParser.AfContext;
import info.scce.m3c.antlr.CTLParser.AgContext;
import info.scce.m3c.antlr.CTLParser.AndContext;
import info.scce.m3c.antlr.CTLParser.AtomContext;
import info.scce.m3c.antlr.CTLParser.AuContext;
import info.scce.m3c.antlr.CTLParser.AwContext;
import info.scce.m3c.antlr.CTLParser.BoxContext;
import info.scce.m3c.antlr.CTLParser.DiamondContext;
import info.scce.m3c.antlr.CTLParser.EfContext;
import info.scce.m3c.antlr.CTLParser.EgContext;
import info.scce.m3c.antlr.CTLParser.EmptyBoxContext;
import info.scce.m3c.antlr.CTLParser.EmptyDiamondContext;
import info.scce.m3c.antlr.CTLParser.EquivContext;
import info.scce.m3c.antlr.CTLParser.EuContext;
import info.scce.m3c.antlr.CTLParser.EwContext;
import info.scce.m3c.antlr.CTLParser.FContext;
import info.scce.m3c.antlr.CTLParser.FalseContext;
import info.scce.m3c.antlr.CTLParser.ImplContext;
import info.scce.m3c.antlr.CTLParser.NotContext;
import info.scce.m3c.antlr.CTLParser.OrContext;
import info.scce.m3c.antlr.CTLParser.ParenExprContext;
import info.scce.m3c.antlr.CTLParser.TrueContext;
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
import info.scce.m3c.formula.ctl.AFNode;
import info.scce.m3c.formula.ctl.AGNode;
import info.scce.m3c.formula.ctl.AUNode;
import info.scce.m3c.formula.ctl.AWUNode;
import info.scce.m3c.formula.ctl.EFNode;
import info.scce.m3c.formula.ctl.EGNode;
import info.scce.m3c.formula.ctl.EUNode;
import info.scce.m3c.formula.ctl.EWUNode;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

public class ParserCTL extends CTLBaseVisitor<FormulaNode> {

    public ParserCTL() {

    }

    public FormulaNode parse(String ctlForumla) {
        ANTLRInputStream inputStream = new ANTLRInputStream(ctlForumla);
        CTLLexer lexer = new CTLLexer(inputStream);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        CTLParser parser = new CTLParser(tokens);
        return this.visit(parser.f());
    }

    @Override
    public FormulaNode visitNot(NotContext ctx) {
        NotNode notNode = new NotNode();
        FormulaNode childNode = visit(ctx.expr);
        notNode.setLeftChild(childNode);
        return notNode;
    }

    @Override
    public FormulaNode visitEmptyDiamond(EmptyDiamondContext ctx) {
        return visitDiamond("", ctx.expr);
    }

    @Override
    public FormulaNode visitEf(EfContext ctx) {
        EFNode efNode = new EFNode();
        FormulaNode childNode = visit(ctx.expr);
        efNode.setLeftChild(childNode);
        return efNode;
    }

    @Override
    public FormulaNode visitEg(EgContext ctx) {
        EGNode egNode = new EGNode();
        FormulaNode childNode = visit(ctx.expr);
        egNode.setLeftChild(childNode);
        return egNode;
    }

    @Override
    public FormulaNode visitOr(OrContext ctx) {
        OrNode orNode = new OrNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(orNode, leftChild, rightChild);
    }

    @Override
    public FormulaNode visitAf(AfContext ctx) {
        AFNode afNode = new AFNode();
        FormulaNode childNode = visit(ctx.expr);
        afNode.setLeftChild(childNode);
        return afNode;
    }

    @Override
    public FormulaNode visitAg(AgContext ctx) {
        AGNode agNode = new AGNode();
        FormulaNode childNode = visit(ctx.expr);
        agNode.setLeftChild(childNode);
        return agNode;
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
    public FormulaNode visitParenExpr(ParenExprContext ctx) {
        return visit(ctx.expr);
    }

    @Override
    public FormulaNode visitEu(EuContext ctx) {
        EUNode euNode = new EUNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(euNode, leftChild, rightChild);
    }

    private FormulaNode visitBinaryNode(BinaryFormulaNode binaryNode, FormulaNode leftChild,
        FormulaNode rightChild) {
        binaryNode.setLeftChild(leftChild);
        binaryNode.setRightChild(rightChild);
        return binaryNode;
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
    public FormulaNode visitDiamond(DiamondContext ctx) {
        return visitDiamond(ctx.action.getText(), ctx.expr);
    }

    @Override
    public FormulaNode visitEw(EwContext ctx) {
        EWUNode ewuNode = new EWUNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(ewuNode, leftChild, rightChild);
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
    public FormulaNode visitAu(AuContext ctx) {
        AUNode auNode = new AUNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(auNode, leftChild, rightChild);
    }

    @Override
    public FormulaNode visitAw(AwContext ctx) {
        AWUNode awuNode = new AWUNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(awuNode, leftChild, rightChild);
    }

    @Override
    public FormulaNode visitAnd(AndContext ctx) {
        AndNode andNode = new AndNode();
        FormulaNode leftChild = visit(ctx.leftChild);
        FormulaNode rightChild = visit(ctx.rightChild);
        return visitBinaryNode(andNode, leftChild, rightChild);
    }

    @Override
    public FormulaNode visitTrue(TrueContext ctx) {
        return new TrueNode();
    }

    @Override
    public FormulaNode visitAtom(AtomContext ctx) {
        String quotedAtomicProp = ctx.getText();
        String atomicProp = quotedAtomicProp.substring(1, quotedAtomicProp.length() - 1);
        AtomicNode atomicNode = new AtomicNode(atomicProp);
        return atomicNode;
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
