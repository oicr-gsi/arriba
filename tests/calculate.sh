#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

find . -regex '.*\.fusions.tsv$' -exec md5sum {} \;
find . -regex '.*\.fusions.discarded.tsv$' -exec md5sum {} \;
find . -regex '.*\.fusions.pdf$' -exec sh -c "cat {} | grep -av Date | md5sum" \;
