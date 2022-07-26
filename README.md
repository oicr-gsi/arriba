# arriba

Workflow that takes the Bam output from STAR and detects RNA-seq fusion events.

## Overview

## Dependencies

* [arriba 1.2](https://github.com/suhrig/arriba)
* [star 2.7.3a](https://github.com/alexdobin/STAR)
* [samtools 1.9](http://www.htslib.org/)


## Usage

### Cromwell
```
java -jar cromwell.jar run arriba.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`inputGroups`|Array[InputGroup]|Array of fastq files to align with STAR and the merged filename
`outputFileNamePrefix`|String|Prefix for filename


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`structuralVariants`|File?|None|path to structural variants for sample


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runArriba.star`|String|"$STAR_ROOT/bin/STAR"|Path to STAR binary
`runArriba.index`|String|"$HG38_STAR_INDEX100_ROOT"|Path to STAR index
`runArriba.arriba`|String|"$ARRIBA_ROOT/bin/arriba"|Name of the Arriba binary
`runArriba.draw`|String|"$ARRIBA_ROOT/bin/draw_fusions.R"|path to arriba draw command
`runArriba.samtools`|String|"$SAMTOOLS_ROOT/bin/samtools"|path to samtools binary
`runArriba.modules`|String|"arriba/1.2 hg38-star-index100/2.7.3a rarriba/0.1 hg38-cosmic-fusion/v91"|Names and versions of modules to load
`runArriba.gencode`|String|"$GENCODE_ROOT/gencode.v31.annotation.gtf"|Path to gencode annotation file
`runArriba.genome`|String|"$HG38_ROOT/hg38_random.fa"|Path to loaded genome
`runArriba.cytobands`|String|"$ARRIBA_ROOT/share/database/cytobands_hg38_GRCh38_2018-02-23.tsv"|cytobands for figure annotation
`runArriba.domains`|String|"$ARRIBA_ROOT/share/database/protein_domains_hg38_GRCh38_2019-07-05.gff3"|protein domains for annotation
`runArriba.blacklist`|String|"$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_2018-11-04.tsv.gz"|List of fusions which are seen in normal tissue or artefacts
`runArriba.chimOutType`|String|"WithinBAM SoftClip"|Where to report chimeric reads
`runArriba.cosmic`|String|"$HG38_COSMIC_FUSION_ROOT/CosmicFusionExport.tsv"|known fusions from cosmic
`runArriba.outFilterMultimapNmax`|Int|1|max number of multiple alignments allowed for a read
`runArriba.outFilterMismatchNmax`|Int|3|maximum number of mismatches per pair
`runArriba.chimSegmentMin`|Int|10|the minimum mapped length of the two segments of a chimera
`runArriba.chimScoreMin`|Int|1|minimum total (summed) score of the chimeric segments
`runArriba.chimScoreDropMax`|Int|30|max drop (difference) of chimeric score from the read length
`runArriba.chimJunctionOverhangMin`|Int|10|minimum overhang for a chimeric junction
`runArriba.chimScoreJunctionNonGTAG`|Int|0|penalty for a non-GT/AG chimeric junction
`runArriba.chimScoreSeparation`|Int|1|minimum difference between the best chimeric score
`runArriba.chimSegmentReadGapMax`|Int|3|maximum gap in the read sequence between chimeric segments
`runArriba.threads`|Int|8|Requested CPU threads
`runArriba.jobMemory`|Int|64|Memory allocated for this job
`runArriba.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description
---|---|---
`fusionsPredictions`|File|fusion output tsv
`fusionDiscarded`|File|discarded fusion output tsv
`spliceJunctions`|File|splice junctions from star fusion run
`sortAlignBam`|File|Output sorted bam file aligned to genome
`sortAlignIndex`|File|Output index file for sorted bam aligned to genome
`fusionFigure`|File|pdf rendering of candidate fusions


## Niassa + Cromwell

This WDL workflow is wrapped in a Niassa workflow (https://github.com/oicr-gsi/pipedev/tree/master/pipedev-niassa-cromwell-workflow) so that it can used with the Niassa metadata tracking system (https://github.com/oicr-gsi/niassa).

* Building
```
mvn clean install
```

* Testing
```
mvn clean verify \
-Djava_opts="-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication" \
-DrunTestThreads=2 \
-DskipITs=false \
-DskipRunITs=false \
-DworkingDirectory=/path/to/tmp/ \
-DschedulingHost=niassa_oozie_host \
-DwebserviceUrl=http://niassa-url:8080 \
-DwebserviceUser=niassa_user \
-DwebservicePassword=niassa_user_password \
-Dcromwell-host=http://cromwell-url:8000
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_

