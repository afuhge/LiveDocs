package info.scce.m3c.formula;

import info.scce.m3c.formula.FormulaNode;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a block in an equational system
 *
 * @author alnis
 */
public class EquationalBlock {

    private boolean isMaxBlock;
    private int blockNumber;
    private List<FormulaNode> nodes;

    public EquationalBlock() {
        blockNumber = 0;
        nodes = new ArrayList<>();
    }

    public EquationalBlock(boolean isMaxBlock) {
        this.isMaxBlock = isMaxBlock;
        this.nodes = new ArrayList<>();
    }

    public EquationalBlock(boolean isMaxBlock, int blockNumber) {
        this.isMaxBlock = isMaxBlock;
        this.blockNumber = blockNumber;
        this.nodes = new ArrayList<>();
    }

    public boolean containsNodeWithVarNumber(int varNumber) {
        for(FormulaNode node : nodes) {
            if(node.getVarNumber() == varNumber) {
                return true;
            }
        }
        return false;
    }

    public List<FormulaNode> getNodes() {
        return nodes;
    }

    public void addNode(FormulaNode node) {
        nodes.add(node);
    }

    public void setIsMaxBlock(boolean isMaxBlock) {
        this.isMaxBlock = isMaxBlock;
    }

    public boolean isMaxBlock() {
        return isMaxBlock;
    }

    public int getBlockNumber() {
        return blockNumber;
    }

    public void setBlockNumber(int blockNumber) {
        this.blockNumber = blockNumber;
    }

}
