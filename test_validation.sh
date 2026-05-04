#!/bin/bash

# Test script for validation functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHIPFLOW_TEST_ROOT="$SCRIPT_DIR"
source "$SHIPFLOW_TEST_ROOT/lib.sh"
source "$SHIPFLOW_TEST_ROOT/local/mcp-login.sh"
source "$SHIPFLOW_TEST_ROOT/local/blacksmith-login.sh"

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}        ${YELLOW}ShipFlow Validation Tests${NC}          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

test_count=0
pass_count=0

run_test() {
    local test_name=$1
    local expected=$2
    shift 2
    local cmd=("$@")

    ((test_count += 1))
    echo -n "Test $test_count: $test_name ... "

    if "${cmd[@]}" >/dev/null 2>&1; then
        result="pass"
    else
        result="fail"
    fi

    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}✓${NC}"
        ((pass_count += 1))
    else
        echo -e "${RED}✗${NC} (expected $expected, got $result)"
    fi
}

echo -e "${BLUE}Testing validate_project_path()${NC}"
echo ""

# Should pass
run_test "Valid path /root" "pass" validate_project_path "/root"
run_test "Valid path checkout" "pass" validate_project_path "$SHIPFLOW_TEST_ROOT"
run_test "Valid path /opt" "pass" validate_project_path "/opt"

# Should fail
run_test "Empty path" "fail" validate_project_path ""
run_test "Relative path" "fail" validate_project_path "relative/path"
run_test "Path traversal" "fail" validate_project_path "/root/../etc"
run_test "Special chars semicolon" "fail" validate_project_path "/root/test;rm"
run_test "Special chars pipe" "fail" validate_project_path "/root/test|cat"
run_test "Special chars dollar" "fail" validate_project_path "/root/test\$USER"
run_test "Uppercase path" "fail" validate_project_path "/root/MyApp"
run_test "Non-existent path" "fail" validate_project_path "/root/nonexistent123456"
run_test "Unsafe directory /etc" "fail" validate_project_path "/etc"

echo ""
echo -e "${BLUE}Testing validate_env_name()${NC}"
echo ""

# Should pass
run_test "Valid env name 'myapp'" "pass" validate_env_name "myapp"
run_test "Valid env name 'my-app'" "pass" validate_env_name "my-app"
run_test "Valid env name 'my_app'" "pass" validate_env_name "my_app"
run_test "Valid env name 'my.app'" "pass" validate_env_name "my.app"
run_test "Valid env name 'app123'" "pass" validate_env_name "app123"

# Should fail
run_test "Empty env name" "fail" validate_env_name ""
run_test "Env name with spaces" "fail" validate_env_name "my app"
run_test "Env name starting with dash" "fail" validate_env_name "-myapp"
run_test "Env name starting with dot" "fail" validate_env_name ".myapp"
run_test "Env name with uppercase" "fail" validate_env_name "MyApp"
run_test "Env name with special chars" "fail" validate_env_name "my@app"

echo ""
echo -e "${BLUE}Testing DuckDNS/public publish validation${NC}"
echo ""

run_test "Valid DuckDNS subdomain" "pass" validate_duckdns_subdomain "my-app123"
run_test "DuckDNS subdomain uppercase" "fail" validate_duckdns_subdomain "MyApp"
run_test "DuckDNS subdomain injection newline" "fail" validate_duckdns_subdomain $'myapp\nexample.com'
run_test "DuckDNS subdomain trailing dash" "fail" validate_duckdns_subdomain "myapp-"
run_test "Valid DuckDNS token" "pass" validate_duckdns_token "12345678-1234-1234-1234-123456789abc"
run_test "DuckDNS token with ampersand" "fail" validate_duckdns_token "1234567890123456&bad"
run_test "Valid public IPv4" "pass" validate_public_ipv4 "203.0.113.10"
run_test "Invalid public IPv4 octet" "fail" validate_public_ipv4 "203.0.113.999"
run_test "Invalid public IPv4 payload" "fail" validate_public_ipv4 "203.0.113.10 example.com"

echo ""
echo -e "${BLUE}Testing validate_repo_name()${NC}"
echo ""

