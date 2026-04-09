
#(chia-pipe) chia-pipe@ubuntu:/mnt/hgfs/chiapipe_simon/SIMON20210317/ANNO202103071958P1C1DIR$ rm SH02.PREP.sh 

datadir=${PWD}
CURDIR=$(pwd|rev|cut -d"/" -f1|rev)
SEQID=$(echo $CURDIR)

LIB=$(echo $CURDIR)




echo $CURDIR
echo $SEQID
echo $LIB





FC=${LIB}.cfg
echo "#!/bin/bash" > $FC
echo "LIB="${LIB} >>  $FC
echo "NTHREAD=14" >>  $FC
echo "datadir="${datadir} >>  $FC
echo "mainprog=/mnt/hgfs/chiapipe_simon/softwares/cpu" >>  $FC
echo "fasta=/mnt/hgfs/chiapipe_simon/ref_genome/mm10/mm10.fa" >>  $FC
echo "genome=/mnt/hgfs/chiapipe_simon/ref_genome/genome_size/mm10.size.txt" >>  $FC
echo "selfbp=8000" >>  $FC #self ligation in bp
echo "mapquality=30" >>  $FC #mapping quality cutoff
echo "extbp=500" >>  $FC #extension size from each ends in clustering PETs
cd $datadir

cat $FC



#cp ../PP20210422/*.pipe .
sleep 0.2
for FP in *.pipe
do
cat $FC $FP > TMP
sleep 0.2
mv TMP $FP

done
rm -rf TMP


chmod 755 *.pipe *.sh

  sed -i  's/-g hs/-g mm/g' 30.call_peaks.pipe
  sed -i  's/.no_input_all//g' 30.call_peaks.pipe

