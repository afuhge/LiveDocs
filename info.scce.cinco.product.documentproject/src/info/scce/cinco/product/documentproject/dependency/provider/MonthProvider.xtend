package info.scce.cinco.product.documentproject.dependency.provider

import de.jabc.cinco.meta.runtime.provider.CincoValuesProvider
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import java.util.Arrays
import java.util.LinkedHashMap

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