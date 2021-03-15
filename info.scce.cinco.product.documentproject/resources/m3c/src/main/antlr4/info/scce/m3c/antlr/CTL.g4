grammar CTL;

f :	'(' expr=f ')'                  #parenExpr
|   '!' expr=f                      #not
|   'AF' expr=f            	        #af
|	'EF' expr=f          		    #ef
|	'AG' expr=f          		    #ag
|	'EG' expr=f          		    #eg
|	'A' '(' leftChild=f 'U' rightChild=f ')'  #au
|	'E' '(' leftChild=f 'U' rightChild=f ')'  #eu
|	'A' '(' leftChild=f 'W' rightChild=f ')'  #aw
|	'E' '(' leftChild=f 'W' rightChild=f ')'  #ew
|   '[]' expr=f 				    #emptyBox
|   '['action=ID']' expr=f          #box
|   '<>' expr=f                     #emptyDiamond
|   '<'action=ID'>' expr=f          #diamond
|   leftChild=f '&' rightChild=f    #and
|	leftChild=f '|' rightChild=f    #or
|	leftChild=f '=>' rightChild=f   #impl
|	leftChild=f '<=>' rightChild=f  #equiv
|   'false'              		    #false
|   'true'                		    #true
|	QUOTED_ID                  	    #atom
;

QUOTED_ID : '"' ID '"' | '\'' ID '\'';
ID : ('a'..'z' | 'A'..'Z') ('a'..'z' | 'A'..'Z' | '_' | '0'..'9')* ;
WS : [ \r\t\u000C\n]+ -> skip;
