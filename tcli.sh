#!/bin/bash
# Copyright (c) 2014 Mathew Paret
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

TCLI_RC="$HOME/.tcli.rc"

# Source TwitterOAuth.sh

OAuth_sh=$(which TwitterOAuth.sh)
(( $? != 0 )) && echo 'Unable to locate TwitterOAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

usage () {
	echo "usage: $0 options

OPTIONS:
  -h      Show this message

  -c      Command
    
	Valid Commands:
      account_update_profile_image
      statuses_update
      twitpic_upload
      twitpic_upload_post

Use -h -c command to get options for the command.
"
	exit $1
	}

show_config_help () {
	echo "Please create $TCLI_RC with:
oauth_consumer_key=YOUR_CONSUMER_KEY
oauth_consumer_secret=YOUR_CONSUMER_SECRET

You can register new app to get consumer key and secret at
  http://dev.twitter.com/apps/new
"
	exit $1
	}

show_account_update_profile_image () {
	echo "Command account_update_profile_image

Requires:
  -f file
"
	exit $1
	}

show_statuses_update () {
	echo "Command statuses_update

Requires:
  -s status

Optional:
  -r in_reply_to_status_id
"
	exit $1
	}

show_twitpic_update () {
	echo "Command twitpic_update

Requires:
  -s status
  -f file
"
	exit $0
	}

load_config () {
	[[ -f "$TCLI_RC" ]] && . "$TCLI_RC" || show_config_help 1

	[[ "$oauth_consumer_key" == "" ]] && show_config_help 1
	[[ "$oauth_consumer_secret" == "" ]] && show_config_help 1

	TO_init

	if [[ "$oauth_token" == "" ]] || [[ "$oauth_token_secret" == "" ]]; then
		TO_access_token_helper
		if (( $? == 0 )); then
			oauth_token=${TO_ret[0]}
			oauth_token_secret=${TO_ret[1]}
			echo "oauth_token='${TO_ret[0]}'" >> "$TCLI_RC"
			echo "oauth_token_secret='${TO_ret[1]}'" >> "$TCLI_RC"
			echo "Token saved."
		else
			echo 'Unable to get access token'
			exit 1
		fi
	fi
	}

main () {
	load_config
	
	tcli_command=
	tcli_status=
	tcli_in_reply_to_status_id=
	tcli_file=
	tcli_help_flag=
	while getopts "c:s:r:f:h" name
	do
		case $name in
		c)	tcli_command="$OPTARG";;
		s)	tcli_status="$OPTARG";;
		r)	tcli_in_reply_to_status_id="$OPTARG";;
		f)	tcli_file="$OPTARG";;
		h)	Tcli_help_flag="1";;
		?)	usage
			exit 2;;
		esac
	done

	if [[ "$tcli_help_flag" == "1" ]]; then case $tcli_command in
	account_update_profile_image)
		show_account_update_profile_image 0
		;;
	statuses_update)
		show_statuses_update 0
		;;
	twitpic_upload|twitpic_upload_post)
		show_twitpic_upload 0
		;;
	*)
		[[ "$tcli_command" == "" ]] && usage 0
		usage 1
	esac ; fi

	case $tcli_command in
	account_update_profile_image)
		[[ "$tcli_file" == "" ]] && show_account_update_profile 1
		TO_account_update_profile_image "$tcli_file"
		echo "$TO_ret"
		return $TO_rval
		;;
	statuses_update)
		[[ "$tcli_status" == "" ]] && show_statuses_update 1
		TO_statuses_update "$tcli_status" "$tcli_in_reply_to_status_id"
		echo "$TO_ret"
		return $TO_rval
		;;
	twitpic_upload)
		[[ "$twitpic_api" == "" ]] && read -p 'You TwitPic API Key: ' twitpic_api && echo "twitpic_api=\"$twitpic_api\"" >> "$TCLI_RC"
		[[ "$twitpic_api" == "" ]] && exit 1

		[[ "$tcli_file" == "" ]] && show_twitpic_upload 1
		[[ "$tcli_status" == "" ]] && show_twitpic_upload 1
		
		T_ACCOUNT_VERIFY_CREDENTIALS='https://api.twitter.com/1/account/verify_credentials.json'
		auth_header=$(OAuth_authorization_header 'X-Verify-Credentials-Authorization' 'http://api.twitter.com' '' '' 'GET' "$T_ACCOUNT_VERIFY_CREDENTIALS")
		echo "Sending $tcli_file to TwitPic..."
		ret=$(curl -s -H "X-Auth-Service-Provider=$T_ACCOUNT_VERIFY_CREDENTIALS" -H "$auth_header" -F "key=$twitpic_api" -F "message=$tcli_status" -F "media=@$tcli_file" http://twitpic.com/api/2/upload.xml)
		rval=$?
		(( $rval != 0 )) && echo "$ret" && exit $rval
		
		image_url=$(egrep -o 'http://twitpic\.com/[^<]*' <<< "$ret")
		echo " Image uploaded: $image_url"
		;;
	twitpic_upload_post)
		[[ "$twitpic_api" == "" ]] && read -p 'You TwitPic API Key: ' twitpic_api && echo "twitpic_api=\"$twitpic_api\"" >> "$TCLI_RC"
		[[ "$twitpic_api" == "" ]] && exit 1

		[[ "$tcli_file" == "" ]] && show_twitpic_upload 1
		[[ "$tcli_status" == "" ]] && show_twitpic_upload 1
		
		T_ACCOUNT_VERIFY_CREDENTIALS='https://api.twitter.com/1/account/verify_credentials.json'
		auth_header=$(OAuth_authorization_header 'X-Verify-Credentials-Authorization' 'http://api.twitter.com' '' '' 'GET' "$T_ACCOUNT_VERIFY_CREDENTIALS")
		echo "Sending $tcli_file to TwitPic..."
		ret=$(curl -s -H "X-Auth-Service-Provider=$T_ACCOUNT_VERIFY_CREDENTIALS" -H "$auth_header" -F "key=$twitpic_api" -F "message=$tcli_status" -F "media=@$tcli_file" http://twitpic.com/api/2/upload.xml)
		rval=$?
		(( $rval != 0 )) && echo "$ret" && exit $rval

		image_url=$(egrep -o 'http://twitpic\.com/[^<]*' <<< "$ret")
		echo " Image uploaded: $image_url"
		
		echo "Posting tweet..."
		TO_statuses_update "$tcli_status $image_url" "$tcli_in_reply_to_status_id"
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
