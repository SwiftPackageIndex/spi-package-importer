#!/bin/bash

# GH search allows at most 1000 results to be fetched by paging through a list of results
# Since the searches turn up more than 2k results, we come at it from both ends by flipping the search order and try sorting by different parameters in order to try and capture as many different results from the 2k+ results there are.

# best match ignores --order and is desc by default
swift run importer fetch --sort bestMatch -o best-desc.json

swift run importer fetch --sort stars --order asc  -o stars-asc.json
swift run importer fetch --sort stars --order desc -o stars-desc.json

swift run importer fetch --sort updated --order asc  -o updated-asc.json
swift run importer fetch --sort updated --order desc -o updated-desc.json
