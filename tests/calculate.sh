#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

find . -regex '.*\.fusions.tsv$' -exec wc -l {} \;
find . -regex '.*\.fusions.discarded.tsv$' -exec wc -l {} \;
ls | sed 's/.*\.//' | sort | uniq -c
