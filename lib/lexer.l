esc  "\\"
int  ([0-9]|[1-9][0-9]+)
exp  ([eE][-+]?[0-9]+)
frac  ("."[0-9]+)
IDS  [a-zA-Z$_]|"\u"[a-fA-F0-9]{4}
BSL  "\\".
RCLASS "["({BSL}|[^\\\]])*"]"

%x for

%%

";"\s+/("++"|"--")      return ';'
\n(\s|\n)*/("++"|"--")  return ';'
\n(\s|\n)*              if (yy.ASI) { yy.ASI=false; return ';';} else yy.lineBreak = true;
\s+                     yy.ASI=false; /* skip whitespace */
"//".*                  /* skip comment */
"#".*                   /* skip comment */
"/*"(.|\n)*?"*/"        yy.ASI=false; /* skip comment */

"0"[xX][a-fA-F0-9]+/([^a-zA-Z$_]{0,1})              return 'NUMBER';
([1-9][0-9]+|[0-9]){frac}?{exp}?/([^a-zA-Z$_]{0,1}) return 'NUMBER';

'"'("\\x"[a-fA-F0-9]{2}|"\\u"[a-fA-F0-9]{4}|"\\"[^xu]|[^"{esc}\n])*'"'    {yytext = yytext.substr(1,yyleng-2); return 'STRING';}
"'"("\\"['bfvnrt/{esc}]|"\\u"[a-fA-F0-9]{4}|[^'{esc}])*"'"    {yytext = yytext.substr(1,yyleng-2); return 'STRING';}

/("/="({BSL}|{RCLASS}|[^[\\\/])*"/"({IDS})*) %{
  if(!!yy.inRegex) {
    var s = yy.lexer.matches[1];
    for(var i=0;i<s.length;++i) {
      yy.lexer.input();
    }
    yytext = s;
    return 'REGEXP_BODY';
  } else {
    yy.lexer.input(); yy.lexer.input();
    return 'DIVEQUAL';
  };
%}

/("/"({BSL}|{RCLASS}|[^[\\\/*])({BSL}|{RCLASS}|[^[\\\/])*"/"({IDS})*) %{
  if(!!yy.inRegex) {
    var s = yy.lexer.matches[1];
    for(var i=0;i<s.length;++i) {
      yy.lexer.input();
    }
    yytext = s;
    return 'REGEXP_BODY';
  } else {
    yy.lexer.input();
    return '/';
  };
%}


"{"                     return 'OPENBRACE'
<for>"{"                this.popState(); return 'OPENBRACE';
"}"                     return 'CLOSEBRACE'
"["                     return '['
<for>"["                this.popState(); return '['
"]"                     return ']'
"("                     return '('

<for>"("                %{
  if (yy.sawParen) {
    this.popState();
  } else {
    yy.sawParen = true;
  }

  return '(';
%}

<for>\s+                yy.ASI = false;
<for>";"                this.popState(); yy.ASI = false; return ";"

")"                     return ')'
","                     return ','
"..."/((#{IDS})+(#{IDS}|[0-9])*) return 'SPREAD'
"."                     return '.'
";"                     yy.ASI = false; return ';'
":"                     return ':'
"+="                    return 'PLUSEQUAL'
"-="                    return 'MINUSEQUAL'
"*="                    return 'MULTEQUAL'
"%="                    return 'MODEQUAL'
"&="                    return 'ANDEQUAL'
"|="                    return 'OREQUAL'
"^="                    return 'XOREQUAL'
"<<="                   return 'LSHIFTEQUAL'
">>="                   return 'RSHIFTEQUAL'
">>>="                  return 'URSHIFTEQUAL'
"/="                    return 'DIVEQUAL'
"<="                    return 'LE'
">="                    return 'GE'
"==="                   return 'STREQ'
"!=="                   return 'STRNEQ'
"=="                    return 'EQEQ'
"!="                    return 'NE'
"&&"                    return 'AND'
"||"                    return 'OR'
"++"                    return 'PLUSPLUS'
"--"                    return 'MINUSMINUS'
">>>"                   return 'URSHIFT'
"<<"                    return 'LSHIFT'
">>"                    return 'RSHIFT'
"+"                     return '+'
"-"                     return '-'
"*"                     return '*'
"%"                     return '%'
"<"                     return '<'
">"                     return '>'
"&"                     return '&'
"|"                     return '|'
"^"                     return '^'
"!"                     return '!'
"~"                     return '~'
"?"                     return '?'
"/"                     return '/'
"="                     return '='
"break"                 yy.ASI = true; return 'BREAK'
"case"                  return 'CASE'
"continue"              yy.ASI = true; return 'CONTINUE'
"debugger"              return 'DEBUGGER'
"default"               return 'DEFAULT'
"delete"                return 'DELETETOKEN'
"do"                    return 'DO'
"else"                  return 'ELSE'
"finally"               return 'FINALLY'
"for"                   { this.begin("for"); yy.sawParen = false; return 'FOR'; }
<for>"own"              { this.popState(); return 'OWN'; }
"function"              return 'FUNCTION'
"if"                    return 'IF'
"in"                    return 'INTOKEN'
"instanceof"            return 'INSTANCEOF'
"new"                   { return 'NEW'; }
<for>"new"              { this.popState(); return 'NEW'; }
"return"                yy.ASI = true; return 'RETURN'
"switch"                return 'SWITCH'
"try"                   return 'TRY'
"catch"                 return 'CATCH'
"throw"                 yy.ASI = true; return 'THROW'
"typeof"                return 'TYPEOF'
"var"                   return 'VAR';
<for>"var"              { this.popState(); return 'VAR'; }
"void"                  return 'VOIDTOKEN'
"while"                 return 'WHILE'
"with"                  return 'WITH'
"class"                 return 'CLASS'
"const"                 return 'CONSTTOKEN'
<for>"const"            { this.popState(); return 'CONSTTOKEN'; }
"enum"                  return 'ENUM'
"export"                return 'EXPORT'
"extends"               return 'EXTENDS'
"import"                return 'IMPORT'
"super"                 return 'SUPERTOKEN'
"implements"            return 'IMPLEMENTS'
"interface"             return 'INTERFACE'
"let"                   return 'LET'
<for>"let"              { this.popState(); return 'LET' }
"package"               return 'PACKAGE'
"private"               return 'PRIVATE'
"protected"             return 'PROTECTED'
"public"                return 'PUBLIC'
"static"                return 'STATIC'
"yield"                 return 'YIELD'
"this"                  return 'THISTOKEN'
"@"                     return 'AT_THISTOKEN'
"true"                  return 'TRUETOKEN'
"false"                 return 'FALSETOKEN'
"null"                  return 'NULLTOKEN'
({IDS})+({IDS}|[0-9])*  return 'IDENT';
<for>({IDS})+({IDS}|[0-9])*  { this.popState(); return 'IDENT'; }
.                       return 'INVALID'

%%

