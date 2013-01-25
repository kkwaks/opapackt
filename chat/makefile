OPA=opa
SRC_DIR=src
SRC_FILES=$(wildcard $(SRC_DIR)/*.opa)
BIN_DIR=bin
EXEC_NAME=chat.exe
EXEC=$(BIN_DIR)/$(EXEC_NAME)

default:
	clear
	$(OPA) $(SRC_FILES) -o $(EXEC)
run:
	clear
	$(BIN_DIR)/$(EXEC_NAME)
clean:
	rm -frv $(BUILD_DIRS)
	rm -frv $(BIN_DIR)
