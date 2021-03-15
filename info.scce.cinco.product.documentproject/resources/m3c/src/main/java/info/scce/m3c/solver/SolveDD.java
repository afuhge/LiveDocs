package info.scce.m3c.solver;

import info.scce.m3c.cfps.CFPS;
import info.scce.m3c.cfps.Edge;
import info.scce.m3c.cfps.ProceduralProcessGraph;
import info.scce.m3c.cfps.State;
import info.scce.m3c.formula.AndNode;
import info.scce.m3c.formula.AtomicNode;
import info.scce.m3c.formula.BoxNode;
import info.scce.m3c.formula.DependencyGraph;
import info.scce.m3c.formula.EquationalBlock;
import info.scce.m3c.formula.FormulaNode;
import info.scce.m3c.formula.NotNode;
import info.scce.m3c.formula.OrNode;
import info.scce.m3c.formula.TrueNode;
import info.scce.m3c.formula.visitor.CTLToMuCalc;
import info.scce.m3c.formula.visitor.ParserCTL;
import info.scce.m3c.formula.visitor.ParserMuCalc;
import info.scce.m3c.transformer.PropertyTransformer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public abstract class SolveDD<T extends PropertyTransformer> {

    protected CFPS cfps;
    private FormulaNode ast;
    protected DependencyGraph dependGraph;
    protected int currentBlockIndex;

    // Property transformer for every state
    protected PropertyTransformer[] propTransformers;

    // For each act \in Actions there is a property Transformer
    private Map<String, PropertyTransformer> mustTransformers;
    private Map<String, PropertyTransformer> mayTransformers;

    // Keeps track of which state's property transformers have to be updated
    private Set<State> workSet;

    private int blockCounter = 0;

    public SolveDD(CFPS cfps, String formula, boolean formulaIsCtl) {
        this.cfps = cfps;
        if (formulaIsCtl) {
            ParserCTL parser = new ParserCTL();
            FormulaNode ctlFormula = parser.parse(formula);
            this.ast = ctlToMuCalc(ctlFormula);
        } else {
            ParserMuCalc parser = new ParserMuCalc();
            this.ast = parser.parse(formula);
        }
        this.ast = this.ast.toNNF();
    }

    public SolveDD(CFPS cfps, FormulaNode formula, boolean formulaIsCtl) {
        this.cfps = cfps;
        if (formulaIsCtl) {
            this.ast = ctlToMuCalc(formula);
        } else {
            this.ast = formula;
        }
        this.ast = this.ast.toNNF();
    }

    protected abstract void initDDManager();

    protected abstract PropertyTransformer createInitTransformerEnd();

    protected abstract PropertyTransformer createInitState();

    protected abstract PropertyTransformer createInitTransformerEdge(Edge edge);

    public abstract void updateState(State state);

    public abstract List<T> createCompositions(State state);

    public void solve() {
        checkCFPS();
        initialize();
        while (!workSet.isEmpty()) {
            State nextState = workSet.iterator().next();
            updateState(nextState);
        }
    }

    private void checkCFPS() {
        if (cfps.getMainGraph() == null) {
            throw new IllegalArgumentException("The cfps must have an assigned main graph");
        }
        for (ProceduralProcessGraph ppg : cfps.getProcessList()) {
            String ppgName = ppg.getProcessName();
            if (ppg.getStartState() == null) {
                throw new IllegalArgumentException("PPG " + ppgName + " has no start state");
            }
            if (ppg.getEndState() == null) {
                throw new IllegalArgumentException("PPG " + ppgName + " has no end state");
            }
        }
    }

    public boolean isSat() {
        ProceduralProcessGraph mainPPG = cfps.getMainGraph();
        State startState = mainPPG.getStartState();
        List<FormulaNode> satisfiedFormulas = getSatisfiedSubformulas(startState);
        for (FormulaNode node : satisfiedFormulas) {
            if (node.getVarNumber() == 0) {
                return true;
            }
        }
        return false;
    }

    private boolean[] toBoolArray(Set<Integer> satisfiedVars) {
        boolean[] arr = new boolean[dependGraph.getNumVariables()];
        for (Integer satisfiedVar : satisfiedVars) {
            arr[satisfiedVar] = true;
        }
        return arr;
    }

    public void initialize() {
        this.workSet = new LinkedHashSet<>();
        this.dependGraph = new DependencyGraph(ast);
        this.propTransformers = new PropertyTransformer[cfps.getStateList().size()];
        this.currentBlockIndex = dependGraph.getBlocks().size() - 1;
        this.mustTransformers = new HashMap<>();
        this.mayTransformers = new HashMap<>();
        initDDManager();
        fillWorkList();
        initTransformers();
    }

    protected void fillWorkList() {
        for (ProceduralProcessGraph ppg : cfps.getProcessList()) {
            for (State state : ppg.getStates()) {
                if (!state.isEndState()) {
                    workSet.add(state);
                }
            }
        }
    }

    protected void initTransformers() {
        for (int stateNumber = 0; stateNumber < cfps.getStateList().size(); stateNumber++) {
            State state = cfps.getState(stateNumber);
            if (state.isEndState()) {
                propTransformers[stateNumber] = createInitTransformerEnd();
            } else {
                propTransformers[stateNumber] = createInitState();
            }
        }
    }

    protected void updateTransformerAndWorkSet(State state, int stateNumber,
        PropertyTransformer stateTransformer, PropertyTransformer updatedTransformer) {
        if (!stateTransformer.equals(updatedTransformer)) {
            propTransformers[stateNumber] = updatedTransformer;
            updateWorkSet(state);
        }
        if (workSet.isEmpty() && (currentBlockIndex > 0)) {
            currentBlockIndex--;
            fillWorkList();
        }
    }

    protected void updateWorkSet(State updatedState) {
        if (updatedState.isStartState()) {
            String label = updatedState.getProceduralProcessGraph().getProcessName();
            workSet.addAll(cfps.getStatesOutgoingEdgeLabeledBy(label));
            workSet.addAll(updatedState.getPredecessors());
        } else {
            workSet.addAll(updatedState.getPredecessors());
        }
    }

    protected void initUpdate(State state) {
        if (state.isEndState()) {
            throw new IllegalArgumentException("End State must not be updated!");
        }
        workSet.remove(state);
    }

    public PropertyTransformer getEdgeTransformer(Edge edge) {
        PropertyTransformer edgeTransformer;
        if (edge.isProcessCall()) {
            int stateNumberOfProcess = cfps.getStateNumberOfProcess(edge.getLabel());
            edgeTransformer = propTransformers[stateNumberOfProcess];
        } else {
            if (edge.isMust()) {
                if (mustTransformers.containsKey(edge.getLabel())) {
                    edgeTransformer = mustTransformers.get(edge.getLabel());
                } else {
                    edgeTransformer = createInitTransformerEdge(edge);
                    mustTransformers.put(edge.getLabel(), edgeTransformer);
                }
            } else {
                if (mayTransformers.containsKey(edge.getLabel())) {
                    edgeTransformer = mayTransformers.get(edge.getLabel());
                } else {
                    edgeTransformer = createInitTransformerEdge(edge);
                    mayTransformers.put(edge.getLabel(), edgeTransformer);
                }
            }
        }
        return edgeTransformer;
    }

    public List<FormulaNode> getSatisfiedSubformulas(State state) {
        Set<Integer> output = propTransformers[state.getStateNumber()]
            .evaluate(toBoolArray(getAllAPDeadlockedState()));
        List<FormulaNode> satisfiedSubFormulas = new ArrayList<>();
        for (FormulaNode node : dependGraph.getFormulaNodes()) {
            if (output.contains(node.getVarNumber())) {
                satisfiedSubFormulas.add(node);
            }
        }
        return satisfiedSubFormulas;
    }

    protected static FormulaNode ctlToMuCalc(FormulaNode ctlFormula) {
        CTLToMuCalc transformation = new CTLToMuCalc();
        return transformation.toMuCalc(ctlFormula);
    }

    public Set<Integer> getAllAPDeadlockedState() {
        State endState = cfps.getMainGraph().getEndState();
        Set<Integer> satisfiedVariables = new HashSet<>();

        for (int blockIdx = dependGraph.getBlocks().size() - 1; blockIdx >= 0; blockIdx--) {
            EquationalBlock block = dependGraph.getBlock(blockIdx);
            for (FormulaNode node : block.getNodes()) {
                if (node instanceof TrueNode) {
                    satisfiedVariables.add(node.getVarNumber());
                } else if (node instanceof AtomicNode) {
                    String atomicProposition = ((AtomicNode) node).getProposition();
                    if (endState.satisfiesAtomicProposition(atomicProposition)) {
                        satisfiedVariables.add(node.getVarNumber());
                    }
                } else if (node instanceof BoxNode) {
                    /* End State has no outgoing edges */
                    satisfiedVariables.add(node.getVarNumber());
                } else if (node instanceof AndNode) {
                    if (satisfiedVariables.contains(node.getVarNumberLeft()) && satisfiedVariables
                        .contains(node.getVarNumberRight())) {
                        satisfiedVariables.add(node.getVarNumber());
                    }
                } else if (node instanceof OrNode) {
                    if (satisfiedVariables.contains(node.getVarNumberLeft()) || satisfiedVariables
                        .contains(node.getVarNumberRight())) {
                        satisfiedVariables.add(node.getVarNumber());
                    }
                } else if (node instanceof NotNode) {
                    if (!satisfiedVariables.contains(node.getVarNumberLeft())) {
                        satisfiedVariables.add(node.getVarNumber());
                    }
                }
            }
        }
        return satisfiedVariables;
    }

    public Set<State> getWorkSet() {
        return workSet;
    }

    public DependencyGraph getDependGraph() {
        return dependGraph;
    }

    public CFPS getCfps() {
        return cfps;
    }

    public PropertyTransformer[] getPropertyTransformers() {
        return propTransformers;
    }

    public Map<String, PropertyTransformer> getMustTransformers() {
        return mustTransformers;
    }

    public Map<String, PropertyTransformer> getMayTransformers() {
        return mayTransformers;
    }

    public int getBlockCounter() {
        return blockCounter;
    }

}
