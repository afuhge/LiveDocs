grammar ModalMu;

f:  '(' expr=f ')'                  #parenExp
|   '!' expr=f                      #not
|   'nu'  var=ID '.' expr=f         #gfp
|   'mu'  var=ID '.' '(' expr=f ')' #lfp
|   '[]' expr=f 				    #emptyBox
|   '['action=ID']' expr=f          #box
|   '<>' expr=f                     #emptyDiamond
|   '<'action=ID'>' expr=f          #diamond
|   leftChild=f '&' rightChild=f              #and
|   leftChild=f '|' rightChild=f              #or
|   leftChild=f '=>' rightChild=f             #impl
|   leftChild=f '<=>' rightChild=f            #equiv
|   'false'              		    #false
|   'true'                		    #true
|   QUOTED_ID                       #atom
|   ID                              #var
;

QUOTED_ID : '"' ID '"'
 | '\'' ID '\'';
STRING_LITERAL :
'"' ~["\\]* (('\\"' | '\\\\') ~["\\]*)* '"'
| '\'' ~[\'\\]* (('\\\'' | '\\\\') ~[\'\\]*)* '\'';
ID : ('a'..'z' | 'A'..'Z') ('a'..'z' | 'A'..'Z' | '_' | '0'..'9')* ;
WS         : [ \r\t\u000C\n]+ -> skip;