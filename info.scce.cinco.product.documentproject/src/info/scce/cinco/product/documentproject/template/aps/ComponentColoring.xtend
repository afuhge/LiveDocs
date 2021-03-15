package info.scce.cinco.product.documentproject.template.aps

import de.jabc.cinco.meta.core.ge.style.generator.runtime.appearance.StyleAppearanceProvider
import info.scce.cinco.product.documentproject.template.template.Button
import info.scce.cinco.product.documentproject.template.template.Coloring
import info.scce.cinco.product.documentproject.template.template.Field
import info.scce.cinco.product.documentproject.template.template.MovableContainer
import info.scce.cinco.product.documentproject.template.template.Panel
import style.BooleanEnum
import style.Color
import style.StyleFactory
import info.scce.cinco.product.documentproject.template.template.StaticText

class ComponentColoring implements StyleAppearanceProvider<MovableContainer> {

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

	/**
	 * Returns the modified appearance for a given movable container. The type of
	 * the movable container is checked and if it can be styled by a color constant,
	 * the appearance is extended by the selected color
	 */
	override getAppearance(MovableContainer mc, String s) {
		var app = StyleFactory.eINSTANCE.createAppearance();
		app.setFilled(BooleanEnum.TRUE);
		app.setLineInVisible(false);
		app.setLineWidth(2);
		app.setTransparency(0);
		if (mc instanceof Button) {
			var e = mc as Button;
			if (s.equals("buttonColor")) {
				var c = Coloring.DEFAULT;
				c= e.color;
				if (c == Coloring.DEFAULT) {
					app.setBackground(white());
				} else {
					app.setBackground(getColor(c));
				}

				app.setForeground(getColor(c));
			}
			if (s.equals("buttonText")) {
				app.setFilled(BooleanEnum.FALSE);
				var Coloring c = Coloring.DEFAULT;
				c= e.color;
				if (c == Coloring.DEFAULT) {
					app.setForeground(black());
					app.setBackground(white());
				} else {
					app.setForeground(white());
					app.setBackground(getColor(c));
				}
			}
			if (s.startsWith("pre")) {
				if (e.getIcon() != null) {
					var literal = e.getIcon().getPreIcon().getLiteral();
					app.setImagePath("/icons/template/" + literal + ".png");
					return app;
				}
			}
			if (s.startsWith("post")) {
				if (e.getIcon() != null) {
					var literal = e.getIcon().getPostIcon().getLiteral();
					app.setImagePath("/icons/template/" + literal + ".png");
					return app;
				}
			}
			return app;

		}
		if (mc instanceof Panel) {
			var Panel e =  mc as Panel;
			var Coloring c = Coloring.DEFAULT;
			c = e.getColor();
			if (s.startsWith("panelBorder")) {
				app.setBackground(white());
				app.setForeground(getColor(c));
				return app;
			}
			if (s.startsWith("panelColor")) {
				app.setBackground(getColor(c));
				app.setForeground(getColor(c));
				return app;
			}
			if (s.startsWith("panelText")) {
				app.setBackground(getColor(c));
				app.setFilled(BooleanEnum.FALSE);
				if (c == Coloring.DEFAULT) {
					app.setForeground(black());
				} else {
					app.setForeground(white());
				}
				return app;
			}
			app.setBackground(white());
			app.setForeground(grey());
			return app;
		}
		if (mc instanceof Field) {
			var Field e = mc as Field;
			var Coloring c = Coloring.DEFAULT;
			c= e.color;
			if (s.startsWith("fieldColor")) {
				app.setBackground(white());
				app.setForeground(getColor(c));
				return app;
			}
			if (s.startsWith("fieldText")) {
				app.setFilled(BooleanEnum.FALSE);
				if (c == Coloring.DEFAULT) {
					app.setBackground(white());
					app.setForeground(black());
					return app;
				} else {
					app.setBackground(white());
					app.setForeground(getColor(c));
					return app;
				}
			}
			app.setBackground(white());
			app.setBackground(white());
			return app;
		}
			if (mc instanceof StaticText) {
			var StaticText e = mc as StaticText;
			var Coloring c = Coloring.DEFAULT;
			c= e.color;
			if (s.startsWith("fieldText")) {
				app.setFilled(BooleanEnum.FALSE);
				if (c == Coloring.DEFAULT) {
					app.setBackground(white());
					app.setForeground(black());
					return app;
				} else {
					app.setBackground(white());
					app.setForeground(getColor(c));
					return app;
				}
			}
			app.setBackground(white());
			app.setBackground(white());
			return app;
		}
		return app;
	}

}
