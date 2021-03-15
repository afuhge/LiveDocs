package info.scce.m3c.formula;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import info.scce.m3c.formula.DependencyGraph;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.visitor.ParserMuCalc;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

public class DependencyGraphTest {

    @Test
    public void testDependencyGraph() {
        String formula = "mu X.(<b><b>true | <>X)";
        ParserMuCalc parser = new ParserMuCalc();
        FormulaNode ast = parser.parse(formula);
        DependencyGraph dg = new DependencyGraph(ast);

        /* Assert that number of variables are correct */
        assertEquals(5, dg.getFormulaNodes().size());
        assertEquals(dg.getFormulaNodes().size(), dg.getNumVariables());
        assertTrue(checkVarNumbering(dg.getFormulaNodes()));

        /* Assert that blocks are created correctly*/
        assertEquals(1, dg.getBlocks().size());
        assertEquals(5, dg.getBlocks().get(0).getNodes().size());
        assertTrue(isMonotonicallyDecreasing(dg.getBlocks().get(0).getNodes()));

    }

    private boolean checkVarNumbering(List<FormulaNode> nodes) {
        int numVars = nodes.size();
        Set<Integer> vars = new HashSet<>();
        for (int i = 0; i < numVars; i++) {
            vars.add(i);
        }
        for (FormulaNode node : nodes) {
            vars.remove(node.getVarNumber());
        }
        return vars.isEmpty();
    }

    private boolean isMonotonicallyDecreasing(List<FormulaNode> nodes) {
        /* Checks if nodes are sorted such that dependencies between nodes are respected */
        for (int i = 0; i < nodes.size() - 1; i++) {
            if (nodes.get(i).getVarNumber() < nodes.get(i + 1).getVarNumber()) {
                return false;
            }
        }
        return true;
    }
}
