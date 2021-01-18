version 1.0

workflow arriba {

  input {
    File inputBam
    String outputFileNamePrefix
    File? structuralVariants
  }

  parameter_meta {
    inputBam: "STAR BAM aligned to genome"
    outputFileNamePrefix: "Prefix for filename"
    structuralVariants: "path to structural variants for sample"
  }

  call runArriba {
    input:
    inputBam = inputBam,
    outputFileNamePrefix = outputFileNamePrefix,
    structuralVariants = structuralVariants }

  output {
    File fusionsPredictions     = runArriba.fusionPredictions
    File fusionDiscarded        = runArriba.fusionDiscarded
    File fusionFigure           = runArriba.fusionFigure
  }

  meta {
    author: "Alexander Fortuna"
    email: "alexander.fortuna@oicr.on.ca"
    description: "Workflow that takes the Bam output from STAR and detects RNA-seq fusion events."
    dependencies: [
     {
       name: "arriba/2.0",
       url: "https://github.com/suhrig/arriba"
     },
     {
       name: "rstats/3.6",
       url: "https://www.r-project.org/"
     },
     {
       name: "star/2.7.6a",
       url: "https://github.com/alexdobin/STAR"
     }
    ]
  }
}

task runArriba {
  input {
    File   inputBam
    File?  structuralVariants
    String draw = "$ARRIBA_ROOT/bin/draw_fusions.R"
    String modules = "arriba/2.0 rarriba/0.1 hg38-cosmic-fusion/v91 hg38-star-index100/2.7.6a"
    String gencode = "$GENCODE_ROOT/gencode.v31.annotation.gtf"
    String genome = "$HG38_ROOT/hg38_random.fa"
    String knownfusions = "$ARRIBA_ROOT/share/database/known_fusions_hg38_GRCh38_v2.0.0.tsv.gz"
    String cytobands = "$ARRIBA_ROOT/share/database/cytobands_hg38_GRCh38_v2.0.0.tsv"
    String domains = "$ARRIBA_ROOT/share/database/protein_domains_hg38_GRCh38_v2.0.0.gff3"
    String blacklist = "$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_v2.0.0.tsv.gz"
    String cosmic = "$HG38_COSMIC_FUSION_ROOT/CosmicFusionExport.tsv"
    String outputFileNamePrefix
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
  }

  parameter_meta {
    inputBam: "STAR bam"
    structuralVariants: "file containing structural variant calls"
    outputFileNamePrefix: "Prefix for filename"
    draw: "path to arriba draw command"
    modules: "Names and versions of modules to load"
    gencode: "Path to gencode annotation file"
    knownfusions: "database of known fusions"
    domains: "protein domains for annotation"
    cytobands: "cytobands for figure annotation"
    cosmic: "known fusions from cosmic"
    blacklist: "List of fusions which are seen in normal tissue or artefacts"
    genome: "Path to loaded genome"
    chimOutType: "Where to report chimeric reads"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  command <<<
      set -euo pipefail

      arriba \
      -x ~{inputBam} \
      -o ~{outputFileNamePrefix}.fusions.tsv -O ~{outputFileNamePrefix}.fusions.discarded.tsv \
      ~{"-d " + structuralVariants} -k ~{cosmic} -t ~{knownfusions} \
      -a ~{genome} -g ~{gencode} -b ~{blacklist} -p ~{domains}

      Rscript ~{draw} --annotation=~{gencode} --fusions=~{outputFileNamePrefix}.fusions.tsv \
      --output=~{outputFileNamePrefix}.fusions.pdf --alignments=~{inputBam} \
      --cytobands=~{cytobands} --proteinDomains=~{domains}
  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    modules: "~{modules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File fusionPredictions        = "~{outputFileNamePrefix}.fusions.tsv"
      File fusionDiscarded          = "~{outputFileNamePrefix}.fusions.discarded.tsv"
      File fusionFigure             = "~{outputFileNamePrefix}.fusions.pdf"
  }

  meta {
    output_meta: {
      fusionPredictions: "Fusion output tsv",
      fusionDiscarded:   "Discarded fusion output tsv",
      fusionFigure: "PDF rendering of candidate fusions"
    }
  }
}
