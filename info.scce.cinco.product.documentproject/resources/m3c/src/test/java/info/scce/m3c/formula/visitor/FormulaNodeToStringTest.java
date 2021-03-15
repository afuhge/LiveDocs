package info.scce.m3c.formula.visitor;

import static org.junit.jupiter.api.Assertions.assertEquals;

import info.scce.m3c.formula.FormulaNode;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class FormulaNodeToStringTest {

    private static ParserCTL ctlParser;
    private static ParserMuCalc muCalcParser;

    @BeforeAll
    public static void setup() {
        ctlParser = new ParserCTL();
        muCalcParser = new ParserMuCalc();
    }

    @Test
    public void testBaseCases() {
        ParserMuCalc muCalcParser = new ParserMuCalc();
        testCorrectnessCTL("true");
        testCorrectnessCTL("false");
        testCorrectnessCTL("\"a\"");
        testCorrectnessCTL("AF true");
        testCorrectnessCTL("AG true");
        testCorrectnessCTL("A(false U true)");
        testCorrectnessCTL("A(false W true)");
        testCorrectnessCTL("E(false U true)");
        testCorrectnessCTL("E(false W true)");
        testCorrectnessCTL("true | false");
        testCorrectnessCTL("true & false");

        testCorrectnessMuCalc("mu X.(\"a\" | <>X)");
        testCorrectnessMuCalc("nu X.(\"a\" | <>X)");
    }

    private void testCorrectnessCTL(String ctlFormula) {
        FormulaNode ast = ctlParser.parse(ctlFormula);
        String astToString = ast.toString();
        FormulaNode backToAst = ctlParser.parse(astToString);
        assertEquals(ast, backToAst);
    }

    private void testCorrectnessMuCalc(String muCalcFormula) {
        FormulaNode ast = muCalcParser.parse(muCalcFormula);
        String astToString = ast.toString();
        FormulaNode backToAst = muCalcParser.parse(astToString);
        assertEquals(ast, backToAst);
    }

}
