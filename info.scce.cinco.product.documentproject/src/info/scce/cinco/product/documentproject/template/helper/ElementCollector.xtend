package info.scce.cinco.product.documentproject.template.helper

import graphmodel.Node

class ElementCollector {
		/**
	 * Sorts a list of nodes according to their horizontal position.
	 * 
	 * @param elements
	 * @return
	 */
	static def <T extends Node> getElementsH(Iterable<T> elements) {
		elements.sortBy[x]
	}
	
	/**
	 * Sorts a list of nodes according to their vertical position.
	 * 
	 * @param elements
	 * @return
	 */
	static def <T extends Node> getElementsV(Iterable<T> elements) {
		elements.sortBy[y]
	}
}