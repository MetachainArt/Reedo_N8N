.PHONY: export report report-last

export:
	./scripts/export_all.sh

report:
	./scripts/report_changes.sh

report-last:
	./scripts/report_changes.sh HEAD~1 HEAD
