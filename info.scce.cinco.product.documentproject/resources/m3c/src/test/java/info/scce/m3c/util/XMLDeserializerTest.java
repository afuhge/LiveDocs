package info.scce.m3c.util;

import static info.scce.m3c.util.TestUtil.assertCorrectlyCreated;

import info.scce.m3c.cfps.CFPS;
import java.io.File;
import org.junit.jupiter.api.Test;

public class XMLDeserializerTest {

    @Test
    public void testPaperExample() {
        String pathToFile = "src/test/resources/example_models/paper_model.xml";
        XMLDeserializer deserializer = new XMLDeserializer(new File(pathToFile));
        CFPS cfps = deserializer.deserialize();
        assertCorrectlyCreated(cfps);
    }

    @Test
    public void testSerialization() {
        String pathToFile = "src/test/resources/example_models/paper_model.xml";
        XMLDeserializer deserializer = new XMLDeserializer(new File(pathToFile));
        CFPS cfps = deserializer.deserialize();
        XMLSerializer serializer = new XMLSerializer(cfps);
        String cfpsAsString = serializer.serialize();
        deserializer = new XMLDeserializer(cfpsAsString);
        cfps = deserializer.deserialize();
        assertCorrectlyCreated(cfps);
    }

}
