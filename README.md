# arriba

Workflow that takes the Bam output from STAR and detects RNA-seq fusion events.

## Overview

## Dependencies

* [arriba 1.2](https://github.com/suhrig/arriba)


## Usage

### Cromwell
```
java -jar cromwell.jar run arriba.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`inputBam`|File|Bam output from STAR


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`outputFileNamePrefix`|String|basename(inputBam,'.Aligned.sortedByCoord.out.bam')|Prefix for output files


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runArriba.arriba`|String|"$ARRIBA_ROOT/bin/arriba"|Name of the Arriba binary
`runArriba.modules`|String|"arriba/1.2 gencode/31 hg38/p12"|Names and versions of modules to load
`runArriba.gencode`|String|"$GENCODE_ROOT/gencode.v31.annotation.gtf"|Path to gencode annotation file
`runArriba.genome`|String|"$HG38_ROOT/hg38_random.fa"|Path to loaded genome
`runArriba.blacklist`|String|"$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_2018-11-04.tsv.gz"|List of fusions which are seen in normal tissue or artefacts
`runArriba.threads`|Int|8|Requested CPU threads
`runArriba.jobMemory`|Int|64|Memory allocated for this job
`runArriba.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description
---|---|---
`fusionsPredictions`|File|fusion output tsv
`fusionDiscarded`|File|discarded fusion output tsv


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
