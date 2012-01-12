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
