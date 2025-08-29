BUILD_DIR     = out
MAIN_BUILD    = $(BUILD_DIR)/main
TEST_BUILD    = $(BUILD_DIR)/test

SRC_MAIN      = src/main
SRC_TEST      = src/test

TOOLS_DIR     = tools
LIB_DIR       = lib

BUZZ_VERSION = 1.0.0
BUZZ_JAR     = $(LIB_DIR)/org.x96.sys.buzz.jar
BUZZ_URL     = https://github.com/x96-sys/buzz.java/releases/download/v$(BUZZ_VERSION)/org.x96.sys.buzz.jar
BUZZ_SHA256  = c4f30d580a9dea5db83f0dd0256de247ca217e62f401e5c06392c5b61909efa1

IO_VERSION = 1.1.0
IO_JAR     = $(LIB_DIR)/org.x96.sys.io.jar
IO_URL     = https://github.com/x96-sys/io.java/releases/download/v$(IO_VERSION)/org.x96.sys.io.jar
IO_SHA256  = e18d2fdb894386bd24bb08f178e4a6566d7feadaaf8e96d32bd6d9c5dc63c474

KIND_VERSION = 1.0.0
KIND_JAR     = $(LIB_DIR)/org.x96.sys.lexer.token.kind.jar
KIND_URL     = https://github.com/x96-sys/lexer.token.kind.java/releases/download/v$(KIND_VERSION)/org.x96.sys.lexer.token.kind.jar
KIND_SHA256  = 55d12618cd548099d138cbc1e7beda2b78e6a09382ec725523e82f7eb5a31c69

VISITOR_VERSION = 1.0.0
VISITOR_JAR     = $(LIB_DIR)/org.x96.sys.lexer.visitor.jar
VISITOR_URL     = https://github.com/x96-sys/lexer.visitor.java/releases/download/v$(VISITOR_VERSION)/org.x96.sys.lexer.visitor.jar
VISITOR_SHA256  = 2ae4d8669d15c965e30053a7d92a362ea1136c3ef3c3bacdcb9dbbc347bc977e

TOKENIZER_VERSION = 1.0.0
TOKENIZER_JAR     = $(LIB_DIR)/org.x96.sys.lexer.tokenizer.jar
TOKENIZER_URL     = https://github.com/x96-sys/lexer.tokenizer.java/releases/download/v$(TOKENIZER_VERSION)/org.x96.sys.lexer.tokenizer.jar
TOKENIZER_SHA256  = 21a10167ffd798f1fa9cbbda1382650a411c826b957bf3cc607863696bf4e8f7

JUNIT_VERSION = 1.13.4
JUNIT_JAR     = $(TOOLS_DIR)/junit-platform-console-standalone.jar
JUNIT_URL     = https://maven.org/maven2/org/junit/platform/junit-platform-console-standalone/$(JUNIT_VERSION)/junit-platform-console-standalone-$(JUNIT_VERSION).jar
JUNIT_SHA256  = 3fdfc37e29744a9a67dd5365e81467e26fbde0b7aa204e6f8bbe79eeaa7ae892

JACOCO_VERSION = 0.8.13
JACOCO_BASE    = https://maven.org/maven2/org/jacoco

JACOCO_CLI_VERSION = $(JACOCO_VERSION)
JACOCO_CLI_JAR     = $(TOOLS_DIR)/jacococli.jar
JACOCO_CLI_URL     = $(JACOCO_BASE)/org.jacoco.cli/$(JACOCO_CLI_VERSION)/org.jacoco.cli-$(JACOCO_CLI_VERSION)-nodeps.jar
JACOCO_CLI_SHA256  = 8f748683833d4dc4d72cea5d6b43f49344687b831e0582c97bcb9b984e3de0a3

JACOCO_AGENT_VERSION = $(JACOCO_VERSION)
JACOCO_AGENT_JAR     = $(TOOLS_DIR)/jacocoagent-runtime.jar
JACOCO_AGENT_URL     = $(JACOCO_BASE)/org.jacoco.agent/$(JACOCO_AGENT_VERSION)/org.jacoco.agent-$(JACOCO_AGENT_VERSION)-runtime.jar
JACOCO_AGENT_SHA256  = 47e700ccb0fdb9e27c5241353f8161938f4e53c3561dd35e063c5fe88dc3349b

GJF_VERSION = 1.28.0
GJF_JAR     = $(TOOLS_DIR)/gjf.jar
GJF_URL     = https://maven.org/maven2/com/google/googlejavaformat/google-java-format/$(GJF_VERSION)/google-java-format-$(GJF_VERSION)-all-deps.jar
GJF_SHA256  = 32342e7c1b4600f80df3471da46aee8012d3e1445d5ea1be1fb71289b07cc735

CP = $(VISITOR_JAR):$(TOKENIZER_JAR):$(KIND_JAR)

JAVA_SOURCES      = $(shell find $(SRC_MAIN) -name "*.java")
JAVA_TEST_SOURCES = $(shell find $(SRC_TEST) -name "*.java")

CPT = $(MAIN_BUILD):$(JUNIT_JAR):$(IO_JAR):$(CP):$(BUZZ_JAR)

DISTRO_JAR = org.x96.sys.lexer.entry.jar

