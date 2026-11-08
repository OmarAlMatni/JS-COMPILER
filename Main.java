package edu.compiler.lexer;

import org.antlr.v4.runtime.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class Main {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("Usage: java edu.compiler.lexer.Main <file.js>");
            return;
        }
        
        CharStream input = CharStreams.fromFileName(args[0], StandardCharsets.UTF_8);
        JavaScriptLexer lexer = new JavaScriptLexer(input);
        lexer.removeErrorListeners();

        // List to store errors and print them at the end
        List<String> errors = new ArrayList<>();
        
        // Exact header format requested
        System.out.println("---Tokens Found---");
        
        Token token;
        while ((token = lexer.nextToken()).getType() != Token.EOF) {
            if (token.getChannel() != Token.DEFAULT_CHANNEL) continue;
            
            String type = lexer.getVocabulary().getSymbolicName(token.getType());
            if (type == null) type = "TOKEN_" + token.getType();
            
            String text = token.getText()
                    .replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t");

            String errorMsg = getErrorMessage(type, text);
            
            if (errorMsg != null) {
                // DO NOT PRINT YET. Just add to the list.
                errors.add("Error at " + token.getLine() + ":" 
                         + token.getCharPositionInLine() + " " + errorMsg);
                continue;
            }
            
            // Print valid tokens immediately
            System.out.println("Text:[" + text + "]-> Type: " + type 
                             + " (" + token.getLine() + ":" + token.getCharPositionInLine() + ")");
        }
        
        // Exact footer format requested
        System.out.println("----Lexical Errors : " + errors.size() + " -----");
        
        // Print all collected errors at the very end
        for (String err : errors) {
            System.out.println(err);
        }
    }

    private static String getErrorMessage(String type, String text) {
        switch (type) {
            case "UNTERMINATED_DOUBLE_STRING": return "Invalid or unexpected token (unterminated double-quoted string): " + text;
            case "UNTERMINATED_SINGLE_STRING": return "Invalid or unexpected token (unterminated single-quoted string): " + text;
            case "UNTERMINATED_TEMPLATE":      return "Invalid or unexpected token (unterminated template literal): " + text;
            case "UNTERMINATED_COMMENT":       return "Invalid or unexpected token (unterminated multi-line comment): " + text;
            case "INVALID_HEX":                return "Invalid or unexpected token (invalid hexadecimal literal): " + text;
            case "INVALID_BINARY":             return "Invalid or unexpected token (invalid binary literal): " + text;
            case "INVALID_OCTAL":              return "Invalid or unexpected token (invalid octal literal): " + text;
            case "INVALID_SEPARATOR":          return "Invalid or unexpected token (invalid numeric separator): " + text;
            case "INVALID_EXPONENT":           return "Invalid or unexpected token (invalid exponent): " + text;
            case "INVALID_BIGINT":             return "Invalid or unexpected token (invalid BigInt literal): " + text;
            case "INVALID_NUMBER_SUFFIX":      return "Invalid or unexpected token (identifier directly after number): " + text;
            case "ERROR_CHAR":                 return "Invalid or unexpected token: " + text;
            default: return null;
        }
    }
}