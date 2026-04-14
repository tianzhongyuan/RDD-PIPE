#!/usr/bin/env bash
set -euo pipefail

DC="/home/claw3dg/3DgenomeClaw"
ls -l /mnt/hgfs/VMSHARE/*fastq.gz


echo_yellow0() {
	local msg="$1"
	echo -e "\033[0;33m${msg}\033[0m"
    }



# FASTQ
read -r -p "please input fastq-01 with path: " DFQ1
echo_yellow0 "FQ-1 input: $DFQ1"
read -r -p "please input fastq-02 with path: " DFQ2
echo_yellow0 "FQ-2 input: $DFQ2"


# LIB-ID (从 DFQ1 自动提取默认)
LIB0="$(echo "$DFQ1" | cut -d'.' -f1 | cut -d'_' -f1 | rev | cut -d'/' -f1 | rev)"
echo "default LIB-ID: $LIB0 , if you want to manually define LIB ID please enter: "
read -r -p "Input LIB-ID (default: $LIB0): " LIB
LIB="${LIB:-$LIB0}"


mkdir -p ${DC}/data
DIRLIB=${DC}/data/$LIB
rm -rf $DIRLIB
mkdir $DIRLIB
cd $DIRLIB


FC="${LIB}.cfg"
echo "#!/bin/bash" > "$FC"
echo_yellow() {
	local msg="$1"
	local config_file="$FC"
	echo -e "\033[0;33m${msg}\033[0m"
	echo "${msg}" >> "$config_file"
	}
echo_yellow "LIB=${LIB}"
echo_yellow "FQ1=${DFQ1}"
echo_yellow "FQ2=${DFQ2}"
ln -s ${DFQ1} ${LIB}_1.fq.gz
ln -s ${DFQ1} ${LIB}_2.fq.gz




#LINKER
read -r -p "input linker(liner01=RDD,linker02=ChIA-PET default=linker01): " LNK
LNK="${LNK:-linker01}"
case "$LNK" in linker01|linker02) ;;*) echo "Invalid input ($LNK), using default linker01"; LNK="linker01" ;;	
esac
echo_yellow "linker=$LNK"

# REF-GENOME
read -r -p "please input ref-genome(dm3, hg38, mm10, ...,default dm3): " REF
REF="${REF:-dm3}"
echo_yellow "fasta=${DC}/tools/genomes/$REF/$REF.genome.fa"
echo_yellow "genome=${DC}/RDD-PIPE/genome_size/${REF}.size.txt"
#head ${DC}/RDD-PIPE/genome_size/${REF}.size.txt

#CPU
# 计算 NTHREAD（比如至少 1）
NTHREAD=$(( $(nproc) - 2 ))
(( NTHREAD < 1 )) && NTHREAD=1

echo "Current avialiable theard number：$NTHREAD (use all default)"
read -r -p "total NTHREAD=$NTHREAD,use all defaultly, haw many do you want ? (enter = $NTHREAD): " NTHREAD_IN

NTHREAD="${NTHREAD_IN:-$NTHREAD}"
# 可选：再做一次合法性校验
if ! [[ "$NTHREAD" =~ ^[0-9]+$ ]]; then
   echo_yellow "input int please，using default：$NTHREAD"
   NTHREAD="$NTHREAD"
fi
(( NTHREAD < 1 )) && NTHREAD=1
(( NTHREAD > $(nproc) )) && NTHREAD=$(nproc)
echo_yellow "NTHREAD=$NTHREAD"


# chia-pipe main programm
mainprog="${DC}/tools/ChIA-PIPE/util/cpu-dir/cpu-dir/cpu"
echo_yellow "mainprog=$mainprog"


# self-ligation
selfbp=""
species=""
if [[ "$REF" == "dm3" ]]; then
    selfbp=3000
    species="dm"
  elif [[ "$REF" == "hg38" ]]; then
    selfbp=8000
    species="hs"
  elif [[ "$REF" == "mm10" ]]; then
    selfbp=8000
    species="mm"
fi

read -r -p "please input self-ligation threashold (current genome is: ${REF}, selfbp = ${selfbp}): " SELF
SELF="${SELF:-${selfbp}}"
echo_yellow "selfbp=$SELF"
echo_yellow "species=$species"


mapquality=30
read -r -p "default MAPQ== ${mapquality}, if not please enter: " MAPQ
MAPQ="${MAPQ:-${mapquality}}"
echo_yellow "mapquality=$MAPQ"

extbp=500
read -r -p "default tag-extention== ${extbp}, if not please enter: " TAGE
TAGE="${TAGE:-${extbp}}"
echo_yellow "extbp=$TAGE"


ls -l ${PWD}/$FC
cat $FC

echo "#########"

cp ${DC}/RDD-PIPE/PIPELINE/01.run_make.sh .
cp ${DC}/RDD-PIPE/PIPELINE/90.chiapet-workflow.makefile .

for PP in ${DC}/RDD-PIPE/PIPELINE/*.pi
do
  out_file="$(ls $PP|rev|cut -d"/" -f1|rev)pe"
  cat $FC $PP > $out_file
done

ls -lrt
sleep 0.01
nohup bash 01.run_make.sh >> "${LIB}.log" 2>&1 &


