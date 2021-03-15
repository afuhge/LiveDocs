package info.scce.cinco.product.documentproject.constraint.provider

import info.scce.cinco.product.documentproject.constraint.constraint.Premise
import de.jabc.cinco.meta.runtime.provider.CincoValuesProvider
import java.util.LinkedHashMap

class LabelProvider extends CincoValuesProvider<Premise, String>{
	
	
	override getPossibleValues(Premise field) {
		val LinkedHashMap<String, String> map = new LinkedHashMap<String, String>()
		map.put("IF","IF")
		map.put(" "," ")
		return map
	}
	
}