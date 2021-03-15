package info.scce.cinco.product.documentproject.constraint.provider

import de.jabc.cinco.meta.runtime.provider.CincoValuesProvider
import java.util.LinkedHashMap
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint

class DayProvider  extends CincoValuesProvider<DateFieldConstraint, String>{
	
	
	override getPossibleValues(DateFieldConstraint field) {
		val LinkedHashMap<String, String> map = new LinkedHashMap<String, String>()
		var i = 1;
		for (i = 1; i <= 31; i++) {
			map.put(i.toString, i.toString)
		}
		return map
	}
	
}