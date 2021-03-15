package info.scce.cinco.product.documentproject.constraint.provider

import java.util.LinkedHashMap
import de.jabc.cinco.meta.runtime.provider.CincoValuesProvider
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint

class YearProvider extends CincoValuesProvider<DateFieldConstraint, String>{
	
	
	override getPossibleValues(DateFieldConstraint field) {
		val LinkedHashMap<String, String> map = new LinkedHashMap<String, String>()
		var i = 1950;
		for (i = 1950; i <= 2100; i++) {
			map.put(i.toString, i.toString)
		}
		return map
	}
	
}