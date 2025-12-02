#!/bin/bash
set -euo pipefail

# -----------------------
# Config you might tweak
# -----------------------
projectName="aoc_24"
executableName="answer"        # no .app on Linux
version="1"
subVersion="0"

# Where your resources live (optional)
scriptPath="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
resourcePath="$scriptPath/res"
assetsPaths=()

# Source roots + files
sourceFileDirectory="$scriptPath"

betraySourceFiles=("01/answer.c")
forgeSourceFiles=("utils/debug.c" "utils/arrays.c")

# Flatten list
sourceFiles=( "${betraySourceFiles[@]}" "${forgeSourceFiles[@]}"  )

# -----------------------
# Helpers
# -----------------------
errorValue=1
successValue=0

justPrintHelp=0
skipVerification=0
buildMode=""

# Color helpers
echo_error()   { printf "\033[0;31m\033[1mERROR:\033[0m %s\n"   "$1"; }
echo_success() { printf "\033[0;32m\033[1mSUCCESS:\033[0m %s\n" "$1"; }
echo_warning() { printf "\033[0;33m\033[1mWARNING:\033[0m %s\n" "$1"; }

programIsInstalled() {
    command -v "$1" >/dev/null 2>&1
}

prequisitesMet() {
    local programsToInstall=()
    if ! programIsInstalled "clang"; then
        if ! programIsInstalled "gcc"; then
            programsToInstall+=("clang or gcc")
        fi
    fi
    if ! programIsInstalled "make"; then
        programsToInstall+=("make")
    fi
    if [ ${#programsToInstall[@]} -eq 0 ]; then
        return $successValue
    fi
    echo_error "Missing package(s): ${programsToInstall[*]}. Please install them."
    return $errorValue
}

checkPrerequisites() {
    echo
    echo "Checking prerequisites..."
    if ! prequisitesMet; then
        echo_error "Exiting build script because prerequisites are not met"
        exit 1
    fi
    echo_success "... prerequisites are met!"
}

checkBuildMode() {
    local buildModeArg="${1:-}"
    if [ "$buildModeArg" = "debug" ]; then
        echo "debug"
    else
        echo "release"
    fi
}

getBuildPath() {
    echo "$scriptPath/build/$buildMode"
}

getBuildBinPath() {
    local buildPath
    buildPath="$(getBuildPath)"
    echo "$buildPath/bin"
}

getBuildArtifactsPath() {
    local buildPath
    buildPath="$(getBuildPath)"
    echo "$buildPath/artifacts"
}

createBuildDirectories() {
    local buildFolder buildArtifactsPath buildBinPath
    buildFolder="$(getBuildPath)"
    buildArtifactsPath="$(getBuildArtifactsPath)"
    buildBinPath="$(getBuildBinPath)"
    mkdir -p "$buildFolder" "$buildArtifactsPath/obj" "$buildBinPath"
}

printHelpText() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [BUILD]

OPTIONS:
  -h    Print this help text
  -s    Skip verification of prerequisites

BUILD (release is default):
  release
  debug

Environment overrides:
  CC=<compiler>          (default: clang if present, else gcc)
  EXTRA_CFLAGS="..."     (appended to CFLAGS)
  EXTRA_LIBS="..."       (appended to LDFLAGS; default: -lm -lpthread)
EOF
}

compileUsingMakeFile() {
    local makeDir
    makeDir="$(getBuildArtifactsPath)"
    pushd "$makeDir" >/dev/null
    make
    popd >/dev/null
}

generateMakeFile() {
    local makeFilePath outputPath objectOutputPath
    makeFilePath="$(getBuildArtifactsPath)/makefile"
    objectOutputPath="$(getBuildArtifactsPath)/obj"
    outputPath="$(getBuildBinPath)/$executableName"

    mkdir -p "$objectOutputPath"

    # Choose compiler
    local cc="clang"
    if ! programIsInstalled clang && programIsInstalled gcc; then
        cc="gcc"
    fi
    cc="${CC:-$cc}"

    # Strict C89 flags
    local baseCFlags="-std=c89 -pedantic -Wall -Wextra -Wstrict-prototypes -Wno-long-long"
    local modeCFlags
    if [ "$buildMode" = "release" ]; then
        echo "Build config = release"
        modeCFlags="-O3"
    else
        echo "Build config = debug"
        modeCFlags="--debug"
    fi
    local extraCFlags="${EXTRA_CFLAGS:-}"
    local extraLibs="${EXTRA_LIBS:-"-lm -lpthread"}"

    # Build the object list and also remember (src, obj) pairs
    local objects=()
    local srcs=()
    local obj src
    for src in "${sourceFiles[@]}"; do
        obj="$objectOutputPath/${src%.c}.o"   # mirrors directory tree
        objects+=("$obj")
        srcs+=("$src")
    done

    {
        echo "CC:=$cc"
        echo "CFLAGS:=$baseCFlags $modeCFlags $extraCFlags"
        echo "LDFLAGS:=$extraLibs"
        echo "SRCDIR:=$sourceFileDirectory"
        echo "OBJDIR:=$objectOutputPath"
        echo "EXECUTABLE:=$outputPath"
        echo "OBJECTS:= ${objects[*]}"
        echo
        echo 'all: $(EXECUTABLE)'
        echo
        echo '$(EXECUTABLE): $(OBJECTS)'
        echo -e '\t@mkdir -p $(dir $@)'
        echo -e '\t$(CC) $(OBJECTS) $(LDFLAGS) -o $@'
        echo
        # ----- Per-file rules (handle subdirectories) -----
    } > "$makeFilePath"

    # Emit one compile rule per source (handles slashes)
    local i
    for (( i=0; i<${#srcs[@]}; i++ )); do
        src="${srcs[$i]}"
        obj="${objects[$i]}"
        {
            echo "$obj: \$(SRCDIR)/$src"
            echo -e '\t@mkdir -p $(dir $@)'
            echo -e '\t$(CC) $(CFLAGS) -I$(SRCDIR) -c $< -o $@'
            echo
        } >> "$makeFilePath"
    done

    {
        echo 'clean:'
        echo -e '\trm -rf $(OBJDIR) $(EXECUTABLE)'
        echo
        echo 'print-%: ; @echo $*=$($*)'
    } >> "$makeFilePath"
}


copyResources() {
    local binPath
    binPath="$(getBuildBinPath)"
    if [ ${#assetsPaths[@]} -gt 0 ]; then
        echo "Copying assets to $binPath/ ..."
        for assetPath in "${assetsPaths[@]}"; do
            if [ -d "$assetPath" ]; then
                echo "  ... copying $assetPath"
                cp -rf "$assetPath" "$binPath/"
            else
                echo_warning "Asset path not found: $assetPath"
            fi
        done
    fi
}

main() {
    # Options:
    #   h - show help
    #   s - skip verification of prerequisites
    while getopts "hs" opt; do
        case ${opt} in
            h ) printHelpText; justPrintHelp=1 ;;
            s ) skipVerification=1 ;;
            * ) echo "Invalid option: -$OPTARG"; printHelpText; exit 1 ;;
        esac
    done
    shift $((OPTIND -1))

    [ $justPrintHelp -eq 1 ] && exit 0

    buildMode="$(checkBuildMode "${1:-}")"

    if [ $skipVerification -eq 1 ]; then
        echo "Skipping installation verification..."
    else
        checkPrerequisites
    fi

    echo "Building using build mode '$buildMode'"

    createBuildDirectories
    generateMakeFile

    if ! compileUsingMakeFile; then
        echo
        echo_error "Compilation failed"
        exit 1
    fi

    copyResources
    echo_success "Successfully built '${projectName}' → $(getBuildBinPath)/$executableName"
}

main "$@"

