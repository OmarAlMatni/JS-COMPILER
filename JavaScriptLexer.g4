// ==========================================================================
// JavaScript Lexical Analyzer (ECMAScript 2025 subset)
// Phase 1 of the Compilers Project
// ==========================================================================
lexer grammar JavaScriptLexer;



// Import error handling rules from the separate JavaScriptErrors.g4 file.
// ANTLR appends imported rules at the end of this file, ensuring that valid
// tokens (defined below) take precedence over error catch-all rules.
import JavaScriptErrors;

// Virtual tokens used by the multi-line comment lexer mode
tokens {
    MULTI_LINE_COMMENT,
    UNTERMINATED_COMMENT
}

// ==========================================================================
// 1. RESERVED KEYWORDS & LITERALS
// ==========================================================================
// Keywords must be defined BEFORE the generic IDENTIFIER rule.
// In ANTLR, if two rules match the same text length, the first one wins.

// Standard control flow and declaration keywords
BREAK:'break'; CASE:'case'; CATCH:'catch'; CLASS:'class'; CONST:'const';
CONTINUE:'continue'; DEBUGGER:'debugger'; DEFAULT:'default'; DELETE:'delete';
DO:'do'; ELSE:'else'; EXPORT:'export'; EXTENDS:'extends'; FINALLY:'finally';
FOR:'for'; FUNCTION:'function'; IF:'if'; IMPORT:'import'; IN:'in';
INSTANCEOF:'instanceof'; LET:'let'; NEW:'new'; RETURN:'return'; SUPER:'super';
SWITCH:'switch'; THIS:'this'; THROW:'throw'; TRY:'try'; TYPEOF:'typeof';
VAR:'var'; VOID:'void'; WHILE:'while'; WITH:'with'; YIELD:'yield';

// Strict mode reserved words and contextual keywords
ENUM:'enum'; AWAIT:'await'; IMPLEMENTS:'implements'; INTERFACE:'interface';
PACKAGE:'package'; PRIVATE:'private'; PROTECTED:'protected'; PUBLIC:'public';
STATIC:'static'; ASYNC:'async'; OF:'of'; GET:'get'; SET:'set';
TARGET:'target'; 

// Special literal keywords
NULL:'null';
BOOLEAN_LITERAL : 'true' | 'false' ;

// ==========================================================================
// 2. NUMERIC LITERALS (ES2021+ with Numeric Separators & Annex B)
// ==========================================================================
// Order matters: prefixed numbers (Hex/Oct/Bin) and BigInt must be checked 
// before standard Integers and Floats to ensure longest match.

// BigInt: Integer, Hex, Octal, or Binary followed by 'n'
BIGINT_LITERAL
    : ( '0' [xX] HEX_DIGIT ( '_'? HEX_DIGIT )*
      | '0' [oO] [0-7]     ( '_'? [0-7] )*
      | '0' [bB] [01]      ( '_'? [01] )*
      | DECIMAL_INTEGER ) 'n'
    ;

// Prefixed numbers with optional ES2021 numeric separators (e.g., 0xDE_AD_BE_EF)
HEX_NUMBER    : '0' [xX] HEX_DIGIT ( '_'? HEX_DIGIT )* ;
OCTAL_NUMBER  : '0' [oO] [0-7]     ( '_'? [0-7] )* ;
BINARY_NUMBER : '0' [bB] [01]      ( '_'? [01] )* ;

// Annex B (Legacy): Sloppy-mode octals (e.g., 0777) and non-octal decimals (08, 09)
LEGACY_OCTAL_NUMBER : '0' [0-7]+ ;        
NON_OCTAL_DECIMAL   : '0' [89] [0-9]* ;   

// Floating point numbers (e.g., 3.14, .5, 1e10, 1_000.5_0)
FLOAT_NUMBER
    : DECIMAL_INTEGER '.' SEP_DIGITS? DECIMAL_EXPONENT?
    | '.' SEP_DIGITS DECIMAL_EXPONENT?
    | DECIMAL_INTEGER DECIMAL_EXPONENT
    ;

// Standard base-10 integers (e.g., 42, 1_000_000)
INTEGER_NUMBER : DECIMAL_INTEGER ;

