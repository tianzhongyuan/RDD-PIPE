ls -rd FQ*/ SH-*/ PP-*/ RUN0*.sh|grep -v ".log"|grep -v "START"|grep -v "sta"|cut -d"/" -f1


echo "please input the forlder of FASTQ"
echo  "FASTQ file should like this: rHG011_1.fq.gz rHG011_2.fq.gz"
read DFQ
echo $DFQ


echo "please input the forlder of SH"
read DSH
echo $DSH


echo "please input the forlder of pipeline"
read DPP
echo $DPP

TIME=`date +%Y%m%d-%H%M%S`

touch $DFQ.$TIME.START...
echo "sh RUN01-RUNNING.sh "$DFQ" "$DSH" "$DPP"  > "$DFQ".log 2>&1 &" >  $DFQ.$TIME.START...
echo "sh RUN01-RUNNING.sh $DFQ $DSH $DPP  > $DFQ.log 2>&1 &" >  $DFQ.$TIME.log
nohup sh RUN01-RUNNING.sh $DFQ $DSH $DPP >> $DFQ.$TIME.log 2>&1 & 
