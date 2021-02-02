# arriba

Workflow that takes the Bam output from STAR and detects RNA-seq fusion events.
It is required to run STAR with the option --chimOutType 'WithinBAM HardClip Junctions' as per https://github.com/oicr-gsi/star to create a BAM file compatible with both the arriba and STARFusion workflows. For additional parameter suggestions please see the arriba github link below.

## Overview

## Dependencies

* [arriba 2.0](https://github.com/suhrig/arriba)
* [rstats 3.6](https://www.r-project.org/)
* [star 2.7.6a](https://github.com/alexdobin/STAR)


## Usage

### Cromwell
```
java -jar cromwell.jar run arriba.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`inputBam`|File|STAR BAM aligned to genome
`indexBam`|File|Index for STAR Bam file
`outputFileNamePrefix`|String|Prefix for filename


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`structuralVariants`|File?|None|path to structural variants for sample


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runArriba.draw`|String|"$ARRIBA_ROOT/bin/draw_fusions.R"|path to arriba draw command
`runArriba.modules`|String|"arriba/2.0 rarriba/0.1 hg38-cosmic-fusion/v91 hg38-star-index100/2.7.6a"|Names and versions of modules to load
`runArriba.gencode`|String|"$GENCODE_ROOT/gencode.v31.annotation.gtf"|Path to gencode annotation file
`runArriba.genome`|String|"$HG38_ROOT/hg38_random.fa"|Path to loaded genome
`runArriba.knownfusions`|String|"$ARRIBA_ROOT/share/database/known_fusions_hg38_GRCh38_v2.0.0.tsv.gz"|database of known fusions
`runArriba.cytobands`|String|"$ARRIBA_ROOT/share/database/cytobands_hg38_GRCh38_v2.0.0.tsv"|cytobands for figure annotation
`runArriba.domains`|String|"$ARRIBA_ROOT/share/database/protein_domains_hg38_GRCh38_v2.0.0.gff3"|protein domains for annotation
`runArriba.blacklist`|String|"$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_v2.0.0.tsv.gz"|List of fusions which are seen in normal tissue or artefacts
`runArriba.cosmic`|String|"$HG38_COSMIC_FUSION_ROOT/CosmicFusionExport.tsv"|known fusions from cosmic
`runArriba.threads`|Int|8|Requested CPU threads
`runArriba.jobMemory`|Int|64|Memory allocated for this job
`runArriba.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description
---|---|---
`fusionsPredictions`|File|Fusion output tsv
`fusionDiscarded`|File|Discarded fusion output tsv
`fusionFigure`|File|PDF rendering of candidate fusions


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
