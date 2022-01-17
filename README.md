# spi-package-importer

`importer` is a command line utility with three subcommands:

- fetch package lists from Github via search and save them to JSON files
- merge JSON files in package list format, writing a new file with unique packages
- diff two JSON package list files to determine which packages are missing in our master list

The script `run-all.sh` demonstrates how these commands can be put together to compute a list of missing packages.
