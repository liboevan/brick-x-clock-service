#!/bin/bash
set -e

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Function to show help
show_help() {
    print_header "Run"
    echo -e ""
    echo -e "${GREEN}Purpose:${NC}"
    echo -e "  Run the clock container"
    echo -e ""
    echo -e "${GREEN}Usage:${NC}"
    echo -e "  $0 [version]"
    echo -e ""
    echo -e "${GREEN}Parameters:${NC}"
    echo -e "  ${YELLOW}version${NC} - Image version to run (default: $RUN_VERSION)"
    echo -e ""
    echo -e "${BLUE}Configuration:${NC}"
    echo -e "  Container: $CONTAINER_NAME"
    echo -e "  Image: $IMAGE_NAME"
    echo -e "  API Port: $API_PORT"
    echo -e "  NTP Port: $NTP_PORT"
    echo -e "  Network: $NETWORK_NAME"
    echo -e "${BLUE}======================================${NC}"
}

# Parse arguments
if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "-help" ]]; then
    show_help
    exit 0
fi

print_header "Run"

VERSION_ARG=$1
cleanup_container
run_container $VERSION_ARG 