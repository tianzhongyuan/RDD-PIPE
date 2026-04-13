#echo "please input the forlder of FASTQ"
#echo  "FASTQ file should like this: rHG011_1.fq.gz rHG011_2.fq.gz"
#read DFQ
DFQ=$1
echo $DFQ


#echo "please input the forlder of SH"
#read DSH
DSH=$2
echo $DSH

#echo "please input the forlder of pipeline"
DPP=$3
echo $DPP

for F in $DFQ/*_1.fq.gz
do
NAME=$(ls $F|rev|cut -d"/" -f1|rev|cut -d"_" -f1)
echo $NAME
#rm -rf $NAME
mkdir $NAME
cd $NAME

echo $NAME
ln -s ../$DFQ/${NAME}_1.fq.gz ${NAME}_1.fq.gz
ln -s ../$DFQ/${NAME}_2.fq.gz ${NAME}_2.fq.gz
cp ../$DSH/* .
cp ../$DPP/* .
sleep 0.01

sh 00.config.sh 
sleep 0.01
sh 01.runpipe.sh
sleep 0.01
cd ../


done


