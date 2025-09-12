version 1.0

struct ArribaResources {
    String blacklist
    String cosmic
    String cytobands
    String domains
    String gencode
    String knownFusion
    String genome
    String modules
    String data_modules
}

workflow arriba {

  input {
    File inputBam
    File indexBam
    String outputFileNamePrefix
    String reference
    File? structuralVariants
    String local_code_modulefile_path = "/home/ubuntu/local_modules/gsi/modulator/modulefiles/Ubuntu24.04"
    String local_data_modulefile_path = "/home/ubuntu/local_modules/gsi/modulator/modulefiles/data"
  }

  Map[String,ArribaResources] resources = {
    "hg38": {
      "blacklist": "$ARRIBA_ROOT/share/database/blacklist_hg38_GRCh38_v2.4.0.tsv.gz",
      "cosmic": "$HG38_COSMIC_FUSION_ROOT/CosmicFusionExport.tsv",
      "cytobands": "$ARRIBA_ROOT/share/database/cytobands_hg38_GRCh38_v2.4.0.tsv",
      "domains": "$ARRIBA_ROOT/share/database/protein_domains_hg38_GRCh38_v2.4.0.gff3",
      "gencode": "$GENCODE_ROOT/gencode.v31.annotation.gtf",
      "knownFusion": "$ARRIBA_ROOT/share/database/known_fusions_hg38_GRCh38_v2.4.0.tsv.gz",
      "genome": "$HG38_ROOT/hg38_random.fa",
      "modules": "arriba/2.4.0 samtools/1.16.1 rarriba/0.1",
      "data_modules": "hg38/p12 hg38-cosmic-fusion/v91 gencode/31"
    }
  }


  parameter_meta {
    inputBam: "STAR BAM aligned to genome"
    indexBam: "Index for STAR Bam file"
    outputFileNamePrefix: "Prefix for filename"
    reference: "Reference id, i.e. hg38 (Currently the only one supported)"
    structuralVariants: "path to structural variants for sample"
    local_code_modulefile_path: "Path to locally build code modulefiles"
    local_data_modulefile_path: "Path to locally build data modulefiles"
  }

  call runArriba {
    input:
    inputBam = inputBam,
    indexBam = indexBam,
    modules = resources[reference].modules,
    data_modules = resources[reference].data_modules,
    gencode = resources[reference].gencode,
    genome = resources[reference].genome,
    knownfusions = resources[reference].knownFusion,
    cytobands = resources[reference].cytobands,
    cosmic = resources[reference].cosmic,
    domains = resources[reference].domains,
    blacklist = resources[reference].blacklist,
    outputFileNamePrefix = outputFileNamePrefix,
    structuralVariants = structuralVariants,
    local_code_modulefile_path = local_code_modulefile_path, 
    local_data_modulefile_path = local_data_modulefile_path
  }

  output {
    File fusionsPredictions     = runArriba.fusionPredictions
    File fusionDiscarded        = runArriba.fusionDiscarded
    File fusionFigure           = runArriba.fusionFigure
  }

  meta {
    author: "Alexander Fortuna"
    email: "alexander.fortuna@oicr.on.ca"
    description: "Workflow that takes the Bam output from STAR and detects RNA-seq fusion events. It is required to run STAR with the option --chimOutType 'WithinBAM HardClip Junctions' as per https://github.com/oicr-gsi/star to create a BAM file compatible with both the arriba and STARFusion workflows. For additional parameter suggestions please see the arriba github link below."
    dependencies: [
    {
       name: "arriba/2.4.0",
       url: "https://github.com/suhrig/arriba"
     },
     {
       name: "rstats/3.6",
       url: "https://www.r-project.org/"
     }
    ]
  }
}

task runArriba {
  input {
    File   inputBam
    File   indexBam
    File?  structuralVariants
    String draw = "$ARRIBA_ROOT/bin/draw_fusions.R"
    String modules
    String data_modules
    String local_code_modulefile_path
    String local_data_modulefile_path
    String gencode 
    String genome 
    String knownfusions 
    String cytobands 
    String domains 
    String blacklist 
    String? cosmic
    String? additionalParameters
    String outputFileNamePrefix
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
  }

  parameter_meta {
    inputBam: "STAR bam"
    indexBam: "STAR bam index"
    structuralVariants: "file containing structural variant calls"
    outputFileNamePrefix: "Prefix for filename"
    draw: "path to arriba draw command"
    modules: "Names and versions of modules to load"
    data_modules: "Names and versions of data modules to load"
    local_code_modulefile_path: "Path to locally build code modulefiles"
    local_data_modulefile_path: "Path to locally build data modulefiles"
    gencode: "Path to gencode annotation file"
    knownfusions: "database of known fusions"
    domains: "protein domains for annotation"
    cytobands: "cytobands for figure annotation"
    cosmic: "known fusions from cosmic, optional"
    blacklist: "List of fusions which are seen in normal tissue or artefacts"
    genome: "Path to loaded genome"
    additionalParameters: "Any additional parameters we want to pass"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  command <<<
      set -euo pipefail
      . /usr/share/modules/init/bash
      module use ~{local_code_modulefile_path }
      module load ~{modules}
      module use ~{local_data_modulefile_path }
      module load ~{data_modules}

      arriba \
      -x ~{inputBam} \
      -o ~{outputFileNamePrefix}.fusions.tsv -O ~{outputFileNamePrefix}.fusions.discarded.tsv \
      ~{"-d " + structuralVariants} ~{"-k " + cosmic} -t ~{knownfusions} \
      -a ~{genome} -g ~{gencode} -b ~{blacklist} -p ~{domains} ~{additionalParameters}

      samtools index -@4 ~{inputBam}

      Rscript ~{draw} --annotation=~{gencode} --fusions=~{outputFileNamePrefix}.fusions.tsv \
      --output=~{outputFileNamePrefix}.fusions.pdf --alignments=~{inputBam} \
      --cytobands=~{cytobands} --proteinDomains=~{domains}
  >>>

  runtime {
    memory:  "~{jobMemory} GB"
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
    fusionPredictions: {
        description: "Fusion output tsv",
        vidarr_label: "fusionPredictions"
    },
    fusionDiscarded: {
        description: "Discarded fusion output tsv",
        vidarr_label: "fusionDiscarded"
    },
    fusionFigure: {
        description: "PDF rendering of candidate fusions",
        vidarr_label: "fusionFigure"
    }
}
  }
}
