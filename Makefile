BUILD_DIR     = build
MAIN_BUILD    = $(BUILD_DIR)/main
TEST_BUILD    = $(BUILD_DIR)/test

SRC_MAIN      = src/main
SRC_TEST      = src/test

TOOL_DIR      = tools
LIB_DIR       = lib

CS_KIND_VERSION = 0.1.3
CS_KIND_JAR     = $(LIB_DIR)/org.x96.sys.foundation.cs.lexer.token.kind.jar
CS_KIND_URL     = https://github.com/x96-sys/cs.lexer.token.kind.java/releases/download/0.1.3/org.x96.sys.foundation.cs.lexer.token.kind.jar

CS_VISITOR_VERSION = 0.1.2
CS_VISITOR_JAR = $(LIB_DIR)/org.x96.sys.foundation.cs.lexer.visitor.jar
CS_VISITOR_URL = https://github.com/x96-sys/cs.lexer.visitor.java/releases/download/v$(CS_VISITOR_VERSION)/org.x96.sys.foundation.cs.lexer.visitor.jar

CS_TOKENIZER_VERSION = 0.1.6
CS_TOKENIZER_JAR     = $(LIB_DIR)/org.x96.sys.foundation.cs.lexer.tokenizer.jar
CS_TOKENIZER_URL     = https://github.com/x96-sys/cs.lexer.tokenizer.java/releases/download/v$(CS_TOKENIZER_VERSION)/org.x96.sys.foundation.cs.lexer.tokenizer.jar

JUNIT_VERSION = 1.13.4
JUNIT_JAR     = $(TOOL_DIR)/junit-platform-console-standalone.jar
JUNIT_URL     = https://maven.org/maven2/org/junit/platform/junit-platform-console-standalone/$(JUNIT_VERSION)/junit-platform-console-standalone-$(JUNIT_VERSION).jar

CS_FLUX_VERSION = 1.0.1
CS_FLUX_JAR     = $(LIB_DIR)/org.x96.sys.foundation.io.jar
CS_FLUX_URL     = https://github.com/x96-sys/flux.java/releases/download/v$(CS_FLUX_VERSION)/org.x96.sys.foundation.io.jar

JACOCO_VERSION = 0.8.13
JACOCO_BASE    = https://maven.org/maven2/org/jacoco

JACOCO_CLI_VERSION = $(JACOCO_VERSION)
JACOCO_CLI_JAR     = $(TOOL_DIR)/jacococli.jar
JACOCO_CLI_URL     = $(JACOCO_BASE)/org.jacoco.cli/$(JACOCO_CLI_VERSION)/org.jacoco.cli-$(JACOCO_CLI_VERSION)-nodeps.jar

JACOCO_AGENT_VERSION = $(JACOCO_VERSION)
JACOCO_AGENT_JAR     = $(TOOL_DIR)/jacocoagent-runtime.jar
JACOCO_AGENT_URL     = $(JACOCO_BASE)/org.jacoco.agent/$(JACOCO_AGENT_VERSION)/org.jacoco.agent-$(JACOCO_AGENT_VERSION)-runtime.jar

CP = $(CS_VISITOR_JAR):$(CS_TOKENIZER_JAR):$(CS_KIND_JAR)

JAVA_SOURCES      = $(shell find $(SRC_MAIN) -name "*.java")
JAVA_TEST_SOURCES = $(shell find $(SRC_TEST) -name "*.java")

CPT = $(MAIN_BUILD):$(JUNIT_JAR):$(CS_FLUX_JAR):$(CP)

DISTRO_JAR = org.x96.sys.foundation.cs.lexer.entry.jar

build: libs
	@javac -d $(MAIN_BUILD) -cp $(CP) $(JAVA_SOURCES)
	@echo "[🧩] [build] [$(MAIN_BUILD)] successfully!"

build-test: tools/junit lib/flux build
	@javac -d $(TEST_BUILD) -cp $(CPT) $(JAVA_TEST_SOURCES)
	@echo "[🤖] [build-test] [$(TEST_BUILD)] successfully!"

test: build-test
	@java -jar $(JUNIT_JAR) \
     execute \
     --class-path $(TEST_BUILD):$(CPT) \
     --scan-class-path

coverage-run: build-test tools/jacoco
	@java -javaagent:$(JACOCO_AGENT_JAR)=destfile=$(BUILD_DIR)/jacoco.exec \
       -jar $(JUNIT_JAR) \
       execute \
       --class-path $(TEST_BUILD):$(MAIN_BUILD):$(CPT) \
       --scan-class-path

coverage-report: tools/jacoco
	@java -jar $(JACOCO_CLI_JAR) report \
     $(BUILD_DIR)/jacoco.exec \
     --classfiles $(MAIN_BUILD) \
     --sourcefiles $(SRC_MAIN) \
     --html $(BUILD_DIR)/coverage \
     --name "Coverage Report"

coverage: coverage-run coverage-report
	@echo "✅ Relatório de cobertura disponível em: build/coverage/index.html"
	@echo "🌐 Abrir com: open build/coverage/index.html"

define deps
$1/$2: $1
	@if [ ! -f "$$($3_JAR)" ]; then \
		echo "[📦] [🚛] [$$($3_VERSION)] [$2]"; \
		curl -sSL -o $$($3_JAR) $$($3_URL); \
	else \
		echo "[📦] [📍] [$$($3_VERSION)] [$2]"; \
	fi
endef

libs: lib/kind lib/visitor lib/tokenizer

$(eval $(call deps,lib,flux,CS_FLUX))
$(eval $(call deps,lib,kind,CS_KIND))
$(eval $(call deps,lib,visitor,CS_VISITOR))
$(eval $(call deps,lib,tokenizer,CS_TOKENIZER))
$(eval $(call deps,tools,junit,JUNIT))

tools/jacoco: tools/jacoco_cli tools/jacoco_agent

$(eval $(call deps,tools,jacoco_cli,JACOCO_CLI))
$(eval $(call deps,tools,jacoco_agent,JACOCO_AGENT))

$(LIB_DIR) $(TOOL_DIR):
	@mkdir -p $@

distro: lib
	@jar cf $(DISTRO_JAR) -C $(MAIN_BUILD) .
	@echo "[📦] [🎯] $(DISTRO_JAR)"

clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf src/main/org/x96/sys/foundation/cs/lexer/visitor/entry
	@rm -rf src/test/org/x96/sys/foundation/cs/lexer/visitor/entry/terminals/c*
