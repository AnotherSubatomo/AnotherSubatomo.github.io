#!/usr/bin/env bash
# Bash v4.3+ compatible only.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function fatal { echo -e "\e[0;41m$*\e[0m" >&2; } #;; red print
function warn { echo -e "\033[0;33m$*\033[0m" >&2; } #;; yellow print

# Asserts that the required arguments are properly recieved
function assert {
	local index="$1"; shift
	if [ "$#" -lt "$index" ]; then
		echo "Usage: $0 <context-file> <output-path>" >&2
		exit 1
	fi
	echo "${@:$index:1}"
}

function capture_context_values {
	local is_multiline=0
	local mul_value=""
	local mul_placeholder=""
	local -n context_values="$2"

	function register_mul_context_value {
		context_values["${mul_placeholder}"]="${mul_value%$'\n'}"
		is_multiline=0
		mul_value=""
		mul_placeholder=""
	}

	#NOTE: `|| [[ -n $line ]]` ensures the last line gets read!
	while IFS= read -r line || [[ -n $line ]]; do
		if [[ "$line" =~ \<\!\-\-\@\$([A-Za-z0-9\-]+)\-\-\> ]]; then
			if [[ "${is_multiline}" == 1 ]]; then register_mul_context_value; fi
			is_multiline=1
			mul_placeholder="${BASH_REMATCH[1]}"
			continue
		elif [[ "$line" =~ \<\!\-\-\@([A-Za-z0-9\-]+):(.*)\-\-\> ]]; then
			if [[ "${is_multiline}" == 1 ]]; then register_mul_context_value; fi
			context_values["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
			continue
		fi

		if [[ "${is_multiline}" == 0 ]]; then
			fatal "This should be unreachable; please file a bug report."
			exit 1
		else
			mul_value+="${line}"$'\n'
		fi
	done < "$1"

	[[ "${is_multiline}" == 1 ]] && register_mul_context_value
	
	#;; make sure the layout was defined
	[[ -n ${context_values[LAYOUT]+set} ]] || {
		fatal "Layout to be used was not defined by the context file \"$1\"."; exit 1;
	}

	export context_values # just to shut shellcheck(SC2034) down for this occasion
}

function render_context_file {
	local -n context_values="$1" #;; the preprocessed dictionary of context values
	
	local LAYOUT="${context_values[LAYOUT]}" #;; the name of the template to be used
	local TEMPLATE="${SCRIPT_DIR}/template/${LAYOUT}.html" #;; template file path

	#;; make sure the template exists
	[[ -f "$TEMPLATE" ]] || { fatal "Template not found: $TEMPLATE"; exit 1; }

	#;; Prepare render buffer
	local RENDER=""
	
	#;; Process template line-by-line
	while IFS= read -r line || [[ -n $line ]]; do
		if [[ "$line" =~ [^[:space:]]*([[:space:]]*)\<\!\-\-\@([A-Za-z0-9\-]+)\-\-\> ]]; then
			indent="${BASH_REMATCH[1]}"
			placeholder="${BASH_REMATCH[2]}"
			
			local replacement="${context_values["${placeholder}"]}"

			if [[ -f "${replacement}" ]]; then
				warn "Missing substitution for \"<!--@${placeholder}-->\""
       			RENDER+="$line"$'\n'
				continue
			else
				if [[ $replacement =~ $'\n' ]]; then
					replacement=$(printf "%s" "$replacement" | sed "2,\$s/^/${indent}/")
        else
          replacement="${indent}${replacement}"
				fi
				RENDER+="${line//"<!--@${placeholder}-->"/"${replacement}"}"
			fi
		else
			RENDER+="$line"$'\n'
		fi
	done < "$TEMPLATE"

	#;; remove trailing newline
	RENDER="${RENDER%$'\n'}"

	#;; render to file
	touch "$2" || { fatal "Failed to create or access file: $2"; exit 1; }
  	echo -n "$RENDER" > "$2"
}

function main {
	local -A CONTEXTS
	capture_context_values "$1" CONTEXTS
	render_context_file CONTEXTS "$2"

	# for placeholder in "${!CONTEXTS[@]}"; do
	# 	value="${CONTEXTS["${placeholder}"]}"
	# 	fatal "|${placeholder}|${value}|"
	# done
	
	export CONTEXTS
}

# An HTML file that holds the template substitutions
CONTEXT_FILE=$(assert 1 "$@")
# A file path where we will write the render to
OUTPUT_PATH=$(assert 2 "$@")

main "$CONTEXT_FILE" "$OUTPUT_PATH"