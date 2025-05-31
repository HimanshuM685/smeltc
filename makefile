ASM = nasm
LD = ld

ASM_FLAGS = -f elf32 -I include/
LD_FLAGS = -m elf_i386

SRC_DIR = src
BUILD_DIR = build
INCLUDE_DIR = include

SRC_FILES = $(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES = $(SRC_FILES:$(SRC_DIR)/%.asm=$(BUILD_DIR)/%.o)

TARGET = $(BUILD_DIR)/basic_lexer

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) $< -o $@

$(TARGET): $(OBJ_FILES)
	$(LD) $(LD_FLAGS) $^ -o $@

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	./$(TARGET)

debug: ASM_FLAGS += -g -F dwarf
debug: $(TARGET)

test: $(TARGET)
	@echo "Testing lexer with sample input..."
	@echo "3 + 4 * 2" | ./$(TARGET)
	@echo "Testing complete."

install: $(TARGET)
	sudo cp $(TARGET) /usr/local/bin/basic_lexer

uninstall:
	sudo rm -f /usr/local/bin/basic_lexer

help:
	@echo "Available targets:"
	@echo "  all      - Build the lexer (default)"
	@echo "  clean    - Remove build artifacts"
	@echo "  run      - Build and run the lexer"
	@echo "  debug    - Build with debug symbols"
	@echo "  test     - Build and run basic tests"
	@echo "  install  - Install to system (requires sudo)"
	@echo "  uninstall- Remove from system (requires sudo)"
	@echo "  help     - Show this help message"

$(BUILD_DIR)/main.o: $(INCLUDE_DIR)/macros.inc $(INCLUDE_DIR)/lexer.inc
$(BUILD_DIR)/lexer.o: $(INCLUDE_DIR)/macros.inc
$(BUILD_DIR)/io.o: $(INCLUDE_DIR)/macros.inc

.PHONY: all clean run debug test install uninstall help