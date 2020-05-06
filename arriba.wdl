version 1.0

workflow arriba {


  input {
    Array[InputGroup] inputGroups
    String outputFileNamePrefix
    File? structuralVariants
  }

  scatter (ig in inputGroups) {
    File read1s       = ig.fastqR1
    File read2s       = ig.fastqR2
    String readGroups = ig.readGroup
  }

  parameter_meta {
    inputGroups: "Array of fastq files to align with STAR and the merged filename"
    outputFileNamePrefix: "Prefix for filename"
    structuralVariants: "path to structural variants for sample"
  } 

  call runArriba { input: read1s = read1s, read2s = read2s, readGroups = readGroups, outputFileNamePrefix = outputFileNamePrefix, structuralVariants = structuralVariants }

  output {
    File fusionsPredictions     = runArriba.fusionPredictions
    File fusionDiscarded        = runArriba.fusionDiscarded
    File spliceJunctions        = runArriba.spliceJunctions
    File sortAlignBam           = runArriba.sortAlignBam
    File sortAlignIndex         = runArriba.sortAlignIndex
    File fusionFigure           = runArriba.fusionFigure
    }

  meta {
    author: "Alexander Fortuna"
    email: "alexander.fortuna@oicr.on.ca"
    description: "Workflow that takes the Bam output from STAR and detects RNA-seq fusion events."
    dependencies: [
     {
      name: "arriba/1.2",
      url: "https://github.com/suhrig/arriba"
     },
     {
        name: "star/2.7.3a",
        url: "https://github.com/alexdobin/STAR"
      },
      {
         name: "samtools/1.9",
         url: "http://www.htslib.org/"
       }
    ]
  }
}

