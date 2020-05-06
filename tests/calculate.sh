#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

module load samtools/1.9 2>/dev/null
find . -regex '.*\.bam$' -exec samtools flagstat {} \;
find . -regex '.*\.tab$' -exec wc -l {} \;
find . -regex '.*\.junction$' -exec wc -l {} \;
ls | sed 's/.*\.//' | sort | uniq -c