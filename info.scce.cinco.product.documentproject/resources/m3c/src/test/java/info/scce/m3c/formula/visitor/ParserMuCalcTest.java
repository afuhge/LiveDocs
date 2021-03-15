package info.scce.m3c.formula.visitor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;
import info.scce.m3c.formula.modalmu.LfpNode;
import info.scce.m3c.formula.modalmu.VariableNode;
import org.junit.jupiter.api.Test;

public class ParserMuCalcTest {

    @Test
    public void testParseModalMu() {
        String formula = "mu X.(<b><b>true | <>X)";
        ParserMuCalc parser = new ParserMuCalc();
        FormulaNode root = parser.parse(formula);

        assertTrue(root instanceof LfpNode);
        assertTrue(root.getLeftChild() instanceof OrNode);

        OrNode orNode = (OrNode) root.getLeftChild();
        assertTrue(orNode.getLeftChild() instanceof DiamondNode);
        assertTrue(orNode.getRightChild() instanceof DiamondNode);

        DiamondNode orLC = (DiamondNode) orNode.getLeftChild();
        DiamondNode orRC = (DiamondNode) orNode.getRightChild();

        assertEquals("b", orLC.getAction());
        assertEquals("", orRC.getAction());

        assertTrue(orLC.getLeftChild() instanceof DiamondNode);
        assertTrue(orRC.getLeftChild() instanceof VariableNode);

        DiamondNode orLCChild = (DiamondNode) orLC.getLeftChild();
        assertEquals("b", orLCChild.getAction());
        assertTrue(orLCChild.getLeftChild() instanceof TrueNode);
    }

}
