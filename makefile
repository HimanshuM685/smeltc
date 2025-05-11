ASM = nasm
LD = ld
SRC = src
BUILD = build

OBJS = $(BUILD)/main.o $(BUILD)/io.o $(BUILD)/utils.o 
OUT = $(BUILD)/program

all: $(OUT)

$(BUILD)/%.o: $(SRC)/%.asm
	mkdir -p $(BUILD)
	$(ASM) -f elf64 $< -o $@

$(OUT): $(OBJS)
	$(LD) $(OBJS) -o $(OUT)

run: all
	./$(OUT)

clean:
	rm -rf $(BUILD)
