; Function prototypes
extern lexer_init
extern lexer_adv
extern lexer_make_tokens
extern lexer_make_num 
extern position_init
extern position_adv
extern position_copy
extern token_create
extern error_create
extern is_digit
extern is_whitespace
extern print_tokens
extern print_error
extern parser_parse

;glo data section 
extern lexer_instance
extern token_buffer 
extern error_buffer
extern temp_buffer
extern digits_str
extern ast_buffer
