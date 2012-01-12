#!/bin/bash
# Copyright (c) 2010, Yu-Jie Lin
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

BASM_RC="$HOME/.Basm.rc"

OAuth_sh=$(which StereomoodOAuth.sh)
(( $? != 0 )) && echo 'Unable to locate StereomoodOAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"


# If you are going to develop based on this, please use your own key and
# secret.
oauth_consumer_key='3727e42eb4dfc4d53db038e02f3e357404bf6557a'
oauth_consumer_secret='ac1a13e8adf36343a0f6673115a3d3d8'


usage () {
	echo "usage: $0 options

OPTIONS:
  -h      Show this message

  -q      Query text
  -t      Type: mood, activity, or site

Example: $0 -q happy -t mood
"
	exit $1
	}


load_config () {

	[[ -f "$BASM_RC" ]] && . "$BASM_RC"
	
	SM_init

	if [[ "$oauth_token" == "" ]] || [[ "$oauth_token_secret" == "" ]]; then
		SM_access_token_helper
		if (( $? == 0 )); then
			oauth_token=${SM_ret[0]}
			oauth_token_secret=${SM_ret[1]}
			if [[ "$oauth_token" == "" ]] || [[ "$oauth_token_secret" == "" ]]; then
				echo -e "Couldn't get the token"!
				exit 1
			fi

			echo "oauth_token='${SM_ret[0]}'" >> "$BASM_RC"
			echo "oauth_token_secret='${SM_ret[1]}'" >> "$BASM_RC"
			echo "Token saved to $BASM_RC."
			echo
		else
			echo 'Unable to get access token'
			exit 1
		fi
		chmod 600 "$BASM_RC"
	fi

	}


quit () {

	# Show cursor
	echo -e "\033[?25h"
	# Echo for stdin
	stty echo
	echo
	exit $1
	
	}


listen () {

	SM_get_search_total "$1" "$2"
	(( $SM_rval != 0 )) && echo "$SM_ret" && exit $SM_rval

	total=$SM_ret
	
	echo "Keys: P - Pause | A - Add to library | N - Next song | Q - Quit"
	echo
	echo "$total songs in $1 $2"
	echo

	while true; do
		# 1-indexed
		page=$(( $RANDOM * total / 32768 + 1 ))

		SM_search 'xml' "$1" "$2" '1' "$page"

		total=$(SM_extract_XML_value 'total' "$SM_ret")

		song_id=$(SM_extract_XML_value 'id' "$SM_ret")
		song_title=$(SM_extract_XML_value 'title' "$SM_ret")
		song_artist=$(SM_extract_XML_value 'artist' "$SM_ret")
		song_album=$(SM_extract_XML_value 'album' "$SM_ret")
		song_url=$(SM_extract_XML_value 'url' "$SM_ret")
		song_image_url=$(SM_extract_XML_value 'image_url' "$SM_ret")
		song_audio_url=$(SM_extract_XML_value 'audio_url' "$SM_ret")
		song_post_url=$(SM_extract_XML_value 'post_url' "$SM_ret")

		# Clean up because current line may be 'Next song...'
		echo -e "\033[0G\033[A\033[2K\n\033[2KID: $song_id"
		echo "Title: $song_title"
		echo "Artist: $song_artist"
		echo "Album: $song_album"
		echo "URL: $song_url"
		echo "Audio: $song_audio_url"
		echo

		exec 8> >(mplayer -msglevel all=5 "$song_audio_url" | while read -d \[ line; do
			ret=$(echo -n "$line" | egrep "^J.A:")
			[[ "$ret" != "" ]] && echo -ne "\033[2K\033[0G$ret"
			done)
		subshell_pid=$!

		t_start=$(date +%s)
		finished_song=

		while true; do
			ps $subshell_pid &> /dev/null
			(( $? != 0 )) && finished_song=1 && break

			read -n 1 -t 1 ch
			[[ $? -gt 0 ]] && continue
			case "$ch" in
				a|A)	SM_user_library_song 'xml' "$song_id"
					echo -e "\033[2K\033[0G$(SM_extract_XML_value 'message' "$SM_ret")"
					continue
					;;
				p|P)	echo -n 'p' >&8
					sleep 0.1
					echo -ne "\033[2K\033[0G === PAUSED ===\033[0G"
					continue
					;;
				n|N)	echo -n 'q' >&8
					sleep 0.1
					echo -ne "\033[A\033[2K\n"
					echo -ne "\033[2K\033[0G"
					break
					;;
				q|Q)	echo -n 'q' >&8
					sleep 0.1
					echo -ne "\033[A\033[2K\n"
					echo -ne "\033[2K\033[0G"
					break
					;;
			esac
		done
		
		exec 8>&-

		t_diff=$(( $(date +%s) - $t_start))
		# finished listening?
		# FIXME this is not a good way to make it
		if [[ "$finished_song" != "" ]] && (( t_diff >= 90 )); then
			echo -ne "\033[2K\033[0GAdding listen...\033[0G"
			SM_song_listen 'xml' "$song_id"
			echo -e "\033[2K$(SM_extract_XML_value 'message' "$SM_ret")\n"
		fi

		case "$ch" in
			n|N)	echo -ne "Next song...\033[0G"
				continue
				;;
			q|Q)	echo -ne "Quiting..."
				break
				;;
		esac
	done
	
	}


main () {
	
	echo "Basm: A Bash client for stereomood"
	echo

	load_config

	# Catch program exiting and keyboard interrupt (Ctrl+C)
	trap quit INT EXIT
	# Catch window size changing
	trap sig_winch WINCH

	# No echo for stdin
	stty -echo
	# Hide cursor
	echo -ne "\033[?25l"

	basm_q=
	basm_type=
	while getopts "q:t:h" name
	do
		case $name in
		q)	basm_q="$OPTARG";;
		t)	basm_type="$OPTARG";;
		h)  usage 0
			;;
		?)	usage
			exit 2;;
		esac
	done

	[[ "$basm_q" == "" ]] && usage 1
	[[ "$basm_type" == "" ]] && uasge 1

	listen "$basm_q" "$basm_type"

	return 0
	
	}


main "$@"
