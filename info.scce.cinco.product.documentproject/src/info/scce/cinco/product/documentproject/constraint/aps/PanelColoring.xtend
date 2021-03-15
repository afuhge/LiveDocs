package info.scce.cinco.product.documentproject.constraint.aps

import de.jabc.cinco.meta.core.ge.style.generator.runtime.appearance.StyleAppearanceProvider
import style.StyleFactory
import style.Color
import info.scce.cinco.product.documentproject.constraint.constraint.Panel
import info.scce.cinco.product.documentproject.template.template.Coloring

class PanelColoring implements StyleAppearanceProvider<Panel> {

	override getAppearance(Panel panel, String arg1) {
		val app = StyleFactory.eINSTANCE.createAppearance
		var templPanel = (panel.panel as info.scce.cinco.product.documentproject.dependency.dependency.Panel).panel as info.scce.cinco.product.documentproject.template.template.Panel
		var Coloring c = Coloring.DEFAULT;
		c = templPanel.color
		if (c == Coloring.DEFAULT) {
			app.setForeground(black());
		} else {
			app.setForeground(white());
		}
		app.setBackground(getColor(c));
		return app
	}

	/**
	 * Converts a given coloring constant to RGB color
	 * 
	 * @param c
	 * @return
	 */
	def getColor(Coloring c) {
		var Color cl = StyleFactory.eINSTANCE.createColor();
		switch (c) {
			case BLUE: {
				cl.setR(51);
				cl.setG(122);
				cl.setB(183);
			}
			case DEFAULT: {
				cl.setR(204);
				cl.setG(204);
				cl.setB(204);
			}
			case GREEN: {
				cl.setR(92);
				cl.setG(184);
				cl.setB(92);
			}
			case LIGHTBLUE: {
				cl.setR(91);
				cl.setG(192);
				cl.setB(222);
			}
			case RED: {
				cl.setR(217);
				cl.setG(83);
				cl.setB(79);
			}
			case YELLOW: {
				cl.setR(240);
				cl.setG(173);
				cl.setB(78);
			}
		}
		return cl;
	}

	/**
	 * Returns a grey style color
	 * 
	 * @return
	 */
	def Color grey() {
		var Color cl = StyleFactory.eINSTANCE.createColor();
		cl.setR(214);
		cl.setG(215);
		cl.setB(212);
		return cl;
	}

	/**
	 * Returns a black style color
	 * 
	 * @return
	 */
	def Color black() {
		var Color cl = StyleFactory.eINSTANCE.createColor();
		cl.setB(0);
		cl.setG(0);
		cl.setR(0);
		return cl;
	}

	/**
	 * Returns a white style color
	 * 
	 * @return
	 */
	def Color white() {
		var Color cl = StyleFactory.eINSTANCE.createColor();
		cl.setB(255);
		cl.setG(255);
		cl.setR(255);
		return cl;
	}

}
