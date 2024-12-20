# arriba

Workflow that takes the Bam output from STAR and detects RNA-seq fusion events. It is required to run STAR with the option --chimOutType 'WithinBAM HardClip Junctions' as per https://github.com/oicr-gsi/star to create a BAM file compatible with both the arriba and STARFusion workflows. For additional parameter suggestions please see the arriba github link below.

## Dependencies

* [arriba 2.4.0](https://github.com/suhrig/arriba)
* [rstats 3.6](https://www.r-project.org/)


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
`reference`|String|Reference id, i.e. hg38 (Currently the only one supported)


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`structuralVariants`|File?|None|path to structural variants for sample


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runArriba.draw`|String|"$ARRIBA_ROOT/bin/draw_fusions.R"|path to arriba draw command
`runArriba.additionalParameters`|String?|None|Any additional parameters we want to pass
`runArriba.threads`|Int|8|Requested CPU threads
`runArriba.jobMemory`|Int|64|Memory allocated for this job
`runArriba.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description | Labels
---|---|---|---
`fusionsPredictions`|File|{'description': 'Fusion output tsv', 'vidarr_label': 'fusionPredictions'}|
`fusionDiscarded`|File|{'description': 'Discarded fusion output tsv', 'vidarr_label': 'fusionDiscarded'}|
`fusionFigure`|File|{'description': 'PDF rendering of candidate fusions', 'vidarr_label': 'fusionFigure'}|


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
