package info.scce.m3c.solver;

import info.scce.addlib.dd.bdd.BDDManager;
import info.scce.m3c.cfps.CFPS;
import info.scce.m3c.cfps.Edge;
import info.scce.m3c.cfps.State;
import info.scce.m3c.formula.EquationalBlock;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.transformer.BDDTransformer;
import info.scce.m3c.transformer.PropertyTransformer;
import java.util.ArrayList;
import java.util.List;

public class SolveBDD extends SolveDD<BDDTransformer> {

    private BDDManager bddManager;

    public SolveBDD(CFPS cfps, String formula, boolean formulaIsCtl) {
        super(cfps, formula, formulaIsCtl);
    }

    public SolveBDD(CFPS cfps, FormulaNode formula, boolean formulaIsCtl) {
        super(cfps, formula, formulaIsCtl);
    }

    public void updateState(State state) {
        initUpdate(state);
        int stateNumber = state.getStateNumber();
        BDDTransformer stateTransformer = (BDDTransformer) propTransformers[stateNumber];
        PropertyTransformer updatedTransformer = getUpdatedPropertyTransformer(state,
            stateTransformer);
        updateTransformerAndWorkSet(state, stateNumber, stateTransformer, updatedTransformer);
    }

    private PropertyTransformer getUpdatedPropertyTransformer(State state,
        BDDTransformer stateTransformer) {
        List<BDDTransformer> compositions = createCompositions(state);
        EquationalBlock currentBlock = dependGraph.getBlock(currentBlockIndex);
        return stateTransformer.createUpdate(state, compositions, currentBlock);
    }

    public List<BDDTransformer> createCompositions(State state) {
        List<BDDTransformer> compositions = new ArrayList<>();
        for (Edge edge : state.getOutgoingEdges()) {
            State targetState = cfps.getState(edge.getTarget().getStateNumber());
            PropertyTransformer edgeTransformer = getEdgeTransformer(edge);
            PropertyTransformer succTransformer = propTransformers[targetState.getStateNumber()];
            BDDTransformer composition = (BDDTransformer) edgeTransformer.compose(succTransformer);
            composition.setIsMust(edge.isMust());
            compositions.add(composition);
        }
        return compositions;
    }

    @Override
    protected void initDDManager() {
        this.bddManager = new BDDManager();
    }

    @Override
    protected PropertyTransformer createInitTransformerEnd() {
        int numVariables = dependGraph.getNumVariables();
        return new BDDTransformer(bddManager, numVariables);
    }

    @Override
    protected PropertyTransformer createInitState() {
        return new BDDTransformer(bddManager, dependGraph);
    }

    @Override
    protected PropertyTransformer createInitTransformerEdge(Edge edge) {
        return new BDDTransformer(bddManager, edge, dependGraph);
    }

}
