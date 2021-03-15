package info.scce.m3c.util;

import info.scce.m3c.cfps.CFPS;
import info.scce.m3c.cfps.Edge;
import info.scce.m3c.cfps.EdgeType;
import info.scce.m3c.cfps.ProceduralProcessGraph;
import info.scce.m3c.cfps.State;
import info.scce.m3c.cfps.StateClass;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class XMLDeserializer {

    private Map<String, State> idToState;
    private CFPS cfps;
    private Element root;

    public XMLDeserializer(File xmlFile) {
        try {
            this.root = getRoot(new FileInputStream(xmlFile));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    public XMLDeserializer(String xmlInput) {
        this.root = getRoot(new ByteArrayInputStream(xmlInput.getBytes()));
    }

    public CFPS deserialize() {
        idToState = new HashMap<>();
        cfps = new CFPS();

        NodeList ppgs = root.getElementsByTagName("ppg");
        for (int i = 0; i < ppgs.getLength(); i++) {
            Element ppg = (Element) ppgs.item(i);
            addPPG(ppg);
        }

        return cfps;
    }

    private void addPPG(Element elemPPG) {
        String isMainString = elemPPG.getElementsByTagName("isMain").item(0).getTextContent();
        boolean isMain = false;
        if (isMainString.equals("true")) {
            isMain = true;
        } else if (!isMainString.equals("false")) {
            throw new IllegalArgumentException("isMain must be either \"true\" or \"false\"");
        }
        String ppgName = elemPPG.getElementsByTagName("name").item(0).getTextContent();

        ProceduralProcessGraph ppg = new ProceduralProcessGraph(ppgName);
        cfps.addPPG(ppg);
        if (isMain) {
            cfps.setMainGraph(ppg);
        }

        Element statesElement = (Element) elemPPG.getElementsByTagName("states").item(0);
        NodeList states = statesElement.getElementsByTagName("state");
        for (int i = 0; i < states.getLength(); i++) {
            Element state = (Element) states.item(i);
            addState(ppg, state);
        }

        Element transitionsElement = (Element) root.getElementsByTagName("edges").item(0);
        NodeList transitions = transitionsElement.getElementsByTagName("edge");
        for (int i = 0; i < transitions.getLength(); i++) {
            Element transition = (Element) transitions.item(i);
            addEdge(transition);
        }
    }

    private void addState(ProceduralProcessGraph ppg, Element elemState) {
        String stateId = elemState.getElementsByTagName("id").item(0).getTextContent();
        String stateName = elemState.getElementsByTagName("name").item(0).getTextContent();
        String stateClassString = elemState.getElementsByTagName("stateClass").item(0)
            .getTextContent();
        String stateLabelsString = elemState.getElementsByTagName("stateLabels").item(0)
            .getTextContent();
        StateClass stateClass;
        switch (stateClassString) {
            case "start":
                stateClass = StateClass.START;
                break;
            case "normal":
                stateClass = StateClass.NORMAL;
                break;
            case "end":
                stateClass = StateClass.END;
                break;
            default:
                throw new IllegalArgumentException(
                    "stateClass must be \"start\", \"normal\" or \"end\"");
        }
        State state = new State(stateClass).withName(stateName).withStateLabels(stateLabelsString);
        idToState.put(stateId, state);
        cfps.addState(ppg, state);
    }

    private void addEdge(Element elemEdge) {
        String sourceId = elemEdge.getElementsByTagName("sourceId").item(0).getTextContent();
        String targetId = elemEdge.getElementsByTagName("targetId").item(0).getTextContent();
        String label = elemEdge.getElementsByTagName("label").item(0).getTextContent();
        String isMustString = elemEdge.getElementsByTagName("isMust").item(0).getTextContent();
        String isProcessCallString = elemEdge.getElementsByTagName("isProcessCall").item(0)
            .getTextContent();

        boolean isMust = false;
        if (isMustString.equals("true")) {
            isMust = true;
        } else if (!isMustString.equals("false")) {
            throw new IllegalArgumentException("isMust must either be \"true\" or \"false\"");
        }

        boolean isProcessCall = false;
        if (isProcessCallString.equals("true")) {
            isProcessCall = true;
        } else if (!isProcessCallString.equals("false")) {
            throw new IllegalArgumentException(
                "isProcessCall must either be \"true\" or \"false\"");
        }

        EdgeType edgeType;
        if (isMust) {
            if (isProcessCall) {
                edgeType = EdgeType.MUST_PROCESS;
            } else {
                edgeType = EdgeType.MUST;
            }
        } else {
            if (isProcessCall) {
                edgeType = EdgeType.MAY_PROCESS;
            } else {
                edgeType = EdgeType.MAY;
            }
        }

        State sourceState = idToState.get(sourceId);
        State targetState = idToState.get(targetId);
        Edge edge = new Edge(sourceState, targetState, label, edgeType);
        sourceState.addEdge(edge);
    }

    private Element getRoot(InputStream inputFile) {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(inputFile);
            Element root = document.getDocumentElement();
            return root;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
