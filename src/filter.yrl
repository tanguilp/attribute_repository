Nonterminals filter
attrExp logExp valuePath
valFilter valLogExp
attrPath attrName
compareOp compValue.

Terminals
and or not
true false null string number datetime
pr
eq ne co sw ew gt lt ge le
'[' ']' '(' ')' '.'
attributename uri.

Rootsymbol filter.
Endsymbol '$end'.

%FIXME: precedence of not (but since parenthesis are required, does it make sense?)
Left 100 'or'.
Left 200 'and'.

filter -> attrExp : {'attrExp', '$1'}.
filter -> logExp : '$1'.
filter -> valuePath : '$1'.
filter -> '(' filter ')' : '$2'.
filter -> 'not' '(' filter ')' : {'not', '$3'}.

attrExp -> attrPath pr : {pr, '$1'}.
attrExp -> attrPath compareOp compValue : {'$2', '$1', '$3'}.

logExp -> filter 'and' filter : {'and', '$1', '$3'}.
logExp -> filter 'or' filter : {'or', '$1', '$3'}.

valuePath -> attrPath '[' valFilter ']' : {'valuePath', '$1', '$3'}.

valFilter -> attrExp : '$1'.
valFilter -> valLogExp : '$1'.
valFilter -> '(' valFilter ')' : '$2'.
valFilter -> 'not' '(' valFilter ')' : {'not', '$3'}.

%FIXME: quickhack because SCIM standard grammar is wrong
valLogExp -> attrExp 'and' valLogExp : {'and', '$1', '$3'}.
valLogExp -> attrExp 'and' attrExp : {'and', '$1', '$3'}.
valLogExp -> attrExp 'or' valLogExp : {'or', '$1', '$3'}.
valLogExp -> attrExp 'or' attrExp : {'or', '$1', '$3'}.

attrPath -> attrName :
	'Elixir.AttributeRepository.Search.AttributePath':'new'(#{attribute => '$1'}).
attrPath -> uri attrName :
	'Elixir.AttributeRepository.Search.AttributePath':'new'(#{attribute => '$2',
								  uri => element(3, '$1')}).
attrPath -> attrName '.' attrName :
	'Elixir.AttributeRepository.Search.AttributePath':'new'(#{attribute => '$1',
								  sub_attribute => '$3'}).
attrPath -> uri attrName '.' attrName :
	'Elixir.AttributeRepository.Search.AttributePath':'new'(#{attribute => '$2',
								  uri => element(3, '$1'),
								  sub_attribute => '$4'}).

attrName -> attributename : element(3, '$1').

compareOp -> eq : eq.
compareOp -> ne : ne.
compareOp -> co : co.
compareOp -> sw : sw.
compareOp -> ew : ew.
compareOp -> gt : gt.
compareOp -> lt : lt.
compareOp -> ge : ge.
compareOp -> le : le.

compValue -> true : true.
compValue -> false : false.
compValue -> null : null.
compValue -> string : element(3, '$1').
compValue -> number : element(3, '$1').
compValue -> datetime : element(3, '$1').

Erlang code.

