#!/bin/bash

input_dir="."
workspace_file="workspace"
port=8080        # default port
help=0

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input-dir)
            input_dir="$2"
            shift 2
            ;;
        -w|--workspace-dls)
            workspace_file="$2"
            shift 2
            ;;
        -p|--port)
            port="$2"
            shift 2
            ;;
        -h|--help)
            help=1
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Remaining arguments: DIR FILE
if [[ $help -eq 1 ]]; then
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -i --input-dir NAME            The name of the directory the .dsl is in (default: current directory)"
    echo "  -w --workspace-dsl NAME            The name of the workspace file without the .dsl (default: 'workspace')"
    echo "  -p --port NUMBER            The port to run the server on (default: 8080)"
    echo "example: `./server.sh -i ./C4Model/ -w c4 -p 8081` will reder ./C4Model/c4.dsl on localhost:8081"
    exit 1
fi


# Get absolute path safely
real_dir="$(realpath "$input_dir")"
if [[ ! -d "$real_dir" ]]; then
    echo "Error: directory '$real_dir' does not exist"
    exit 1
fi

echo "RUNNING:" && echo "docker run -it --rm -p "$port:8080" -v "$real_dir":/usr/local/structurizr:z -e STRUCTURIZR_WORKSPACE_FILENAME="$workspace_file" structurizr/lite" && echo

# Start container
docker run -it --rm \
    -p "$port:8080" \
    -v "$real_dir":/usr/local/structurizr:z \
    -e STRUCTURIZR_WORKSPACE_FILENAME="$workspace_file" \
    structurizr/lite

