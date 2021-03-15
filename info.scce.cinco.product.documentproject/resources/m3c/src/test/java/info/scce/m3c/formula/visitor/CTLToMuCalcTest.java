package info.scce.m3c.formula.visitor;

import static org.junit.jupiter.api.Assertions.assertEquals;

import info.scce.m3c.formula.AndNode;
import info.scce.m3c.formula.AtomicNode;
import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;
import info.scce.m3c.formula.modalmu.GfpNode;
import info.scce.m3c.formula.modalmu.LfpNode;
import info.scce.m3c.formula.modalmu.VariableNode;
import org.junit.jupiter.api.Test;

public class CTLToMuCalcTest {

    @Test
    public void testBaseCases() {
        ParserCTL ctlParser = new ParserCTL();
        CTLToMuCalc transformer = new CTLToMuCalc();

        FormulaNode atomicProp = ctlParser.parse("\"p\"");
        assertEquals(new AtomicNode("p"), transformer.toMuCalc(atomicProp));

        FormulaNode negation = ctlParser.parse("!\"p\"");
        assertEquals(negation, transformer.toMuCalc(negation));

        FormulaNode egNode = ctlParser.parse("EG \"p\"");
        GfpNode gfpNode = new GfpNode("Z0",
            new AndNode(new AtomicNode("p"), new DiamondNode("", new VariableNode("Z0"))));
        FormulaNode transformedEgNode = transformer.toMuCalc(egNode);
        assertEquals(gfpNode, transformedEgNode);

        FormulaNode euNode = ctlParser.parse("E(\"p\" U true)");
        LfpNode lfpNode = new LfpNode("Z0",
            new OrNode(new TrueNode(), new AndNode(
                new AtomicNode("p"), new DiamondNode("", new VariableNode("Z0")))));
        FormulaNode transformedEuNode = transformer.toMuCalc(euNode);
        assertEquals(lfpNode, transformedEuNode);
        //TODO: Test all cases
    }

}
