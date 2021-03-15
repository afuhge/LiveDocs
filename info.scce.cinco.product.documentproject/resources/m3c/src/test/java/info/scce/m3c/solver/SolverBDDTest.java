package info.scce.m3c.solver;

import info.scce.m3c.cfps.CFPS;

public class SolverBDDTest extends SolverTest {

    public SolveDD getSolver(CFPS cfps, String formula, boolean formulaIsCtl) {
        return new SolveBDD(cfps, formula, formulaIsCtl);
    }

}
