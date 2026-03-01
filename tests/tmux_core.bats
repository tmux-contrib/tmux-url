#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/test_helper.bash"
}

# -- _tmux_get_option ------------------------------------------------------

@test "_tmux_get_option: returns default when tmux returns empty" {
	run _tmux_get_option "@nonexistent" "fallback"
	[[ "$output" = "fallback" ]]
}

@test "_tmux_get_option: returns empty when no default provided" {
	run _tmux_get_option "@nonexistent"
	[[ "$output" = "" ]]
}
