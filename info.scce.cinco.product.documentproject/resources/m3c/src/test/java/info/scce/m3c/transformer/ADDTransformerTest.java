package info.scce.m3c.transformer;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import info.scce.addlib.dd.xdd.latticedd.example.BooleanVectorLogicDDManager;
import info.scce.m3c.cfps.Edge;
import info.scce.m3c.cfps.EdgeType;
import info.scce.m3c.formula.BoxNode;
import info.scce.m3c.formula.DependencyGraph;
import info.scce.m3c.formula.DiamondNode;
import info.scce.m3c.formula.EquationalBlock;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;
import info.scce.m3c.formula.visitor.ParserMuCalc;
import java.util.BitSet;
import java.util.Set;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class ADDTransformerTest {

    private static DependencyGraph dg;
    private static BooleanVectorLogicDDManager xddManager;
    private static OrNode orNode;
    private static DiamondNode diaNode1;
    private static DiamondNode diaNode2;
    private static BoxNode boxNode;
    private static TrueNode trueNode;

    @BeforeAll
    public static void setup() {
        String formula = "mu X.(<b>[b]true | <>X)";
        ParserMuCalc parser = new ParserMuCalc();
        FormulaNode ast = parser.parse(formula);
        dg = new DependencyGraph(ast);
        xddManager = new BooleanVectorLogicDDManager(dg.getNumVariables());
        orNode = (OrNode) ast.getLeftChild();
        diaNode1 = (DiamondNode) orNode.getLeftChild();
        diaNode2 = (DiamondNode) orNode.getRightChild();
        boxNode = (BoxNode) diaNode1.getLeftChild();
        trueNode = (TrueNode) boxNode.getLeftChild();
    }

    @Test
    public void testADDIdentity() {
        ADDTransformer transformer = new ADDTransformer(xddManager, dg.getNumVariables());
        double numVarCombinations = Math.pow(2, dg.getNumVariables());

        /* Check output of each possible input */
        for (int i = 0; i < numVarCombinations; i++) {

            /* Construct boolean  input vector from BitSet */
            BitSet bs = BitSet.valueOf(new long[]{i});
            boolean[] input = new boolean[dg.getNumVariables()];
            for (int idx = 0; idx < dg.getNumVariables(); idx++) {
                input[idx] = bs.get(idx);
            }

            /* Test correctness of identity by checking if input equals output */
            Set<Integer> satisfiedVars = transformer.evaluate(input);
            for (int idx = 0; i < input.length; i++) {
                if (input[idx]) {
                    assertTrue(satisfiedVars.contains(idx));
                }
                if (satisfiedVars.contains(idx)) {
                    assertTrue(input[idx]);
                }
            }
        }
    }

    @Test
    public void testBDDStateInitialization() {
        ADDTransformer transformer = new ADDTransformer(xddManager, dg);
        assertTrue(transformer.getAdd().isConstant());
        boolean[] leafData = transformer.getAdd().v().data();
        for (EquationalBlock block : dg.getBlocks()) {
            for (FormulaNode node : block.getNodes()) {
                boolean val = leafData[node.getVarNumber()];
                boolean isMaxBlock = block.isMaxBlock();
                assertEquals(isMaxBlock, val);
            }
        }
    }

    @Test
    public void testEdgeTransformerMust() {
        Edge edge = new Edge(null, null, "b", EdgeType.MUST);
        ADDTransformer transformer = new ADDTransformer(xddManager, edge, dg);
        double numVarCombinations = Math.pow(2, dg.getNumVariables());

        for (int i = 0; i < numVarCombinations; i++) {

            /* Construct boolean  input vector from BitSet */
            BitSet bs = BitSet.valueOf(new long[]{i});
            boolean[] input = new boolean[dg.getNumVariables()];
            for (int idx = 0; idx < dg.getNumVariables(); idx++) {
                input[idx] = bs.get(idx);
            }

            Set<Integer> satisfiedVars = transformer.evaluate(input);
            assertFalse(satisfiedVars.contains(orNode.getVarNumber()));

            boolean diaNode1ExpectedTrue = input[diaNode1.getVarNumberLeft()];
            boolean diaNode1ActualTrue = satisfiedVars.contains(diaNode1.getVarNumber());
            assertEquals(diaNode1ExpectedTrue, diaNode1ActualTrue);

            boolean diaNode2ExpectedTrue = input[diaNode2.getVarNumberLeft()];
            boolean diaNode2ActualTrue = satisfiedVars.contains(diaNode2.getVarNumber());
            assertEquals(diaNode2ExpectedTrue, diaNode2ActualTrue);

            boolean boxNodeExpectedTrue = input[boxNode.getVarNumberLeft()];
            boolean boxNodeActualTrue = satisfiedVars.contains(boxNode.getVarNumber());
            assertEquals(boxNodeExpectedTrue, boxNodeActualTrue);

            assertFalse(satisfiedVars.contains(trueNode.getVarNumber()));
        }
    }

    @Test
    public void testEdgeTransformerNoMatch() {
        Edge edge = new Edge(null, null, "a", EdgeType.MUST);
        ADDTransformer transformer = new ADDTransformer(xddManager, edge, dg);
        double numVarCombinations = Math.pow(2, dg.getNumVariables());
        for (int i = 0; i < numVarCombinations; i++) {

            /* Construct boolean  input vector from BitSet */
            BitSet bs = BitSet.valueOf(new long[]{i});
            boolean[] input = new boolean[dg.getNumVariables()];
            for (int idx = 0; idx < dg.getNumVariables(); idx++) {
                input[idx] = bs.get(idx);
            }

            Set<Integer> satisfiedVars = transformer.evaluate(input);
            assertFalse(satisfiedVars.contains(orNode.getVarNumber()));

            assertFalse(satisfiedVars.contains(diaNode1.getVarNumber()));

            boolean diaNode2ExpectedTrue = input[diaNode2.getVarNumberLeft()];
            boolean diaNode2ActualTrue = satisfiedVars.contains(diaNode2.getVarNumber());
            assertEquals(diaNode2ExpectedTrue, diaNode2ActualTrue);

            assertTrue(satisfiedVars.contains(boxNode.getVarNumber()));

            assertFalse(satisfiedVars.contains(trueNode.getVarNumber()));
        }
    }


    @Test
    public void testEdgeTransformerMay() {
        Edge edge = new Edge(null, null, "b", EdgeType.MAY);
        ADDTransformer transformer = new ADDTransformer(xddManager, edge, dg);
        double numVarCombinations = Math.pow(2, dg.getNumVariables());
        for (int i = 0; i < numVarCombinations; i++) {

            /* Construct boolean  input vector from BitSet */
            BitSet bs = BitSet.valueOf(new long[]{i});
            boolean[] input = new boolean[dg.getNumVariables()];
            for (int idx = 0; idx < dg.getNumVariables(); idx++) {
                input[idx] = bs.get(idx);
            }

            Set<Integer> satisfiedVars = transformer.evaluate(input);
            assertFalse(satisfiedVars.contains(orNode.getVarNumber()));

            assertFalse(satisfiedVars.contains(diaNode1.getVarNumber()));

            assertFalse(satisfiedVars.contains(diaNode2.getVarNumber()));

            boolean boxNodeExpectedTrue = input[boxNode.getVarNumberLeft()];
            boolean boxNodeActualTrue = satisfiedVars.contains(boxNode.getVarNumber());
            assertEquals(boxNodeExpectedTrue, boxNodeActualTrue);

            assertFalse(satisfiedVars.contains(trueNode.getVarNumber()));
        }
    }

    @Test
    public void testComposition() {
        ADDTransformer transformer = new ADDTransformer(xddManager, dg);
        ADDTransformer identity = new ADDTransformer(xddManager, dg.getNumVariables());
        ADDTransformer composition = transformer.compose(identity);
        assertEquals(transformer, composition);

        ADDTransformer inverseComposition = identity.compose(transformer);
        assertEquals(transformer, inverseComposition);
    }

}
