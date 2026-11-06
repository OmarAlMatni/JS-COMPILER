# JavaScript Lexical Analyzer — ECMAScript 2025 (Phase 1)

A lexical analyzer (scanner) for the **JavaScript / ECMAScript 2025** language, built with
**ANTLR 4**. It reads a `.js` source file, extracts every lexeme as a typed token with its
exact `line:column` position, and reports **lexical errors** precisely located.

> Compilers Project — Phase 1 (Lexical Analysis). The grammar rules live in a single
> `JavaScriptLexer.g4` file; the driver/runner is `Main.java`.

---

## ✨ Recognized Tokens

| Category | Examples |
|---|---|
| Reserved keywords | `var`, `let`, `if`, `else`, `return`, `function`, … |
| Numbers | `42` (INTEGER), `3.14` (FLOAT), `0xFF` (HEX), `0o17` (OCTAL), `0b101` (BINARY), `10n` (BIGINT), plus legacy octal `0123` and non-octal decimal `0189` |
| Booleans | `true`, `false` |
| String literals | `"..."` and `'...'` with escape sequences and line continuation |
| Template literals | `` `...` `` spanning multiple lines |
| Operators & punctuation | `+  -  *  /  =  ==  ===  <  >  &&  ||  !  ;  ,  {  }  (  )  [  ]` … |
| Identifiers & variables | `myVar`, `_x`, `$count`, … |
| Comments | `// single line`, `/* multi line */` |

### Special cases handled (the heart of this phase)

1. **Single-line strings** — start and end with the same quote; may contain the *other*
   quote without escaping; escape sequences `\X` are accepted as-is; **line continuation**
   (backslash + newline) extends the STRING token across two lines as one token:
   `var a='It\'s a"beautiful" day';` and `var b="abc\<newline>def";`
2. **Template literals** — multi-line strings between backticks.
3. **Multi-line comments** — including unterminated detection.
4. **Lexical errors** — unterminated strings/comments, stray characters, and invalid
   numeric literals (`1__2`, `1e+`, `1.5n`) are reported as
   `Invalid or unexpected token` with exact position.
5. **Extras beyond the spec sheet** — ES2021 numeric separators (`1_000`), ES2023 hashbang
   (`#!/usr/bin/env node`), legacy octal numbers.

---

## 📤 Output Format

```
--- Tokens Found ---
Text:[var]-> Type: RESERVED_KEYWORD (1:0)
Text:[s]-> Type: IDENTIFIER (1:4)
Text:[=]-> Type: ASSIGN (1:6)
Text:[var]-> Type: RESERVED_KEYWORD (1:12)
Text:[t]-> Type: IDENTIFIER (1:16)
Text:[=]-> Type: ASSIGN (1:18)
Text:[5]-> Type: INTEGER_NUMBER (1:20)
Text:[;]-> Type: SEMICOLON (1:21)
--- Lexical Errors: 1 ---
Error at 1:8 Invalid or unexpected token (unterminated string literal)
```

Every token prints: **lexeme first**, then its **type**, then its **(line:column)**.
Errors print: `Error at line:column message`. Type names are the ANTLR token names
defined in `JavaScriptLexer.g4`.

---

## 📁 Project Layout

```
.
├── JavaScriptLexer.g4        # ANTLR lexer grammar (all rules + special cases)
├── Main.java                 # Driver: reads a .js file, runs lexer, prints report
├── test.js                   # Happy-path test: every token category
├── special.js                # Special-cases test: escapes, continuation, templates
├── error.js                  # Lexical-errors test: unterminated/invalid lexemes
├── README.md
└── .gitignore
```

---

## ⚙️ Setup

**Requirements:** JDK 17+ and the ANTLR 4.13.2 complete jar.

1. Download the jar into the project root:
   <https://www.antlr.org/download/antlr-4.13.2-complete.jar>
2. Generate the lexer from the grammar:
   ```bash
   java -jar antlr-4.13.2-complete.jar JavaScriptLexer.g4
   ```
3. Compile the generated lexer + driver:
   ```bash
   javac -cp ".;antlr-4.13.2-complete.jar" JavaScriptLexer.java Main.java
   ```

---

## 🧪 Testing

Run the analyzer on each bundled test file:

```bash
java -cp ".;antlr-4.13.2-complete.jar" Main test.js
java -cp ".;antlr-4.13.2-complete.jar" Main special.js
java -cp ".;antlr-4.13.2-complete.jar" Main error.js
```

| File | What it proves | Expected result |
|---|---|---|
| `test.js` | Every token category lexes correctly (keywords, all number bases, booleans, strings, operators, identifiers, comments) | Full token list, `--- Lexical Errors: 0 ---` |
| `special.js` | Escape sequences, quotes-inside-quotes, **line continuation** (one STRING token spanning two lines), multi-line **template literals**, multi-line comments | Multi-line tokens reported as single tokens with start position, 0 errors |
| `error.js` | Unterminated string, stray characters, invalid numeric literals, unterminated comment | `--- Lexical Errors: N ---` with each error at its exact `line:column` |

---

## 🗺️ Roadmap

- [x] Phase 1 — Lexical analysis (this repo)
- [ ] Phase 2 — Syntax analysis (parser)

