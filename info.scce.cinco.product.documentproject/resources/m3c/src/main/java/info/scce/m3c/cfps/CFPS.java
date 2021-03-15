package info.scce.m3c.cfps;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class CFPS {

    private int numberOfStates;
    private List<ProceduralProcessGraph> processList;
    private ProceduralProcessGraph mainGraph;
    private List<State> stateList;

    public CFPS() {
        numberOfStates = 0;
        stateList = new ArrayList<>();
        processList = new ArrayList<>();
    }

    public CFPS(Collection<ProceduralProcessGraph> ppgs, ProceduralProcessGraph mainPpg) {
        this();
        this.mainGraph = mainPpg;
        for (ProceduralProcessGraph ppg : ppgs) {
            addPPG(ppg);
        }
    }

    public void addPPG(ProceduralProcessGraph ppg) {
        processList.add(ppg);
        for (State state : ppg.getStates()) {
            state.setStateNumber(numberOfStates++);
            stateList.add(state);
        }
        ppg.setCFPS(this);
    }

    public State createAndAddState(ProceduralProcessGraph ppg, StateClass stateClass) {
        State state = new State(stateClass);
        state.setProceduralProcessGraph(ppg);
        ppg.addState(state);
        return state;
    }

    public void addState(ProceduralProcessGraph ppg, State state) {
        ppg.addState(state);
        state.setProceduralProcessGraph(ppg);
    }

    void addState(State state) {
        stateList.add(state);
        state.setStateNumber(numberOfStates++);
    }

    public State getState(int stateNumber) {
        return stateList.get(stateNumber);
    }

    public int getStateNumberOfProcess(String processName) {
        for (ProceduralProcessGraph ppg : processList) {
            if (ppg.getProcessName().equals(processName)) {
                return ppg.getStartState().getStateNumber();
            }
        }
        return -1;
    }

    public State getState(String name) {
        for (State state : stateList) {
            if (state.getName().equals(name)) {
                return state;
            }
        }
        return null;
    }

    public ArrayList<State> getAllEndStates() {
        ArrayList<State> list = new ArrayList<>();
        for (State state : mainGraph.getStates()) {
            if (state.getStateClass() == StateClass.END) {
                list.add(state);
            }
        }
        return list;
    }

    public List<Integer> getAllStatesWithEdgeLabel(String label) {
        List<Integer> sourceList = new ArrayList<>();
        for (ProceduralProcessGraph ppg : processList) {
            for (State state : ppg.getStates()) {
                for (Edge edge : state.getOutgoingEdges()) {
                    if (edge.getLabel().equals(label)) {
                        sourceList.add(state.getStateNumber());
                    }
                }
            }
        }
        return sourceList;
    }

    public List<State> getStatesOutgoingEdgeLabeledBy(String label) {
        List<State> sourceList = new ArrayList<>();
        for (ProceduralProcessGraph ppg : processList) {
            for (State state : ppg.getStates()) {
                for (Edge edge : state.getOutgoingEdges()) {
                    if (edge.getLabel().equals(label)) {
                        sourceList.add(state);
                        break;
                    }
                }
            }
        }
        return sourceList;
    }

    public void setMainGraph(ProceduralProcessGraph ppg) {
        this.mainGraph = ppg;
    }

    public List<State> getStateList() {
        return stateList;
    }

    public List<ProceduralProcessGraph> getProcessList() {
        return processList;
    }

    public int getNumberOfStates() {
        return numberOfStates;
    }

    public ProceduralProcessGraph getMainGraph() {
        return mainGraph;
    }

}