gen: clean/gen
	@echo "[♦️] [generating] visitor classes"
	@ruby scripts/visitors.rb
	@ruby scripts/visitorsTest.rb
	@echo "[🧩] [generated] visitor classes"

build: libs clean/build/main gen
	@javac -d $(MAIN_BUILD) -cp $(CP) $(JAVA_SOURCES)
	@echo "[🧩] [compiled] in [$(MAIN_BUILD)]"

build/test: kit clean/build/test build
	@javac -d $(TEST_BUILD) -cp $(CPT) $(JAVA_TEST_SOURCES)
	@echo "[🤖] [compiled] in [$(TEST_BUILD)]"

test: build/test
	@java -jar $(JUNIT_JAR) \
     execute \
     --class-path $(TEST_BUILD):$(CPT) \
     --scan-class-path

coverage-run: build/test
	@java -javaagent:$(JACOCO_AGENT_JAR)=destfile=$(BUILD_DIR)/jacoco.exec \
       -jar $(JUNIT_JAR) \
       execute \
       --class-path $(TEST_BUILD):$(MAIN_BUILD):$(CPT) \
       --scan-class-path

coverage-report:
	@java -jar $(JACOCO_CLI_JAR) report \
     $(BUILD_DIR)/jacoco.exec \
     --classfiles $(MAIN_BUILD) \
     --sourcefiles $(SRC_MAIN) \
     --html $(BUILD_DIR)/coverage \
     --name "Coverage Report"

coverage: coverage-run coverage-report
	@echo "✅ Relatório de cobertura disponível em: build/coverage/index.html"
	@echo "🌐 Abrir com: open out/coverage/index.html"

define deps
$1/$2: $1
	@expected="$($3_SHA256)"; \
	jar="$($3_JAR)"; \
	url="$($3_URL)"; \
	tmp="$$$$(mktemp)"; \
	if [ ! -f "$$$$jar" ]; then \
		echo "[📦] [🚛] [$($3_VERSION)] [$2]"; \
		curl -sSL -o "$$$$tmp" "$$$$url"; \
		actual="$$$$(shasum -a 256 $$$$tmp | awk '{print $$$$1}')"; \
		if [ "$$$$expected" = "$$$$actual" ]; then mv "$$$$tmp" "$$$$jar"; \
		echo "[📦] [📍] [$($3_VERSION)] [$2] [🐚]"; else rm "$$$$tmp"; \
		echo "[❌] [hash mismatch] [$2]"; exit 1; fi; \
	else \
		actual="$$$$(shasum -a 256 $$$$jar | awk '{print $$$$1}')"; \
		if [ "$$$$expected" = "$$$$actual" ]; \
		then echo "[📦] [📍] [$($3_VERSION)] [🐚] [$2]"; \
		else \
			echo "[❌] [hash mismatch] [$2]"; \
			curl -sSL -o "$$$$tmp" "$$$$url"; \
			actual="$$$$(shasum -a 256 $$$$tmp | awk '{print $$$$1}')"; \
			if [ "$$$$expected" = "$$$$actual" ]; then mv "$$$$tmp" "$$$$jar"; \
			echo "[📦] [♻️] [$($3_VERSION)] [🐚] [$2]"; else rm "$$$$tmp"; \
			echo "[❌] [download failed] [$2]"; exit 1; fi; \
		fi; \
	fi
endef

$(LIB_DIR) $(TOOLS_DIR):
	@mkdir -p $@

libs: \
	$(LIB_DIR)/io \
	$(LIB_DIR)/kind \
	$(LIB_DIR)/visitor \
	$(LIB_DIR)/tokenizer \
	$(LIB_DIR)/buzz

$(eval $(call deps,$(LIB_DIR),io,IO))
$(eval $(call deps,$(LIB_DIR),kind,KIND))
$(eval $(call deps,$(LIB_DIR),visitor,VISITOR))
$(eval $(call deps,$(LIB_DIR),tokenizer,TOKENIZER))
$(eval $(call deps,$(LIB_DIR),buzz,BUZZ))

kit: \
	$(TOOLS_DIR)/junit \
	$(TOOLS_DIR)/gjf \
	$(TOOLS_DIR)/jacoco_cli \
	$(TOOLS_DIR)/jacoco_agent

$(eval $(call deps,$(TOOLS_DIR),junit,JUNIT))
$(eval $(call deps,$(TOOLS_DIR),gjf,GJF))
$(eval $(call deps,$(TOOLS_DIR),jacoco_cli,JACOCO_CLI))
$(eval $(call deps,$(TOOLS_DIR),jacoco_agent,JACOCO_AGENT))

distro: lib
	@jar cf $(DISTRO_JAR) -C $(MAIN_BUILD) .
	@echo "[📦] [🎯] $(DISTRO_JAR)"

clean/build/main:
	@rm -rf $(MAIN_BUILD)

clean/build/test:
	@rm -rf $(TEST_BUILD)

clean/gen:
	@rm -rf src/main/org/x96/sys/lexer/visitor/entry

clean: clean/gen
	@rm -rf $(BUILD_DIR)
	@rm -rf $(LIB_DIR)
	@rm -rf $(TOOLS_DIR)

