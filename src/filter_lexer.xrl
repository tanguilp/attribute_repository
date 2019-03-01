Definitions.

ALPHA   	= [A-Za-z]
NAMECHAR	= [A-Za-z0-9_-]
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
