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

T_API_VERSION="1"

# Twitter API endpoints

T_ACCOUNT_UPDATE_PROFILE_IMAGE="https://api.twitter.com/$T_API_VERSION/account/update_profile_image"
T_STATUSES_UPDATE="https://api.twitter.com/$T_API_VERSION/statuses/update"

T_REQUEST_TOKEN='https://api.twitter.com/oauth/request_token'
T_ACCESS_TOKEN='https://api.twitter.com/oauth/access_token'
T_AUTHORIZE_TOKEN='https://api.twitter.com/oauth/authorize'

# Source OAuth.sh

OAuth_sh=$(which OAuth.sh)
(( $? != 0 )) && echo 'Unable to locate OAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

TO_debug () {
	# Print out all parameters, each in own line
	[[ "$TO_DEBUG" == "" ]] && return
	local t=$(date +%FT%T.%N)
	while (( $# > 0 )); do
		echo "[TO][DEBUG][$t] $1"
		shift 1
		done
	}

TO_extract_value () {
	# $1 key name
	# $2 string to find
	egrep -o "$1=[a-zA-Z0-9-]*" <<< "$2" | cut -d\= -f 2
	}


TO_init() {
	# Initialize TwitterOAuth
	oauth_version='1.0'
	oauth_signature_method='HMAC-SHA1'
	oauth_basic_params=(
		$(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
		$(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
		$(OAuth_param 'oauth_version' "$oauth_version")
		)
	}

TO_access_token_helper () {
	# Help guide user to get access token

	local resp PIN

	# Request Token
	
	local auth_header="$(_OAuth_authorization_header 'Authorization' 'http://api.twitter.com/' "$oauth_consumer_key" "$oauth_consumer_secret" '' '' "$oauth_signature_method" "$oauth_version" "$(OAuth_nonce)" "$(OAuth_timestamp)" 'POST' "$T_REQUEST_TOKEN" "$(OAuth_param 'oauth_callback' 'oob')"), $(OAuth_param_quote 'oauth_callback' 'oob')"
	
	resp=$(curl -s -d '' -H "$auth_header" "$T_REQUEST_TOKEN")
	TO_rval=$?
	(( $? != 0 )) && return $TO_rval

	local _oauth_token=$(TO_extract_value 'oauth_token' "$resp")
	local _oauth_token_secret=$(TO_extract_value 'oauth_token_secret' "$resp")

	echo 'Please go to the following link to get the PIN:'
	echo "  ${T_AUTHORIZE_TOKEN}?oauth_token=$_oauth_token"
	
	read -p 'PIN: ' PIN

	# Access Token

	local auth_header="$(_OAuth_authorization_header 'Authorization' 'http://api.twitter.com/' "$oauth_consumer_key" "$oauth_consumer_secret" "$_oauth_token" "$_oauth_token_secret" "$oauth_signature_method" "$oauth_version" "$(OAuth_nonce)" "$(OAuth_timestamp)" 'POST' "$T_ACCESS_TOKEN" "$(OAuth_param 'oauth_verifier' "$PIN")"), $(OAuth_param_quote 'oauth_verifier' "$PIN")"

	resp=$(curl -s -d "" -H "$auth_header" "$T_ACCESS_TOKEN")
	TO_rval=$?
	(( $? != 0 )) && return $TO_rval
	
	TO_ret=(
		$(TO_extract_value 'oauth_token' "$resp")
		$(TO_extract_value 'oauth_token_secret' "$resp")
		$(TO_extract_value 'user_id' "$resp")
		$(TO_extract_value 'screen_name' "$resp")
		)
	}

# APIs
######

TO_statuses_update () {
	# $1 format
	# $2 status
	# $3 in_reply_to_status_id
	# The followins are not implemented yet:
	# $4 lat
	# $5 long
	# $6 place_id
	# $7 display_coordinates
	local format="$1"
	[[ "$format" == "" ]] && format="xml"
	
	local params=(
		$(OAuth_param 'status' "$2")
		)
	[[ "$3" != "" ]] && params[${#params[@]}]=$(OAuth_param 'in_reply_to_status_id' "$3") && local in_reply_to_status_id=( '--data-urlencode' "in_reply_to_status_id=$3" )
	
	local auth_header=$(OAuth_authorization_header 'Authorization' 'http://api.twitter.com' '' '' 'POST' "$T_STATUSES_UPDATE.$format" ${params[@]})
	
	TO_ret=$(curl -s -H "$auth_header" --data-urlencode "status=$2" ${in_reply_to_status_id[@]} "$T_STATUSES_UPDATE.$format")

	TO_rval=$?
	return $TO_rval
	}

TO_account_update_profile_image () {
	# $1 format
	# $2 image (filename)
	local format="$1"
	[[ "$format" == "" ]] && format="xml"
	local auth_header=$(OAuth_authorization_header 'Authorization' 'http://api.twitter.com' '' '' 'POST' "$T_ACCOUNT_UPDATE_PROFILE_IMAGE.$format")
	TO_ret=$(curl -s -H "$auth_header" -H "Expect:" -F "image=@$2" "$T_ACCOUNT_UPDATE_PROFILE_IMAGE.$format")
	TO_rval=$?
	return $TO_rval

	}
