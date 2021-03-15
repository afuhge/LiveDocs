package info.scce.m3c.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import info.scce.m3c.cfps.CFPS;
import info.scce.m3c.cfps.Edge;
import info.scce.m3c.cfps.EdgeType;
import info.scce.m3c.cfps.State;
import info.scce.m3c.cfps.StateClass;

public class TestUtil {

    public static void assertCorrectlyCreated(CFPS cfps) {
        assertEquals(1, cfps.getProcessList().size());
        assertEquals(4, cfps.getStateList().size());
        assertEquals(cfps.getMainGraph(), cfps.getProcessList().get(0));

        State start = cfps.getState("start");
        State end = cfps.getState("end");
        State s1 = cfps.getState("s1");
        State s2 = cfps.getState("s2");

        /* Assert that state start is created correctly */
        assertEquals(StateClass.START, start.getStateClass());
        assertEquals(2, start.getOutgoingEdges().size());
        if(start.getOutgoingEdges().get(0).getLabel().equals("e")) {
            Edge startToEnd = start.getOutgoingEdges().get(0);
            assertEquals(end, startToEnd.getTarget());
            assertEquals(EdgeType.MUST, startToEnd.getEdgeType());

            Edge startToS1 = start.getOutgoingEdges().get(1);
            assertEquals(s1, startToS1.getTarget());
            assertEquals(EdgeType.MUST, startToS1.getEdgeType());
            assertEquals("a", startToS1.getLabel());
        }

        /* Assert that state end is created correctly */
        assertEquals(StateClass.END, end.getStateClass());
        assertEquals(0, end.getOutgoingEdges().size());

        /* Assert that state s1 is created correctly */
        assertEquals(StateClass.NORMAL, s1.getStateClass());
        assertEquals(1, s1.getOutgoingEdges().size());
        Edge s1ToS2 = s1.getOutgoingEdges().get(0);
        assertEquals(s2, s1ToS2.getTarget());
        assertEquals("P", s1ToS2.getLabel());
        assertEquals(EdgeType.MUST_PROCESS, s1ToS2.getEdgeType());

        /* Assert that state s2 is created correctly */
        assertEquals(StateClass.NORMAL, s2.getStateClass());
        assertEquals(1, s2.getOutgoingEdges().size());
        Edge s2ToEnd = s2.getOutgoingEdges().get(0);
        assertEquals(end, s2ToEnd.getTarget());
        assertEquals("b", s2ToEnd.getLabel());
        assertEquals(EdgeType.MUST, s2ToEnd.getEdgeType());
    }
}
