#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <math.h>


// Constants

const char* Digits = "0123456789";

//Token

typedef enum {
  TT_INT,
  TT_FLOAT,
  TT_PLUS,
  TT_MINUS,
  TT_MUL,
  TT_DIV,
  TT_STRING,
  TT_LPAREN,
  TT_RPAREN,
  TT_IDENTIFIER,
  TT_KEYWORD,
  TT_OPERATOR,
  TT_COMMENT,
  TT_INVALID
} TokenType;

typedef struct {
  TokenType type;
  char *value;
  bool value;
} Token;

Token makeToken(TokenType type){
  return (Token){
    .type = type,
  };
} 

Token makeTokenInt(int value){
  return (Token){
    .type= TT_INT,
  };
}

Token makeTokenFloat(TokenType type){
  return (Token){
    .type = TT_FLOAT,
  };
}

void printToken(){
  
}

// Position
typedef struct{
  int idx;
  int ln;
  int col;
  const char* fn;
  const char* ftxt;
} Position;

Position advance(Position* pos, char current_char){
  pos->idx++;
  pos->col++;

  if(current_char == '\n'){
    pos->ln++;
    pos->col = 0;
  }

  return *pos;
}

Position copy_position(Position* pos){
  return (Position){
    pos->idx,
    pos->ln,
    pos->col,
    pos->fn,
    pos->ftxt
  };
}

//Lexer
typedef struct{
  const char* fn;
  const char* text;
  Position pos;
  char current_char;
} Lexer;

void lexer_advance(Lexer* lexer){
  lexer->pos = advance(&lexer->pos, lexer->current_char);
  if(lexer->pos.idx < strlen(lexer->text))
    lexer->current_char = lexer->text[lexer->pos.idx];
  else
    lexer->current_char = '\0';
}

void lexer_number(Lexer* lexer){
  char num_str[32] = {0};
  int dot_count = 0;
  int i = 0;

  while (lexer->current_char != '\0' && (isdigit(lexer->current_char)||lexer->current_char == '.')){
    if(dot_count == 1)
  };
  
}


//Errors

int main(){

  return 0;
}




































