# arriba

Workflow that takes the Bam output from STAR and detects RNA-seq fusion events. It is required to run STAR with the option --chimOutType 'WithinBAM HardClip Junctions' as per https://github.com/oicr-gsi/star to create a BAM file compatible with both the arriba and STARFusion workflows. For additional parameter suggestions please see the arriba github link below.

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
`runArriba.cosmic`|String?|None|known fusions from cosmic, optional
`runArriba.threads`|Int|8|Requested CPU threads
`runArriba.jobMemory`|Int|64|Memory allocated for this job
`runArriba.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description
---|---|---
`fusionsPredictions`|File|Fusion output tsv
`fusionDiscarded`|File|Discarded fusion output tsv
`fusionFigure`|File|PDF rendering of candidate fusions


## Commands
 This section lists command(s) run by arriba workflow
 
 * Running arriba
 
 Run the program on bam output from STAR and detects RNA-seq fusion events
 
 ```
 
       arriba 
       -x INPUT_BAMS 
       -o OUTPUT_PREFIX.fusions.tsv -O OUTPUT_PREFIX.fusions.discarded.tsv 
       -d STRUCTURAL_VARIANTS (Optional) -k COSMIC (Optional) -t KNOWN_FUSIONS 
       -a GENOME -g GENCODE_REFERENCE_FILE -b BLACK_LIST -p DOMAINS
 
       Rscript DRAW --annotation=GENCODE_REFERENCE_FILE --fusions=OUTPUT_PREFIX.fusions.tsv 
       --output=OUTPUT_PREFIX.fusions.pdf --alignments=INPUT_BAM 
       --cytobands=CYTOBANDS --proteinDomains=DOMAINS
 
 ```
 ## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
