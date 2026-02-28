.PHONY: gates demo

gates:
	bash scripts/verify_arch_gate.sh
	bash scripts/verify_api_gate.sh

demo:
	bash scripts/demo.sh
