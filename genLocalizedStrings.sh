#!/bin/sh

# This little helper script simply allows for easier generation of strings file in the pod's asset bundle.
# It's used like genstrings alone, but does the correct replacement for our custom macro to get localized strings
# and creates/modifies the strings files for all our used languages.
# There might be a better way to do this, but for now it works for the pod development.

if [ $# -eq 0 ]
  then
    echo "No source file specified!"
    exit 1    
fi

genstrings -s TRSLocalizedString -o ./Pod/Assets/en.lproj $1
genstrings -s TRSLocalizedString -o ./Pod/Assets/de.lproj $1
genstrings -s TRSLocalizedString -o ./Pod/Assets/es.lproj $1
genstrings -s TRSLocalizedString -o ./Pod/Assets/fr.lproj $1
genstrings -s TRSLocalizedString -o ./Pod/Assets/it.lproj $1
genstrings -s TRSLocalizedString -o ./Pod/Assets/nl.lproj $1
genstrings -s TRSLocalizedString -o ./Pod/Assets/pl.lproj $1