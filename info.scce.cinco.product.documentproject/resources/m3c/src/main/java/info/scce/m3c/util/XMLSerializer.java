package info.scce.m3c.util;

import info.scce.m3c.cfps.CFPS;
import info.scce.m3c.cfps.Edge;
import info.scce.m3c.cfps.ProceduralProcessGraph;
import info.scce.m3c.cfps.State;

public class XMLSerializer {

    private CFPS cfps;

    public XMLSerializer(CFPS cfps) {
        this.cfps = cfps;
    }

    public String serialize() {
        StringBuilder output = new StringBuilder("<cfps>\n");
        for (ProceduralProcessGraph ppg : cfps.getProcessList()) {
            output.append(serializePPG(ppg));
        }
        output.append("</cfps>");
        return output.toString();
    }

    public String serializePPG(ProceduralProcessGraph ppg) {
        StringBuilder output = new StringBuilder("\t<ppg>\n");
        boolean isMain = cfps.getMainGraph().equals(ppg);
        output.append("\t\t<isMain>").append(isMain).append("</isMain>\n");
        output.append("\t\t<name>").append(ppg.getProcessName()).append("</name>\n");
        output.append("\t\t<states>\n");
        for (State state : ppg.getStates()) {
            output.append(serializeState(state));
        }

        output.append("\t\t<edges>\n");
        for(State state : ppg.getStates()) {
            for(Edge edge : state.getOutgoingEdges()) {
                output.append(serializeEdge(edge));
            }
        }
        output.append("\t\t</edges>\n");
        output.append("\t\t</states>\n");
        output.append("\t</ppg>\n");
        return output.toString();
    }

    public String serializeState(State state) {
        String output = "\t\t\t<state>\n";
        output += "\t\t\t\t<id>" + state.getStateNumber() + "</id>\n";
        output += "\t\t\t\t<name>" + state.getName() + "</name>\n";
        String stateClass = state.getStateClass().name().toLowerCase();
        output += "\t\t\t\t<stateClass>" + stateClass + "</stateClass>\n";
        String stateLabels = String.join(",", state.getStateLabels());
        output += "\t\t\t\t<stateLabels>" + stateLabels + "</stateLabels>\n";
        output += "\t\t\t</state>\n";
        return output;
    }

    public String serializeEdge(Edge edge) {
        String output = "\t\t\t<edge>\n";
        output += "\t\t\t\t<sourceId>" + edge.getSource().getStateNumber() + "</sourceId>\n";
        output += "\t\t\t\t<targetId>" + edge.getTarget().getStateNumber() + "</targetId>\n";
        output += "\t\t\t\t<label>" + edge.getLabel() + "</label>\n";
        output += "\t\t\t\t<isMust>" + edge.isMust() + "</isMust>\n";
        output += "\t\t\t\t<isProcessCall>" + edge.isProcessCall() + "</isProcessCall>\n";
        output += "\t\t\t</edge>\n";
        return output;
    }

}
