version 1.0

struct ArribaResources {
    String blacklist
    String cosmic
    String cytobands
    String domains
    String gencode
    String knownFusion
    String genome
}

workflow arriba {

  input {
    File inputBam
    File indexBam
    String outputFileNamePrefix
    String reference
    File? structuralVariants
  }

  Map[String,ArribaResources] resources = {
    "hg38": {
      "blacklist": "/home/ubuntu/module_data/arriba_data/blacklist_hg38_GRCh38_v2.4.0.tsv.gz",
      "cosmic": "/home/ubuntu/module_data/arriba_data/CosmicFusionExport.tsv",
      "cytobands": "/home/ubuntu/module_data/arriba_data/cytobands_hg38_GRCh38_v2.4.0.tsv",
      "domains": "/home/ubuntu/module_data/arriba_data/protein_domains_hg38_GRCh38_v2.4.0.gff3",
      "gencode": "/home/ubuntu/module_data/arriba_data/gencode.v31.annotation.gtf",
      "knownFusion": "/home/ubuntu/module_data/arriba_data/known_fusions_hg38_GRCh38_v2.4.0.tsv.gz",
      "genome": "/home/ubuntu/module_data/hg38_data/hg38_random.fa"
    }
  }


  parameter_meta {
    inputBam: "STAR BAM aligned to genome"
    indexBam: "Index for STAR Bam file"
    outputFileNamePrefix: "Prefix for filename"
    reference: "Reference id, i.e. hg38 (Currently the only one supported)"
    structuralVariants: "path to structural variants for sample"
  }

  call runArriba {
    input:
    inputBam = inputBam,
    indexBam = indexBam,
    gencode = resources[reference].gencode,
    genome = resources[reference].genome,
    knownfusions = resources[reference].knownFusion,
    cytobands = resources[reference].cytobands,
    cosmic = resources[reference].cosmic,
    domains = resources[reference].domains,
    blacklist = resources[reference].blacklist,
    outputFileNamePrefix = outputFileNamePrefix,
    structuralVariants = structuralVariants,
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
    File draw = "/home/ubuntu/module_data/arriba_data/draw_fusions.R"
    String docker= "arriba:2.4.0"
    File gencode 
    File genome 
    File knownfusions 
    File cytobands 
    File domains 
    File blacklist 
    File? cosmic
    String? additionalParameters
    String outputFileNamePrefix
  }

  parameter_meta {
    inputBam: "STAR bam"
    indexBam: "STAR bam index"
    structuralVariants: "file containing structural variant calls"
    outputFileNamePrefix: "Prefix for filename"
    draw: "path to arriba draw command"
    docker: "Names and versions of docker to load"
    gencode: "Path to gencode annotation file"
    knownfusions: "database of known fusions"
    domains: "protein domains for annotation"
    cytobands: "cytobands for figure annotation"
    cosmic: "known fusions from cosmic, optional"
    blacklist: "List of fusions which are seen in normal tissue or artefacts"
    genome: "Path to loaded genome"
    additionalParameters: "Any additional parameters we want to pass"
  }

  command <<<
      set -euo pipefail

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
    docker:"786fca2f74f7"
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
