package info.scce.cinco.product.documentproject.constraint.provider

import de.jabc.cinco.meta.runtime.provider.CincoValuesProvider
import java.util.LinkedHashMap
import java.util.Arrays
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint

class MonthProvider extends CincoValuesProvider<DateFieldConstraint, String>{
	
	
	override getPossibleValues(DateFieldConstraint field) {
		val LinkedHashMap<String, String> map = new LinkedHashMap<String, String>()
		var months = Arrays.asList("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
		var i = 0;
		for (i = 0; i < months.size; i++) {
			map.put(months.get(i), months.get(i))
		}
		return map
	}
	
}