#!/usr/bin/env bash
set -euo pipefail

LIB="${1:-${LIB:-$(basename "$PWD")}}"
OUT="${2:-${LIB}.library_read_stats.tsv}"
NTHREAD="${3:-${NTHREAD:-4}}"

need_samtools=0
if ! command -v samtools >/dev/null 2>&1; then
    need_samtools=1
fi

warn() {
    printf 'WARNING: %s\n' "$*" >&2
}

stat_value() {
    local pattern="$1"
    local file="${LIB}.stat"

    if [ ! -s "$file" ]; then
        warn "missing $file"
        printf 'NA'
        return
    fi

    awk -v pat="$pattern" '
        index($0, pat) { print $3; found=1; exit }
        END { if (!found) print "NA" }
    ' "$file"
}

bam_count() {
    local file="$1"

    if [ "$need_samtools" -eq 1 ]; then
        warn "samtools not found; cannot count $file"
        printf 'NA'
        return
    fi

    if [ ! -s "$file" ]; then
        warn "missing $file"
        printf 'NA'
        return
    fi

    samtools view -@ "$NTHREAD" -c "$file"
}

mapped_sam_count() {
    local file="$1"

    if [ "$need_samtools" -eq 1 ]; then
        warn "samtools not found; cannot count $file"
        printf 'NA'
        return
    fi

    if [ ! -s "$file" ]; then
        warn "missing $file"
        printf 'NA'
        return
    fi

    samtools view -@ "$NTHREAD" -F 4 -c "$file"
}

sum_numbers_or_na() {
    local total=0
    local value

    for value in "$@"; do
        if [ "$value" = "NA" ]; then
            printf 'NA'
            return
        fi
        total=$((total + value))
    done

    printf '%s' "$total"
}

total_read_pairs=$(stat_value "Total pairs")
read_pairs_with_linker=$(stat_value "Linker detected")

mappable_0linker_reads=$(mapped_sam_count "${LIB}.none.sam.gz")
mappable_1linker1tag_reads=$(mapped_sam_count "${LIB}.singlelinker.single.sam.gz")
mappable_1linker2tags_reads=$(mapped_sam_count "${LIB}.singlelinker.paired.sam.gz")
mappable_total_reads=$(sum_numbers_or_na \
    "$mappable_0linker_reads" \
    "$mappable_1linker1tag_reads" \
    "$mappable_1linker2tags_reads")

uniq_mapped_0linker_reads=$(bam_count "${LIB}.none.UU.bam")
uniq_mapped_1linker1tag_reads=$(bam_count "${LIB}.singlelinker.single.UxxU.bam")
uniq_mapped_1linker2tags_reads=$(bam_count "${LIB}.singlelinker.paired.UU.bam")
uniq_mapped_total_reads=$(sum_numbers_or_na \
    "$uniq_mapped_0linker_reads" \
    "$uniq_mapped_1linker1tag_reads" \
    "$uniq_mapped_1linker2tags_reads")

uniq_mapped_rmdup_0linker_reads=$(bam_count "${LIB}.none.UU.nr.bam")
uniq_mapped_rmdup_1linker1tag_reads=$(bam_count "${LIB}.singlelinker.single.UxxU.nr.bam")
uniq_mapped_rmdup_1linker2tags_reads=$(bam_count "${LIB}.singlelinker.paired.UU.nr.bam")
uniq_mapped_rmdup_total_reads=$(sum_numbers_or_na \
    "$uniq_mapped_rmdup_0linker_reads" \
    "$uniq_mapped_rmdup_1linker1tag_reads" \
    "$uniq_mapped_rmdup_1linker2tags_reads")

{
    printf 'metric\tvalue\n'
    printf 'Total_read_pairs\t%s\n' "$total_read_pairs"
    printf 'Read_pairs_with_linker\t%s\n' "$read_pairs_with_linker"
    printf 'mappable_0linker_reads\t%s\n' "$mappable_0linker_reads"
    printf 'mappable_1linker1tag_reads\t%s\n' "$mappable_1linker1tag_reads"
    printf 'mappable_1linker2tags_reads\t%s\n' "$mappable_1linker2tags_reads"
    printf 'mappable_total_reads\t%s\n' "$mappable_total_reads"
    printf 'Uniq_mapped_0linker_reads\t%s\n' "$uniq_mapped_0linker_reads"
    printf 'Uniq_mapped_1linker1tag_reads\t%s\n' "$uniq_mapped_1linker1tag_reads"
    printf 'Uniq_mapped_1linker2tags_reads\t%s\n' "$uniq_mapped_1linker2tags_reads"
    printf 'Uniq_mapped_total_reads\t%s\n' "$uniq_mapped_total_reads"
    printf 'Uniq_mapped_rmDup_0linker_reads\t%s\n' "$uniq_mapped_rmdup_0linker_reads"
    printf 'Uniq_mapped_rmDup_1linker1tag_reads\t%s\n' "$uniq_mapped_rmdup_1linker1tag_reads"
    printf 'Uniq_mapped_rmDup_s1linker2tags_reads\t%s\n' "$uniq_mapped_rmdup_1linker2tags_reads"
    printf 'Uniq_mapped_rmDup_total_reads\t%s\n' "$uniq_mapped_rmdup_total_reads"
} > "$OUT"

cat "$OUT"

