#!/bin/bash
#SBATCH --partition=bahl_p
#SBATCH --job-name=nextstrain
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=60gb
#SBATCH --time=72:00:00
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --mail-user=ll22780@uga.edu
#SBATCH --mail-type=END,FAIL

source ~/.bashrc
mypath=$(pwd)
mkdir $1
cd $1 
git clone https://github.com/nextstrain/ncov.git --branch v12
cd ncov
git clone https://github.com/leke-lyu/surveillanceInTexas.git
rm defaults/lat_longs.tsv
cp surveillanceInTexas/lat_longs.tsv defaults/
m=0
n=0
for i in "${@:2}"
do
	if [[ $i == contextual* ]]
	then
		Rscript $mypath"/scripts/editContextual.R" $mypath"/04_genomes" surveillanceInTexas/data $i
        	cp $mypath"/04_genomes/"$i".sequences.fasta" surveillanceInTexas/data
		line1=" - name: \"context_"$m"\""
        	sed -i -e "2i\ ${line1}" surveillanceInTexas/builds.yaml		
		sed -i '/  - name: "context_'"$m"'"/a \    metadata: \"surveillanceInTexas\/data\/'"$i"'.metadata.tsv\"' surveillanceInTexas/builds.yaml
                sed -i '/  - name: "context_'"$m"'"/a \    sequences: \"surveillanceInTexas\/data\/'"$i"'.sequences.fasta\"' surveillanceInTexas/builds.yaml
		m=`expr $m + 1`
	else
		Rscript $mypath"/scripts/editMetadata.R" $mypath"/04_genomes" surveillanceInTexas/data $i
        	cp $mypath"/04_genomes/"$i".sequences.fasta" surveillanceInTexas/data
		line1=" - name: \"focus_"$n"\""
		sed -i -e "2i\ ${line1}" surveillanceInTexas/builds.yaml
		sed -i '/  - name: "focus_'"$n"'"/a \    metadata: \"surveillanceInTexas\/data\/'"$i"'.metadata.tsv\"' surveillanceInTexas/builds.yaml
		sed -i '/  - name: "focus_'"$n"'"/a \    sequences: \"surveillanceInTexas\/data\/'"$i"'.sequences.fasta\"' surveillanceInTexas/builds.yaml
		n=`expr $n + 1`
	fi
done
#nextstrain build . --configfile surveillanceInTexas/builds.yaml --cores 32
# how to use? type: sh sub.sh 12k_00 5k_00 5k_01 contextual_6k_00 contextual_6k_01