# Should pass
run_test "Valid repo 'myrepo'" "pass" validate_repo_name "myrepo"
run_test "Valid repo 'my-repo'" "pass" validate_repo_name "my-repo"
run_test "Valid repo 'my_repo'" "pass" validate_repo_name "my_repo"
run_test "Valid repo 'my.repo'" "pass" validate_repo_name "my.repo"

# Should fail
run_test "Empty repo name" "fail" validate_repo_name ""
run_test "Repo with spaces" "fail" validate_repo_name "my repo"
run_test "Repo with special chars" "fail" validate_repo_name "my@repo"

echo ""
echo -e "${BLUE}Testing _ui_normalize_choice()${NC}"
echo ""

run_test "Choice lowercase" "pass" test "$( _ui_normalize_choice "a" )" = "a"
run_test "Choice uppercase" "pass" test "$( _ui_normalize_choice "A" )" = "a"
run_test "Choice with suffix" "pass" test "$( _ui_normalize_choice "a)" )" = "a"
run_test "Choice with spaces" "pass" test "$( _ui_normalize_choice "  B  " )" = "b"
run_test "Choice with CRLF" "pass" test "$( _ui_normalize_choice $'c\r' )" = "c"

echo ""
echo -e "${BLUE}Testing validate_mcp_provider_name()${NC}"
echo ""

run_test "Valid MCP provider vercel" "pass" validate_mcp_provider_name "vercel"
run_test "Valid MCP provider custom-name_1" "pass" validate_mcp_provider_name "custom-name_1"
run_test "Invalid MCP provider empty" "fail" validate_mcp_provider_name ""
run_test "Invalid MCP provider starts with dash" "fail" validate_mcp_provider_name "--config"
run_test "Invalid MCP provider space" "fail" validate_mcp_provider_name "bad name"
run_test "Invalid MCP provider slash" "fail" validate_mcp_provider_name "bad/name"
run_test "Invalid MCP provider semicolon" "fail" validate_mcp_provider_name "bad;name"
run_test "Invalid MCP provider dollar" "fail" validate_mcp_provider_name "bad\$name"
run_test "Invalid MCP provider backtick" "fail" validate_mcp_provider_name "bad\`name"
run_test "Invalid MCP provider newline" "fail" validate_mcp_provider_name $'bad\nname'

echo ""
echo -e "${BLUE}Testing parse_mcp_oauth_port_from_text()${NC}"
echo ""

run_test "Parse encoded redirect_uri callback port" "pass" test "$(parse_mcp_oauth_port_from_text 'https://example.com/oauth?redirect_uri=http%3A%2F%2F127.0.0.1%3A46319%2Fcallback')" = "46319"
run_test "Parse decoded callback port" "pass" test "$(parse_mcp_oauth_port_from_text 'Open this URL: http://127.0.0.1:38765/callback')" = "38765"
run_test "Reject missing callback port" "fail" parse_mcp_oauth_port_from_text "https://example.com/no-callback"

echo ""
echo -e "${BLUE}Testing parse_blacksmith_oauth_port_from_text()${NC}"
echo ""

run_test "Parse Blacksmith callback_port query" "pass" test "$(parse_blacksmith_oauth_port_from_text 'https://app.blacksmith.sh/cli/auth?callback_port=45007')" = "45007"
run_test "Parse Blacksmith encoded localhost callback port" "pass" test "$(parse_blacksmith_oauth_port_from_text 'https://example.com/oauth?redirect_uri=http%3A%2F%2Flocalhost%3A48321%2Fcallback')" = "48321"
run_test "Parse Blacksmith decoded 127 callback port" "pass" test "$(parse_blacksmith_oauth_port_from_text 'Open this URL: http://127.0.0.1:38765/callback')" = "38765"
run_test "Reject missing Blacksmith callback port" "fail" parse_blacksmith_oauth_port_from_text "https://example.com/no-callback"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "Results: ${GREEN}$pass_count${NC}/${test_count} tests passed"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo ""

if [ $pass_count -eq $test_count ]; then
    echo -e "${GREEN}✅ All validation tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