// ==========================================================================
// 3. STRING LITERALS & TEMPLATE LITERALS
// ==========================================================================
// Handles single and double quotes, escape sequences, and line continuations.
// '\\' ( '\r'? '\n' | . ) allows a backslash to escape ANY character, 
// including Windows (CRLF) and Unix (LF) line breaks for line continuation.
STRING_LITERAL
    : '\'' ( '\\' ( '\r'? '\n' | . ) | ~['\\\r\n] )* '\''
    | '"'  ( '\\' ( '\r'? '\n' | . ) | ~["\\\r\n] )* '"'
    ;

// Template literals (backticks). They can span multiple lines natively.
// '${...}' interpolation is treated as part of the string at the lexical level.
TEMPLATE_LITERAL : '`' ( '\\' . | ~[`\\] )* '`' ;

// ==========================================================================
// 4. COMMENTS
// ==========================================================================
// Single-line comments consume everything up to (but not including) the newline.
SINGLE_LINE_COMMENT : '//' ~[\r\n]* ;

// Multi-line comments use a Lexer Mode to safely handle nested characters 
// and properly detect unterminated comments at EOF.
BLOCK_COMMENT_START : '/*' -> more, pushMode(COMMENT_MODE) ;

// ==========================================================================
// 5. IDENTIFIERS & SPECIAL TOKENS
// ==========================================================================
// ES2023 Hashbang comments (e.g., #!/usr/bin/env node) must be checked 
// before the generic Private Identifier (#name) rule.
HASHBANG_COMMENT   : '#!' ~[\r\n]* ;                 

// Standard JS identifiers and ES2022 Private Class fields (#privateVar)
IDENTIFIER         : IdentifierStart IdentifierPart* ;
PRIVATE_IDENTIFIER : '#' IdentifierStart IdentifierPart* ;

// ==========================================================================
// 6. OPERATORS & PUNCTUATION
// ==========================================================================
// Multi-character operators are defined first to ensure longest-match precedence.
STRICT_EQUAL:'==='; STRICT_NOT_EQUAL:'!=='; UNSIGNED_RIGHT_ASSIGN:'>>>=';
EXPONENT_ASSIGN:'**='; SHIFT_LEFT_ASSIGN:'<<='; SHIFT_RIGHT_ASSIGN:'>>=';
AND_ASSIGN:'&&='; OR_ASSIGN:'||='; NULLISH_ASSIGN:'??=';
OPTIONAL_CHAIN:'?.'; INCREMENT:'++'; DECREMENT:'--'; EXPONENT:'**';
LEFT_SHIFT:'<<'; RIGHT_SHIFT:'>>'; UNSIGNED_RIGHT_SHIFT:'>>>';
LESS_EQUAL:'<='; GREATER_EQUAL:'>='; EQUAL:'=='; NOT_EQUAL:'!=';
LOGICAL_AND:'&&'; LOGICAL_OR:'||'; NULLISH:'??';
PLUS_ASSIGN:'+='; MINUS_ASSIGN:'-='; MULTIPLY_ASSIGN:'*=';
DIVIDE_ASSIGN:'/='; MODULO_ASSIGN:'%='; BIT_AND_ASSIGN:'&=';
BIT_OR_ASSIGN:'|='; BIT_XOR_ASSIGN:'^='; ARROW:'=>'; ASSIGN:'=';
PLUS:'+'; MINUS:'-'; MULTIPLY:'*'; DIVIDE:'/'; MODULO:'%';
BIT_AND:'&'; BIT_OR:'|'; BIT_XOR:'^'; BIT_NOT:'~'; LOGICAL_NOT:'!';
LESS_THAN:'<'; GREATER_THAN:'>'; QUESTION:'?'; COLON:':'; SEMICOLON:';';
COMMA:','; DOT:'.'; ELLIPSIS:'...';
LEFT_PAREN:'('; RIGHT_PAREN:')'; LEFT_BRACE:'{'; RIGHT_BRACE:'}';
LEFT_BRACKET:'['; RIGHT_BRACKET:']';

// ==========================================================================
// 7. WHITESPACE
// ==========================================================================
// Spaces, tabs, form feeds, and newlines are skipped and not emitted as tokens.
WS : [ \t\r\n\u000C]+ -> skip ;

// ==========================================================================
// FRAGMENTS (Helper rules, never emitted as tokens)
// ==========================================================================
fragment SEP_DIGITS       : [0-9] ( '_'? [0-9] )* ;
fragment DECIMAL_INTEGER  : '0' | [1-9] ( '_'? [0-9] )* ;
fragment DECIMAL_EXPONENT : [eE] [+-]? SEP_DIGITS ;
fragment HEX_DIGIT        : [0-9a-fA-F] ;
fragment IdentifierStart  : [a-zA-Z_$] ;
fragment IdentifierPart   : [a-zA-Z0-9_$] ;

// ==========================================================================
// MULTI-LINE COMMENT MODE
// ==========================================================================
// When '/*' is encountered, the lexer enters this mode to safely consume 
// characters until '*/' is found, preventing conflicts with other rules.
mode COMMENT_MODE;

// Closing delimiter: emits the complete comment token and returns to default mode.
COMMENT_END     : '*/' -> type(MULTI_LINE_COMMENT), popMode ;

// Keep collecting comment characters silently.
COMMENT_CONTENT : .    -> more ;

// Reached EOF without finding '*/': emits an unterminated comment error token.
COMMENT_EOF     : EOF  -> type(UNTERMINATED_COMMENT), popMode ;