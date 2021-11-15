parallel-compile=kclvm hack/compile-rocket.py

# 编译所有业务应用
check-biz:
	@${parallel-compile} all

# 编译关键字匹配的目录
check-%:
	@${parallel-compile} $*

# Build and run tests.
#
# Args:
#   WHAT: Project directory names to test.
#
# Example:
#   make check WHAT=cafeextcontroller
#   make check WHAT="cafeextcontroller infraform"
#   make check WHAT=samples
check:
	@${parallel-compile} $(WHAT)

clean-all:
	@echo "cleaning kcl cache..."
	@rm -rf ./.kclvm
	@echo "cleaning test cache..."
	@find . -name .pytest_cache  | xargs rm -rf
	@echo "clean finished."