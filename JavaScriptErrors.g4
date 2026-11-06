// ==========================================================================
// JavaScript Lexical Error Handling Rules
// Phase 1 of the Compilers Project
// ==========================================================================
// NOTE: These rules are imported into JavaScriptLexer.g4. ANTLR appends them
// at the end of the main grammar, ensuring valid tokens take precedence.
// ==========================================================================
lexer grammar JavaScriptErrors;



// ==========================================================================
// 1. UNTERMINATED STRING & TEMPLATE LITERALS
// ==========================================================================
// These rules catch strings that open but never close before a raw newline or EOF.
// Note: Valid line continuations (backslash + newline) are handled by STRING_LITERAL.

// Double-quoted string without closing quote.
UNTERMINATED_DOUBLE_STRING
    : '"'  ( '\\' ( '\r'? '\n' | . ) | ~["\\\r\n] )* ( '\r'? '\n' | EOF ) ;

// Single-quoted string without closing quote.
UNTERMINATED_SINGLE_STRING
    : '\'' ( '\\' ( '\r'? '\n' | . ) | ~['\\\r\n] )* ( '\r'? '\n' | EOF ) ;

// Template literal without closing backtick (must reach EOF).
UNTERMINATED_TEMPLATE
    : '`' ( '\\' . | ~[`\\] )* EOF ;

// NOTE: Unterminated multi-line comments (/* ...) are NOT handled here.
// They are handled safely inside the COMMENT_MODE in JavaScriptLexer.g4 
// to prevent this rule from accidentally swallowing valid code after a closed comment.

// ==========================================================================
// 2. INVALID NUMERIC LITERALS
// ==========================================================================
// These catch malformed numbers that look like valid prefixes but contain 
// invalid characters or structures.

// Invalid Hexadecimal (e.g., 0x, 0xG, 0x1G)
INVALID_HEX    : '0' [xX] [a-zA-Z0-9_]* ;

// Invalid Binary (e.g., 0b, 0b102, 0b123)
INVALID_BINARY : '0' [bB] [a-zA-Z0-9_]* ;

// Invalid Octal (e.g., 0o, 0o89, 0o128)
INVALID_OCTAL  : '0' [oO] [a-zA-Z0-9_]* ;

// Invalid ES2021 Numeric Separators (e.g., 1__2, 1_, 0x_FF)
INVALID_SEPARATOR
    : [0-9]* '_' '_' [a-zA-Z0-9_]*
    | [0-9]+ '_'
    | '0' [xXbBoO] '_' [a-zA-Z0-9_]*
    ;

// Invalid Exponents (e.g., 1e, 1e+, 2.5e-)
INVALID_EXPONENT
    : [0-9]+ [eE] [+-]?
    | [0-9]+ '.' [0-9]* [eE] [+-]?
    ;

// Invalid BigInt forms (e.g., 1.5n, 1e5n - floats/exponents cannot be BigInts)
INVALID_BIGINT
    : [0-9]+ '.' [0-9]+ 'n'
    | [0-9]+ [eE] [+-]? [0-9]+ 'n'
    ;

// ==========================================================================
// 3. INVALID NUMBER SUFFIXES (ES Specification Rule)
// ==========================================================================
// The ECMAScript spec states: "The SourceCharacter immediately following a 
// NumericLiteral must not be an IdentifierStart." 
// This catches errors like `123abc` or `5x` which would otherwise silently 
// split into a valid number and a valid identifier.
INVALID_NUMBER_SUFFIX
    : [0-9] ( '_'? [0-9] )* ( '.' [0-9_]* )? ( [eE] [+-]? [0-9] ( '_'? [0-9] )* )? 'n'? [a-zA-Z_$] [a-zA-Z0-9_$]*
    | '.' [0-9] [0-9_]* ( [eE] [+-]? [0-9] ( '_'? [0-9] )* )? 'n'? [a-zA-Z_$] [a-zA-Z0-9_$]*
    ;

// ==========================================================================
// 4. CATCH-ALL ERROR TOKEN
// ==========================================================================
// Must be the absolute last rule in the entire lexer.
// Catches any single character that failed to match ANY valid or specific 
// invalid token rule (e.g., '@', '$' alone if not part of an identifier, etc.).
ERROR_CHAR : . ;