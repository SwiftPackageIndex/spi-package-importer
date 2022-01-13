#!/bin/bash

# best match ignores --order and is desc by default
swift run importer fetch --sort bestMatch -o best-desc.json

swift run importer fetch --sort stars --order asc  -o stars-asc.json
swift run importer fetch --sort stars --order desc -o stars-desc.json

swift run importer fetch --sort updated --order asc  -o updated-asc.json
swift run importer fetch --sort updated --order desc -o updated-desc.json
