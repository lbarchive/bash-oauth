#!/bin/bash
# Copyright (c) 2010, 2012 Yu-Jie Lin
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

GMCLI_RC="$HOME/.gmcli.rc"

# Source GmailOAuth.sh

PATH=$PATH:$(pwd)
OAuth_sh=$(which GmailOAuth.sh)
(( $? != 0 )) && echo 'Unable to locate GmailOAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

usage () {
	echo "usage: $0 options

OPTIONS:
  -h      Show this message

  -c      Command
    
    Valid Commands:
      unread   List unread emails

Use -h -c command to get options for the command.
"
	exit $1
	}

show_unread () {
	echo "Command unread

Requires:
  none

Optional:
  none
"
	exit $1
	}

load_config () {
	[[ -f "$GMCLI_RC" ]] && . "$GMCLI_RC"

	# These are fixed for installed apps: http://code.google.com/apis/accounts/docs/OAuth_ref.html#SigningOAuth
	oauth_consumer_key='anonymous'
	oauth_consumer_secret='anonymous'

	GMAIL_init

	if [[ "$oauth_token" == "" ]] || [[ "$oauth_token_secret" == "" ]]; then
		GMAIL_access_token_helper
		if (( $? == 0 )); then
			oauth_token=${GMAIL_ret[0]}
			oauth_token_secret=${GMAIL_ret[1]}
			echo "oauth_token='${GMAIL_ret[0]}'" >> "$GMCLI_RC"
			echo "oauth_token_secret='${GMAIL_ret[1]}'" >> "$GMCLI_RC"
			echo "Token saved."
		else
			echo 'Unable to get access token'
			exit 1
		fi
	fi
	}

main () {
	load_config
	
	gmcli_command=
	while getopts "c:s:r:f:h" name
	do
		case $name in
		c)	gmcli_command="$OPTARG";;
		h)  gmcli_help_flag="1";;
		?)	usage
			exit 2;;
		esac
	done

	if [[ "$gmcli_help_flag" == "1" ]]; then case $gmcli_command in
	unread)
		show_unread 0
		;;
	*)
		[[ "$gmcli_command" == "" ]] && usage 0
		usage 1
	esac ; fi

	case $gmcli_command in
	unread)
		GMAIL_unread
		echo "$TO_ret"
		return $TO_rval
		;;
	*)
		usage 1
		;;
	esac
	return 0
	}

main "$@"
