#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <math.h>


typedef enum {
  TT_INT,
  TT_FLOAT,
  TT_STRING,
  TT_IDENTIFIER,
  TT_KEYWORD,
  TT_OPERATOR,
  TT_COMMENT
};

typedef struct {
  int type;
  char *value;
  bool value;
} Token;

// Position
typedef struct{
  int idx;
  int ln;
  int col;
  const char* fn;

} Position;


void advance_position(Position* pos,)


Token makeToken(TokenType type){
  return (Token){.type = type;
} 

Token makeTokenInt(int value){
  return (Token){
    .type= TT_INT,
  }
}

Token makeTokenFloat(TokenType type){
  return (Token){
    .type = TT_FLOAT,
  }
}

void printToken(){
  
}

int main(){

  return 0;
}




































