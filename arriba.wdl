version 1.0

workflow arriba {
  input {
    File Bam
  }

  }

  parameter_meta {
    inputFqs: "Array of fastq read pairs"
    chimeric: "Path to Chimeric.out.junction"
  }

  call runArriba { input: fastq1 = fastq1, fastq2 = fastq2, chimeric = chimeric }

  output {
    File fusions = runArriba.fusionPredictions
    File Discardedfusions = runStarFusion.fusionDiscarded
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
    File Bam
    String starFusion = "$STAR_FUSION_ROOT/STAR-Fusion"
    String modules = "star-fusion/1.8.1 star-fusion-genome/1.8.1-hg38"
    String genomeDir = "$STAR_FUSION_GENOME_ROOT/ctat_genome_lib_build_dir"
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
  }

  parameter_meta {
    fastq1: "Array of paths to the fastq files for read 1"
    fastq2: "Array of paths to the fastq files for read 2"
    chimeric: "Path to Chimeric.out.junction"
    starFusion: "Name of the STAR-Fusion binary"
    modules: "Names and versions of STAR-Fusion and STAR-Fusion genome to load"
    genomeDir: "Path to the STAR-Fusion genome directory"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  String outdir = "STAR-Fusion_outdir"

  command <<<
      "~{starFusion}" \
      --genome_lib_dir "~{genomeDir}" \
      --left_fq ~{sep="," fastq1} \
      --right_fq ~{sep="," fastq2} \
      --examine_coding_effect \
      --CPU "~{threads}" --chimeric_junction "~{chimeric}"
  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    modules: "~{modules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File fusionPredictions =          "~{outdir}/star-fusion.fusion_predictions.tsv"
      File fusionPredictionsAbridged =  "~{outdir}/star-fusion.fusion_predictions.abridged.tsv"
      File fusionCodingEffects =        "~{outdir}/star-fusion.fusion_predictions.abridged.coding_effect.tsv"
  }

  meta {
    output_meta: {
      fusionPredictions:          "Raw fusion output tsv",
      fusionPredictionsAbridged:  "Abridged fusion output tsv",
      fusionCodingEffects:        "Annotated fusion output tsv"
    }
  }

}