task runArriba {
  input {
    Array[File]+ read1s
    Array[File]+ read2s
    Array[String]+ readGroups
    File?  structuralVariants
    String index = "$HG38_STAR_INDEX100_ROOT"
    String draw = "$ARRIBA_ROOT/bin/draw_fusions.R"
    String samtools = "$SAMTOOLS_ROOT/bin/samtools"
    String modules = "arriba/1.2 hg38-star-index100/2.7.3a samtools/1.9 rarriba/0.1 hg38-cosmic-fusion/v91"
    String gencode = "$GENCODE_ROOT/gencode.v31.annotation.gtf"
    String genome = "$HG38_ROOT/hg38_random.fa"
    String cytobands = "$ARRIBA_ROOT/share/database/cytobands_hg38_GRCh38_2018-02-23.tsv"
    String domains = "$ARRIBA_ROOT/share/database/protein_domains_hg38_GRCh38_2019-07-05.gff3"
    String blacklist = "$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_2018-11-04.tsv.gz"
    String chimOutType = "WithinBAM SoftClip"
    String cosmic = "$HG38_COSMIC_FUSION_ROOT/CosmicFusionExport.tsv"
    String outputFileNamePrefix
    Int outFilterMultimapNmax = 1
    Int outFilterMismatchNmax = 3
    Int chimSegmentMin = 10
    Int chimScoreMin = 1
    Int chimScoreDropMax = 30
    Int chimJunctionOverhangMin = 10
    Int chimScoreJunctionNonGTAG = 0
    Int chimScoreSeparation = 1
    Int chimSegmentReadGapMax = 3
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
  }

  parameter_meta {
    read1s: "array of read1s"
    read2s: "array of read2s"
    readGroups: "array of readgroup lines"
    outputFileNamePrefix: "Prefix for filename"
    index: "Path to STAR index"
    draw: "path to arriba draw command"
    samtools: "path to samtools binary"
    modules: "Names and versions of modules to load"
    gencode: "Path to gencode annotation file"
    domains: "protein domains for annotation"
    cytobands: "cytobands for figure annotation"
    cosmic: "known fusions from cosmic"
    blacklist: "List of fusions which are seen in normal tissue or artefacts"
    genome: "Path to loaded genome"
    structuralVariants: "file containing structural variant calls"
    outFilterMultimapNmax: "max number of multiple alignments allowed for a read"
    outFilterMismatchNmax: "maximum number of mismatches per pair"
    chimSegmentMin: "the minimum mapped length of the two segments of a chimera"
    chimScoreMin: "minimum total (summed) score of the chimeric segments"
    chimScoreDropMax: "max drop (difference) of chimeric score from the read length"
    chimJunctionOverhangMin: "minimum overhang for a chimeric junction"
    chimScoreJunctionNonGTAG: "penalty for a non-GT/AG chimeric junction"
    chimScoreSeparation: "minimum difference between the best chimeric score"
    chimSegmentReadGapMax: "maximum gap in the read sequence between chimeric segments"
    chimOutType: "Where to report chimeric reads"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  String alignBam_ = "~{outputFileNamePrefix}.Aligned.out.bam"
  String alignBamSorted_ = "~{outputFileNamePrefix}.Aligned.sorted.out.bam"

  command <<<
      set -euo pipefail

      star \
      --readFilesIn ~{sep="," read1s} ~{sep="," read2s} \
      --outSAMattrRGline ~{sep=" , " readGroups} \
      --readFilesCommand zcat \
      --runThreadN ~{threads} \
      --genomeDir ~{index} --genomeLoad NoSharedMemory \
      --outSAMtype BAM SortedByCoordinate \
      --outSAMunmapped Within --outBAMsortingThreadN ~{threads} \
      --outFilterMultimapNmax ~{outFilterMultimapNmax} \
      --outFilterMismatchNmax ~{outFilterMismatchNmax} \
      --chimSegmentMin ~{chimSegmentMin} --chimOutType ~{chimOutType} \
      --chimJunctionOverhangMin ~{chimJunctionOverhangMin} \
      --chimScoreMin ~{chimScoreMin} --chimScoreDropMax ~{chimScoreDropMax} \
      --chimScoreJunctionNonGTAG ~{chimScoreJunctionNonGTAG} --chimScoreSeparation ~{chimScoreSeparation} \
      --alignSJstitchMismatchNmax 5 -1 5 5 \
      --chimSegmentReadGapMax ~{chimSegmentReadGapMax} --outFileNamePrefix ~{outputFileNamePrefix}.

      arriba \
      -x ~{outputFileNamePrefix}.Aligned.sortedByCoord.out.bam \
      -o ~{outputFileNamePrefix}.fusions.tsv -O ~{outputFileNamePrefix}.fusions.discarded.tsv \
      ~{"-d " + structuralVariants} -k ~{cosmic} \
      -a ~{genome} -g ~{gencode} -b ~{blacklist} \
      -T -P

      samtools index ~{outputFileNamePrefix}.Aligned.sortedByCoord.out.bam

      Rscript ~{draw} --annotation=~{gencode} --fusions=~{outputFileNamePrefix}.fusions.tsv \
      --output=~{outputFileNamePrefix}.fusions.pdf --alignments=~{outputFileNamePrefix}.Aligned.sortedByCoord.out.bam \
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
      File spliceJunctions          = "~{outputFileNamePrefix}.SJ.out.tab"
      File sortAlignBam             = "~{outputFileNamePrefix}.Aligned.sortedByCoord.out.bam"
      File sortAlignIndex           = "~{outputFileNamePrefix}.Aligned.sortedByCoord.out.bam.bai"
      File fusionFigure             = "~{outputFileNamePrefix}.fusions.pdf"
  }

  meta {
    output_meta: {
      fusionPredictions: "fusion output tsv",
      fusionDiscarded:   "discarded fusion output tsv",
      spliceJunctions: "splice junctions from star fusion run",
      sortAlignBam: "Output sorted bam file aligned to genome",
      sortAlignIndex: "Output index file for sorted bam aligned to genome",
      fusionFigure: "pdf rendering of candidate fusions"
    }
 }
}

struct InputGroup {
  File fastqR1
  File fastqR2
  String readGroup
}

