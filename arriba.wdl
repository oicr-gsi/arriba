version 1.0

workflow arriba {
  input {
    File inputBam
    String outputFileNamePrefix = basename(inputBam, '.Aligned.sortedByCoord.out.bam')
  }


  parameter_meta {
    inputBam: "Bam output from STAR"
    outputFileNamePrefix: "Prefix for output files"
  }

  call runArriba { input: inputBam = inputBam }

  output {
    File fusionsPredictions = runArriba.fusionPredictions
    File fusionDiscarded = runArriba.fusionDiscarded
    }

  meta {
    author: "Alexander Fortuna"
    email: "alexander.fortuna@oicr.on.ca"
    description: "Workflow that takes the Bam output from STAR and detects RNA-seq fusion events."
    dependencies: [
     {
      name: "arriba/1.2",
      url: "https://github.com/suhrig/arriba"
     }
    ]
  }

}

task runArriba {
  input {
    File inputBam
    String arriba = "$ARRIBA_ROOT/bin/arriba"
    String modules = "arriba/1.2 gencode/31 hg38/p12"
    String gencode = "$GENCODE_ROOT/gencode.v31.annotation.gtf"
    String genome = "$HG38_ROOT/hg38_random.fa"
    String blacklist = "$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_2018-11-04.tsv.gz"
    String cosmic = "$ARRIBA_ROOT/share/database/CosmicFusionExport.tsv"
    String outputFileNamePrefix = outputFileNamePrefix
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
  }

  parameter_meta {
    inputBam: "Path to Bam file output from star workflow"
    arriba: "Name of the Arriba binary"
    outputFileNamePrefix: "Prefix for output files"
    modules: "Names and versions of modules to load"
    gencode: "Path to gencode annotation file"
    genome : "Path to loaded genome"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }



  command <<<
      "~{arriba}" \
      -x "~{inputBam}" \
      -o "~{outputFileNamePrefix}".fusions.tsv -O "~{outputFileNamePrefix}".fusions.discarded.tsv \
      -a "~{genome}" -g "~{gencode}" -b "~{blacklist}" \
      -T -P -k "~{cosmic}"
  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    modules: "~{modules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File fusionPredictions = "~{outputFileNamePrefix}.fusions.tsv"
      File fusionDiscarded =   "~{outputFileNamePrefix}.fusions.discarded.tsv"
  }

  meta {
    output_meta: {
      fusionPredictions: "fusion output tsv",
      fusionDiscarded:   "discarded fusion output tsv"
    }
  }

}
