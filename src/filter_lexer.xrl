Definitions.

ALPHA   	= [A-Za-z]
NAMECHAR	= [A-Za-z0-9_-]
% XML datetime from https://www.w3.org/TR/xmlschema11-2/#nt-yrFrag
YEARFRAG	= -?(([1-9][0-9][0-9][0-9]+)|0[0-9][0-9][0-9])
MONTHFRAG	= (0[1-9])|(1[0-2])
DAYFRAG		= (0[1-9])|([12][0-9])|(3[01])
HOURFRAG	= ([01][0-9])|(2[0-3])
MINUTEFRAG	= [0-5][0-9]
SECONDFRAG	= [0-5][0-9](\.[0-9]+)?
ENDOFDAYFRAG	= 24:00:00(\.(0+))?
TIMEZONEFRAG	= Z|(\+|-)((0[0-9]|1[0-3]):{MINUTEFRAG}|14:00)
DATETIME	= "({YEARFRAG})-({MONTHFRAG})-({DAYFRAG})T((({HOURFRAG}):({MINUTEFRAG}):({SECONDFRAG}))|({ENDOFDAYFRAG}))({TIMEZONEFRAG})?"
% from https://tools.ietf.org/html/rfc7159#section-7
STRING		= "([\x{20}\x{21}\x{23}-\x{5B}\x{5D}-\x{10FFFF}]|\\\x{22}|\\\x{5C}|\\\x{2F}|\\\x{62}|\\\x{66}|\\\x{6E}|\\\x{72}|\\\x{74}|\\\x75[0-9][0-9][0-9][0-9])*"
NUMBER		= -?(0|[1-9][0-9]*)(\.[0-9]+)?(e(\+|-)?[0-9]+)?
% from https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/uri.ex#L447
URI		= [A-Za-z][A-Za-z0-9+.-]*:([^\s]+):
%FIXME: this is an approximation of the URI regex

Rules.

and     		: {token, {'and', TokenLine}}.
or	     		: {token, {'or', TokenLine}}.
not     		: {token, {'not', TokenLine}}.
true    		: {token, {true, TokenLine}}.
false   		: {token, {false, TokenLine}}.
null   			: {token, {null, TokenLine}}.
pr			: {token, {pr, TokenLine}}.
eq			: {token, {eq, TokenLine}}.
ne			: {token, {ne, TokenLine}}.
co			: {token, {co, TokenLine}}.
sw			: {token, {sw, TokenLine}}.
ew			: {token, {ew, TokenLine}}.
gt			: {token, {gt, TokenLine}}.
lt			: {token, {lt, TokenLine}}.
ge			: {token, {ge, TokenLine}}.
le			: {token, {le, TokenLine}}.
{DATETIME}		: {token, {datetime, TokenLine, to_elixir_datetime(TokenChars)}}.
{STRING}		: {token, {string, TokenLine, unicode:characters_to_binary(strip_quotes(TokenChars))}}.
{NUMBER}		: {token, {number, TokenLine, to_erlang_number(TokenChars)}}.
\[			: {token, {'[',TokenLine}}.
\]			: {token, {']',TokenLine}}.
\(			: {token, {'(',TokenLine}}.
\)			: {token, {')',TokenLine}}.
\.			: {token, {'.', TokenLine, TokenChars}}.
{ALPHA}{NAMECHAR}*	: {token, {attributename, TokenLine, TokenChars}}.
{URI}			: {token, {uri, TokenLine, lists:droplast(TokenChars)}}.
\s			: skip_token.
%FIXME: according to the grammar one and only one space is allowed

Erlang code.

strip_quotes([_ | List]) -> lists:droplast(List).

to_erlang_number(Chars) ->
	Str = list_to_binary(Chars),
	'Elixir.Jason':'decode!'(Str).

to_elixir_datetime(Chars) ->
	Str = list_to_binary(strip_quotes(Chars)),
	{ok, DateTime, _} = 'Elixir.DateTime':'from_iso8601'(Str),
	DateTime.
