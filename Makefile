AS      = aarch64-linux-gnu-as
LD      = aarch64-linux-gnu-ld
QEMU    = qemu-aarch64

SRC_DIR   = src
BUILD_DIR = build
TARGET    = $(BUILD_DIR)/motor

SRCS = $(wildcard $(SRC_DIR)/*.s)
OBJS = $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(SRCS))

all: $(TARGET)

$(TARGET): $(OBJS) | $(BUILD_DIR)
	$(LD) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | $(BUILD_DIR)
	$(AS) -g -o $@ $<

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

run: $(TARGET)
	$(QEMU) ./$(TARGET)

debug: $(TARGET)
	$(QEMU) -g 1234 ./$(TARGET)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean
