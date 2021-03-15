package info.scce.m3c.cfps;

import java.util.ArrayList;
import java.util.List;

public class ProceduralProcessGraph {

    private List<State> stateList;
    private int numberOfStates;
    private State start;
    private State end;
    private String processName;
    private CFPS cfps;

    public ProceduralProcessGraph() {
        stateList = new ArrayList<>();
        numberOfStates = 0;
    }

    public ProceduralProcessGraph(String processName) {
        this();
        this.processName = processName;
    }

    public ProceduralProcessGraph withName(String processName) {
        this.processName = processName;
        return this;
    }

    public void addState(State state) {
        if (state.isStartState()) {
            if (start != null) {
                throw new IllegalArgumentException(
                    "The ppg already has a start state and there can only be one.");
            }
            start = state;
        } else if (state.isEndState()) {
            if (end != null) {
                throw new IllegalArgumentException(
                    "The ppg already has an end state and there can only be one");
            }
            end = state;
        }
        if(cfps != null) {
            cfps.addState(state);
        }
        stateList.add(state);
        numberOfStates++;
    }

    public State getState(String name) {
        for (State state : stateList) {
            if (state.getName().equals(name)) {
                return state;
            }
        }
        return null;
    }

    public void setProcessName(String processName) {
        this.processName = processName;
    }

    public String getProcessName() {
        return processName;
    }

    public void setStartState(State startState) {
        start = startState;
    }

    public void setEndState(State endState) {
        end = endState;
    }

    public State getStartState() {
        return start;
    }

    public State getEndState() {
        return end;
    }

    public List<State> getStates() {
        return stateList;
    }

    public int getNumberOfStates() {
        return numberOfStates;
    }

    public void setCFPS(CFPS cfps) {
        this.cfps = cfps;
    }

}
