package info.scce.m3c.formula.visitor;

import static org.junit.jupiter.api.Assertions.assertEquals;

import info.scce.m3c.formula.AndNode;
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
import org.junit.jupiter.api.Test;

public class NNFVisitorTest {

    @Test
    public void testBaseCases() {
        NNFVisitor nnfVisitor = new NNFVisitor();
        ParserMuCalc parser = new ParserMuCalc();

        FormulaNode atomicNode = parser.parse("! \"a\"");
        FormulaNode nnfAtomicNode = nnfVisitor.transformToNNF(atomicNode);
        assertEquals(atomicNode, nnfAtomicNode);

        FormulaNode trueNode = parser.parse("! true");
        FormulaNode nnfTrueNode = nnfVisitor.transformToNNF(trueNode);
        assertEquals(new FalseNode(), nnfTrueNode);

        FormulaNode falseNode = parser.parse("! false");
        FormulaNode nnfFalseNode = nnfVisitor.transformToNNF(falseNode);
        assertEquals(new TrueNode(), nnfFalseNode);

        testGfp(parser);
        testLfp(parser);
        testAnd(parser);
        testOr(parser);
        testBoxNode(parser);
        testDiamondNode(parser);
        testDefaultExample(parser);
    }

    private void testGfp(ParserMuCalc parser) {
        FormulaNode gfpNode = parser.parse("! nu X.(false | X)");
        FormulaNode nnfGfpNode = gfpNode.toNNF();

        /* Create (mu X.(true & X)*/
        LfpNode lfpNode = new LfpNode("X", new AndNode(new TrueNode(), new VariableNode("X")));
        assertEquals(lfpNode, nnfGfpNode);
    }

    private void testLfp(ParserMuCalc parser) {
        FormulaNode lfpNode = parser.parse("! mu X.(false | !X)");
        FormulaNode nnfLfpNode = lfpNode.toNNF();

        /* Create nu X.(true & !X) */
        GfpNode gfpNode = new GfpNode("X",
            new AndNode(new TrueNode(), new NotNode(new VariableNode("X"))));
        assertEquals(gfpNode, nnfLfpNode);
    }

    private void testAnd(ParserMuCalc parser) {
        FormulaNode andNode = parser.parse("!(<> false & true)");
        FormulaNode nnfAndNode = andNode.toNNF();

        /* Create ([]true | false) */
        OrNode orNode = new OrNode(new BoxNode("", new TrueNode()), new FalseNode());
        assertEquals(orNode, nnfAndNode);
    }

    private void testOr(ParserMuCalc parser) {
        FormulaNode orNode = parser.parse("!([a] false | true)");
        FormulaNode nnfOrNode = orNode.toNNF();

        /* Create (<a> true & false) */
        AndNode andNode = new AndNode(new DiamondNode("a", new TrueNode()), new FalseNode());
        assertEquals(andNode, nnfOrNode);
    }

    private void testBoxNode(ParserMuCalc parser) {
        FormulaNode boxNode = parser.parse("![a]true");
        FormulaNode nnfBoxNode = boxNode.toNNF();

        /* Create (<a>false)*/
        DiamondNode diamondNode = new DiamondNode("a", new FalseNode());
        assertEquals(diamondNode, nnfBoxNode);
    }

    private void testDiamondNode(ParserMuCalc parser) {
        FormulaNode diamondNode = parser.parse("!<a>false");
        FormulaNode nnfDiamondNode = diamondNode.toNNF();

        /* Create ([a] true) */
        BoxNode boxNode = new BoxNode("a", new TrueNode());
        assertEquals(boxNode, nnfDiamondNode);
    }

    private void testDefaultExample(ParserMuCalc parser) {
        FormulaNode ast = parser.parse("!(mu X.(<b><b>true | <>X))");
        FormulaNode nnfAst = ast.toNNF();

        /* Create nu X.([b][b]false & []X)*/
        GfpNode gfpNode = new GfpNode("X",
            new AndNode(new BoxNode("b", new BoxNode("b", new FalseNode())),
                new BoxNode("", new VariableNode("X"))));
        assertEquals(gfpNode, nnfAst);
    }

}
