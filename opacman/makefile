OPA=opa
SRC_DIR=src
SRC_FILES=$(wildcard $(SRC_DIR)/*.opa)
PLUGIN_DIR=plugins
PLUGIN_FILES=$(PLUGIN_DIR)/Preloader.js
PLUGIN_OPT=--js-bypass-syntax jsdoc
BIN_DIR=bin
EXEC_NAME=opacman.exe
EXEC=$(BIN_DIR)/$(EXEC_NAME)

default:
	clear
	$(OPA) $(PLUGIN_FILES) $(PLUGIN_OPT) $(SRC_FILES) -o $(EXEC)
run:
	clear
	$(BIN_DIR)/$(EXEC_NAME)
clean:
	rm -frv $(BUILD_DIRS)
	rm -frv $(BIN_DIR)
