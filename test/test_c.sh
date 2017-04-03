## 2D
bin/pairix -f -s2 -d6 -b3 -e3 -u7 samples/merged_nodup.tab.chrblock_sorted.txt.gz
bin/pairix samples/merged_nodup.tab.chrblock_sorted.txt.gz '10:1-1000000|20' > log1
gunzip -c samples/merged_nodup.tab.chrblock_sorted.txt.gz | awk '$2=="10" && $3>=1 && $3<=1000000 && $6=="20"' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi

bin/pairix samples/merged_nodup.tab.chrblock_sorted.txt.gz '10:1-1000000|20:50000000-60000000' > log1
gunzip -c samples/merged_nodup.tab.chrblock_sorted.txt.gz | awk '$2=="10" && $3>=1 && $3<=1000000 && $6=="20" && $7>=50000000 && $7<=60000000' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi

bin/pairix samples/merged_nodup.tab.chrblock_sorted.txt.gz '1:1-10000000|20:50000000-60000000' '3:5000000-9000000|X:70000000-90000000' > log1
gunzip -c samples/merged_nodup.tab.chrblock_sorted.txt.gz | awk '$2=="1" && $3>=1 && $3<=10000000 && $6=="20" && $7>=50000000 && $7<=60000000' > log2
gunzip -c samples/merged_nodup.tab.chrblock_sorted.txt.gz | awk '$2=="3" && $3>=5000000 && $3<=9000000 && $6=="X" && $7>=70000000 && $7<=90000000' >> log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi

bin/pairix samples/merged_nodup.tab.chrblock_sorted.txt.gz '*|1:0-100000' > log1
gunzip -c samples/merged_nodup.tab.chrblock_sorted.txt.gz | awk '$6=="1" && $7>=0 && $7<=100000' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi

bin/pairix samples/merged_nodup.tab.chrblock_sorted.txt.gz '1:0-100000|*' > log1
gunzip -c samples/merged_nodup.tab.chrblock_sorted.txt.gz | awk '$2=="1" && $3>=0 && $3<=100000' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi


## 1D
bin/pairix -s1 -b2 -e2 -f samples/SRR1171591.variants.snp.vqsr.p.vcf.gz
bin/pairix samples/SRR1171591.variants.snp.vqsr.p.vcf.gz chr10:1-4000000 > log1
gunzip -c samples/SRR1171591.variants.snp.vqsr.p.vcf.gz | awk '$1=="chr10" && $2>=1 && $2<=4000000' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi


## 2D, space-delimited
bin/pairix -f -s2 -d6 -b3 -e3 -u7 -T samples/merged_nodups.space.chrblock_sorted.subsample1.txt.gz
bin/pairix samples/merged_nodups.space.chrblock_sorted.subsample1.txt.gz '10:1-1000000|20' > log1
gunzip -c samples/merged_nodups.space.chrblock_sorted.subsample1.txt.gz | awk '$2=="10" && $3>=1 && $3<=1000000 && $6=="20"' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi


## preset for pairs.gz
bin/pairix -f samples/test_4dn.pairs.gz
bin/pairix samples/test_4dn.pairs.gz 'chr10|chr20' > log1
gunzip -c samples/test_4dn.pairs.gz | awk '$2=="chr10" && $4=="chr20"' > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi


## process merged_nodups
source util/process_merged_nodup.sh samples/test_merged_nodups.txt
bin/pairix samples/test_merged_nodups.txt.bsorted.gz '10|20' > log1
awk '$2=="10" && $6=="20"' samples/test_merged_nodups.txt > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi

## process old merged_nodups
source util/process_old_merged_nodup.sh samples/test_old_merged_nodups.txt
bin/pairix samples/test_old_merged_nodups.txt.bsorted.gz '10|20' > log1
awk '$3=="10" && $7=="20"' samples/test_old_merged_nodups.txt > log2
if [ ! -z "$(diff log1 log2)" ]; then
  return 1;
fi


## pairs_merger
bin/pairs_merger samples/merged_nodups.space.chrblock_sorted.subsample2.txt.gz samples/merged_nodups.space.chrblock_sorted.subsample3.txt.gz | bin/bgzip -c > out.gz
bin/pairix -f -s2 -d6 -b3 -e3 -u7 -T out.gz
# compare with the approach of concatenating and resorting.
chmod +x test/inefficient-merger-for-testing
test/inefficient-merger-for-testing . out2 merged_nodups samples/merged_nodups.space.chrblock_sorted.subsample2.txt.gz samples/merged_nodups.space.chrblock_sorted.subsample3.txt.gz
gunzip -f out2.bsorted.pairs.gz 
gunzip -f out.gz
if [ ! -z "$(diff out out2.bsorted.pairs)" ]; then 
  return 1;
fi
rm -f out out2.bsorted.pairs out2.pairs out.gz.px2 out2.bsorted.pairs.gz.px2

echo 'haha'

## streamer_1d
bin/streamer_1d samples/merged_nodups.space.chrblock_sorted.subsample2.txt.gz | bin/bgzip -c > out.1d.pairs.gz
gunzip -c samples/merged_nodups.space.chrblock_sorted.subsample2.txt.gz | sort -t' ' -k2,2 -k3,3g | bin/bgzip -c > out2.1d.pairs.gz
gunzip -f out.1d.pairs.gz
gunzip -f out2.1d.pairs.gz
if [ ! -z "$(diff out.1d.pairs out2.1d.pairs)" ]; then
  return 1;
fi
rm -f out.1d.pairs out2.1d.pairs

