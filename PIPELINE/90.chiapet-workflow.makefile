SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: all

all: final_stats.done

FASTQ1 := $(sort \
  $(wildcard *_1*.fq.gz) \
  $(wildcard *_R1*.fq.gz) \
  $(wildcard *_R1*.fastq.gz) \
)

FASTQ2 := $(sort \
  $(wildcard *_2*.fq.gz) \
  $(wildcard *_R2*.fq.gz) \
  $(wildcard *_R2*.fastq.gz) \
)

linker_filtering.done: inputs.check $(FASTQ1) $(FASTQ2)
	@echo "[linker filtering]"
	bash ./10.filter_linker.pipe
	@touch $@

map_single_linker_2tags.done: linker_filtering.done
	@echo "[map single linker 2 tags]"
	bash ./22.map_single_linker_2tags.pipe
	@touch $@

map_single_linker_1tag.done: linker_filtering.done
	@echo "[map single linker 1 tag]"
	bash ./21.map_single_linker_1tag.pipe
	@touch $@

map_no_linker.done: linker_filtering.done
	@echo "[map no linker]"
	bash ./20.map_no_linker.pipe
	@touch $@

call_peaks.done: map_single_linker_2tags.done map_single_linker_1tag.done map_no_linker.done
	@echo "[call peaks]"
	bash ./30.call_peaks.pipe
	@touch $@

final_stats.done: call_peaks.done
	@echo "[extract summary stats]"
	bash ./40.extract_summary_stats.pipe
	@touch $@

inputs.check:
	@if [[ -z "$(FASTQ1)" ]]; then \
	  echo "Error: No R1 FASTQs found"; exit 1; \
	fi
	@if [[ -z "$(FASTQ2)" ]]; then \
	  echo "Error: No R2 FASTQs found"; exit 1; \
	fi
	@echo "R1 files: $(FASTQ1)"
	@echo "R2 files: $(FASTQ2)"
	@touch $@

clean:
	@rm -f *.done inputs.check
	@echo "[cleaned]"
