CC := gcc
LD := gcc

CFLAGS := -Wall -Wextra -Werror -g -pedantic -Wvla
LDFLAGS :=
CPPFLAGS := -MMD
LDLIBS :=

LDFLAGS += -fsanitize=address
CFLAGS += -fsanitize=address

BUILD := build
TARGET := minimake
TEST := test


C_FILES := $(shell find src/ -type f -name "*.c")
O_FILES := $(C_FILES:%.c=$(BUILD)/%.o)
D_FILES := $(O_FILES:%.o=%.d)

TEST_C_FILES := $(shell find src/ tests/ -type f -name "*.c" ! -wholename "src/main.c")
TEST_O_FILES := $(TEST_C_FILES:%.c=$(BUILD_TEST)/%.o)
TEST_D_FILES := $(TEST_O_FILES:%.o=%.d)

SRCDIRS := $(shell find src/ tests/ -type d)
$(shell mkdir -p $(SRCDIRS:%=$(BUILD)/%))

all: $(TARGET)


check: $(TEST)
	./$(TEST)

format:
	clang-format -i $(C_FILES) $(C_TEST_FILES)

clean:
	${RM} -rf $(BUILD) $(TARGET) $(TEST)

.PHONY: all clean check minimake


$(TARGET): $(O_FILES)
	$(LD) $(LDFLAGS) $(LDLIBS) -o $@ $^

$(BUILD)/%.o: ./%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

$(TEST): $(TEST_O_FILES)
	$(LD) -fsanitize=address -g $(LDFLAGS) $(LDLIBS) -o $@ $^

$(BUILD_TEST)/%.o: ./%.c
	$(CC) -fsanitize=address -g -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

-include $(D_FILES)
