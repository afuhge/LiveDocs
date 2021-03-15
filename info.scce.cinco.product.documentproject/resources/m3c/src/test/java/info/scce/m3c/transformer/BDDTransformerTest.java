package info.scce.m3c.transformer;

import static org.junit.jupiter.api.Assertions.assertEquals;

import info.scce.addlib.dd.bdd.BDD;
import info.scce.addlib.dd.bdd.BDDManager;
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
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class BDDTransformerTest {

    private static DependencyGraph dg;
    private static BDDManager bddManager;
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
        bddManager = new BDDManager();
        orNode = (OrNode) ast.getLeftChild();
        diaNode1 = (DiamondNode) orNode.getLeftChild();
        diaNode2 = (DiamondNode) orNode.getRightChild();
        boxNode = (BoxNode) diaNode1.getLeftChild();
        trueNode = (TrueNode) boxNode.getLeftChild();
    }

    @Test
    public void testBDDIdentity() {
        BDDTransformer transformer = new BDDTransformer(bddManager, dg.getNumVariables());
        for (int var = 0; var < transformer.getBdds().length; var++) {
            assertEquals(transformer.getBdds()[var], bddManager.ithVar(var));
        }
    }

    @Test
    public void testBDDStateInitialization() {
        BDDTransformer transformer = new BDDTransformer(bddManager, dg);
        for (EquationalBlock block : dg.getBlocks()) {
            for (FormulaNode node : block.getNodes()) {
                BDD actual = transformer.getBdds()[node.getVarNumber()];
                BDD expected;
                if (block.isMaxBlock()) {
                    expected = bddManager.readOne();
                } else {
                    expected = bddManager.readLogicZero();
                }
                assertEquals(expected, actual);
            }
        }
    }

    @Test
    public void testEdgeTransformerMust() {
        Edge edge = new Edge(null, null, "b", EdgeType.MUST);
        BDDTransformer transformer = new BDDTransformer(bddManager, edge, dg);

        BDD bddOrNode = transformer.getBdds()[orNode.getVarNumber()];
        BDD expectedBDDOrNode = bddManager.readLogicZero();
        assertEquals(expectedBDDOrNode, bddOrNode);

        BDD bddDiaNode1 = transformer.getBdds()[diaNode1.getVarNumber()];
        BDD expectedBDDDiaNode1 = bddManager.ithVar(diaNode1.getVarNumberLeft());
        assertEquals(expectedBDDDiaNode1, bddDiaNode1);

        BDD bddDiaNode2 = transformer.getBdds()[diaNode2.getVarNumber()];
        BDD expectedBDDDiaNode2 = bddManager.ithVar(diaNode2.getVarNumberLeft());
        assertEquals(expectedBDDDiaNode2, bddDiaNode2);

        BDD bddBoxNode = transformer.getBdds()[boxNode.getVarNumber()];
        BDD expectedBDDBoxNode = bddManager.ithVar(boxNode.getVarNumberLeft());
        assertEquals(expectedBDDBoxNode, bddBoxNode);

        BDD bddTrueNode = transformer.getBdds()[trueNode.getVarNumber()];
        BDD expectedBDDTrueNode = bddManager.readLogicZero();
        assertEquals(expectedBDDTrueNode, bddTrueNode);
    }

    @Test
    public void testEdgeTransformerNoMatch() {
        Edge edge = new Edge(null, null, "a", EdgeType.MUST);
        BDDTransformer transformer = new BDDTransformer(bddManager, edge, dg);

        BDD bddOrNode = transformer.getBdds()[orNode.getVarNumber()];
        BDD expectedBDDOrNode = bddManager.readLogicZero();
        assertEquals(expectedBDDOrNode, bddOrNode);

        BDD bddDiaNode1 = transformer.getBdds()[diaNode1.getVarNumber()];
        BDD expectedBDDDiaNode1 = bddManager.readLogicZero();
        assertEquals(expectedBDDDiaNode1, bddDiaNode1);

        BDD bddDiaNode2 = transformer.getBdds()[diaNode2.getVarNumber()];
        BDD expectedBDDDiaNode2 = bddManager.ithVar(diaNode2.getVarNumberLeft());
        assertEquals(expectedBDDDiaNode2, bddDiaNode2);

        BDD bddBoxNode = transformer.getBdds()[boxNode.getVarNumber()];
        BDD expectedBDDBoxNode = bddManager.readOne();
        assertEquals(expectedBDDBoxNode, bddBoxNode);

        BDD bddTrueNode = transformer.getBdds()[trueNode.getVarNumber()];
        BDD expectedBDDTrueNode = bddManager.readLogicZero();
        assertEquals(expectedBDDTrueNode, bddTrueNode);
    }

    @Test
    public void testEdgeTransformerMay() {
        Edge edge = new Edge(null, null, "b", EdgeType.MAY);
        BDDTransformer transformer = new BDDTransformer(bddManager, edge, dg);

        BDD bddOrNode = transformer.getBdds()[orNode.getVarNumber()];
        BDD expectedBDDOrNode = bddManager.readLogicZero();
        assertEquals(expectedBDDOrNode, bddOrNode);

        BDD bddDiaNode1 = transformer.getBdds()[diaNode1.getVarNumber()];
        BDD expectedBDDDiaNode1 = bddManager.readLogicZero();
        assertEquals(expectedBDDDiaNode1, bddDiaNode1);

        BDD bddDiaNode2 = transformer.getBdds()[diaNode2.getVarNumber()];
        BDD expectedBDDDiaNode2 = bddManager.readLogicZero();
        assertEquals(expectedBDDDiaNode2, bddDiaNode2);

        BDD bddBoxNode = transformer.getBdds()[boxNode.getVarNumber()];
        BDD expectedBDDBoxNode = bddManager.ithVar(boxNode.getVarNumberLeft());
        assertEquals(expectedBDDBoxNode, bddBoxNode);

        BDD bddTrueNode = transformer.getBdds()[trueNode.getVarNumber()];
        BDD expectedBDDTrueNode = bddManager.readLogicZero();
        assertEquals(expectedBDDTrueNode, bddTrueNode);
    }

    @Test
    public void testComposition() {
        BDDTransformer transformer = new BDDTransformer(bddManager, dg);
        BDDTransformer identity = new BDDTransformer(bddManager, dg.getNumVariables());
        BDDTransformer composition = transformer.compose(identity);
        assertEquals(5, composition.getBdds().length);
        assertEquals(transformer, composition);

        BDDTransformer inverseComposition = identity.compose(transformer);
        assertEquals(transformer, inverseComposition);
    }

    @Test
    public void testOrBDDListOnes() {
        Edge edge = new Edge(null, null, "b", EdgeType.MUST);
        BDDTransformer edgeTransformer = new BDDTransformer(bddManager, edge, dg);

        BDDTransformer oneTransformer = new BDDTransformer(bddManager);
        oneTransformer.setIsMust(true);
        BDD[] oneBDDs = new BDD[dg.getNumVariables()];
        for (int var = 0; var < oneBDDs.length; var++) {
            oneBDDs[var] = bddManager.readOne();
        }
        oneTransformer.setBDDs(oneBDDs);

        List<BDDTransformer> comps = new ArrayList<>();
        comps.add(edgeTransformer);
        comps.add(oneTransformer);
        BDD disjunction = edgeTransformer.orBddList(comps, diaNode1.getVarNumber());
        assertEquals(bddManager.readOne(), disjunction);
    }

    @Test
    public void testOrBDDListZeros() {
        Edge edge = new Edge(null, null, "b", EdgeType.MUST);
        BDDTransformer edgeTransformer = new BDDTransformer(bddManager, edge, dg);

        BDDTransformer oneTransformer = new BDDTransformer(bddManager);
        oneTransformer.setIsMust(true);
        BDD[] oneBDDs = new BDD[dg.getNumVariables()];
        for (int var = 0; var < oneBDDs.length; var++) {
            oneBDDs[var] = bddManager.readLogicZero();
        }
        oneTransformer.setBDDs(oneBDDs);

        List<BDDTransformer> comps = new ArrayList<>();
        comps.add(edgeTransformer);
        comps.add(oneTransformer);
        BDD disjunction = edgeTransformer.orBddList(comps, diaNode1.getVarNumber());
        assertEquals(bddManager.ithVar(diaNode1.getVarNumberLeft()), disjunction);
    }
}
