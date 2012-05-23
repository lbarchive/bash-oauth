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

STEREOMOODOAUTH_VERSION=0.1

# Stereomood API endpoints

SM_SEARCH='http://www.stereomood.com/api/search'
SM_SONG_LISTEN='http://www.stereomood.com/api/song/listen'
SM_USER_LIBRARY_SONG='http://www.stereomood.com/api/user/library/song'

SM_REQUEST_TOKEN='http://www.stereomood.com/api/oauth/request_token'
SM_ACCESS_TOKEN='http://www.stereomood.com/api/oauth/access_token'
SM_AUTHORIZE_TOKEN='http://www.stereomood.com/api/oauth/authorize'

# Source OAuth.sh

OAuth_sh=$(which OAuth.sh)
(( $? != 0 )) && echo 'Unable to locate OAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

SM_debug () {
	# Print out all parameters, each in own line
	[[ "$SM_DEBUG" == "" ]] && return
	local t=$(date +%FT%T.%N)
	while (( $# > 0 )); do
		echo "[SM][DEBUG][$t] $1"
		shift 1
		done
	}


SM_extract_value () {
	# $1 key name
	# $2 string to find
	egrep -o "$1=[a-zA-Z0-9-]*" <<< "$2" | cut -d\= -f 2
	}


SM_extract_XML_value () {
	# $1 entity name
	# $2 string to find
	echo -n "$2" | egrep -o "<$1>[^<]+" | sed -e "s/<$1>//"
	}


SM_init() {
	# Initialize TwitterOAuth
	oauth_version='1.0'
	oauth_signature_method='HMAC-SHA1'
	oauth_basic_params=(
		$(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
		$(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
		$(OAuth_param 'oauth_version' "$oauth_version")
		)
	}


SM_access_token_helper () {
	# Help guide user to get access token

	local resp PIN

	# Request Token
	
	local auth_header="$(_OAuth_authorization_header 'Authorization' 'http://www.stereomood.com/' "$oauth_consumer_key" "$oauth_consumer_secret" '' '' "$oauth_signature_method" "$oauth_version" "$(OAuth_nonce)" "$(OAuth_timestamp)" 'POST' "$SM_REQUEST_TOKEN")"
	
	resp=$(curl -s -d '' -H "$auth_header" "$SM_REQUEST_TOKEN")
	SM_rval=$?
	(( $? != 0 )) && return $SM_rval

	local _oauth_token=$(SM_extract_value 'oauth_token' "$resp")
	local _oauth_token_secret=$(SM_extract_value 'oauth_token_secret' "$resp")
	
	echo 'Please go to the following link to get the PIN:'
	echo "  ${SM_AUTHORIZE_TOKEN}?oauth_token=$_oauth_token"
	
	read -p 'PIN: ' PIN

	# Access Token

	local auth_header="$(_OAuth_authorization_header 'Authorization' 'http://www.stereomood.com/' "$oauth_consumer_key" "$oauth_consumer_secret" "$_oauth_token" "$_oauth_token_secret" "$oauth_signature_method" "$oauth_version" "$(OAuth_nonce)" "$(OAuth_timestamp)" 'POST' "$SM_ACCESS_TOKEN" "$(OAuth_param 'oauth_verifier' "$PIN")"), $(OAuth_param_quote 'oauth_verifier' "$PIN")"
	
	resp=$(curl -s -d "" -H "$auth_header" "$SM_ACCESS_TOKEN")
	SM_rval=$?
	(( $? != 0 )) && return $SM_rval
	
	SM_ret=(
		$(SM_extract_value 'oauth_token' "$resp")
		$(SM_extract_value 'oauth_token_secret' "$resp")
		)
	}

# APIs
######

SM_user_library_song () {
	# $1 format
	# $2 id
	
	local format="$1"
	[[ "$format" == "" ]] && format="xml"
	
	local params=(
		)
	
	local auth_header=$(OAuth_authorization_header 'Authorization' 'http://www.stereomood.com' '' '' 'POST' "$SM_USER_LIBRARY_SONG/$2.$format" ${params[@]})

	SM_ret=$(curl -s -d "" -H "$auth_header" "$SM_USER_LIBRARY_SONG/$2.$format")
	SM_rval=$?
	
	return $SM_rval
	}


SM_song_listen () {
	# $1 format
	# $2 id
	
	local format="$1"
	[[ "$format" == "" ]] && format="xml"
	
	local params=(
		)
	
	local auth_header=$(OAuth_authorization_header 'Authorization' 'http://www.stereomood.com' '' '' 'POST' "$SM_SONG_LISTEN/$2.$format" ${params[@]})

	SM_ret=$(curl -s -d "" -H "$auth_header" "$SM_SONG_LISTEN/$2.$format")
	SM_rval=$?
	
	return $SM_rval
	}


SM_search () {
	# $1 format
	# $2 q
	# $3 type
	# Optional:
	# $4 limit
	# $5 page

	local format="$1"
	[[ "$format" == "" ]] && format="xml"
	
	local params=(
		$(OAuth_param 'q' "$2")
		$(OAuth_param 'type' "$3")
		)
	
	[[ "$4" != "" ]] && params[${#params[@]}]=$(OAuth_param 'limit' "$4")
	[[ "$5" != "" ]] && params[${#params[@]}]=$(OAuth_param 'page' "$5")

	local auth_header=$(OAuth_authorization_header 'Authorization' 'http://www.stereomood.com' '' '' 'GET' "$SM_SEARCH.$format" ${params[@]})

	SM_ret=$(curl -s -H "$auth_header" "$SM_SEARCH.$format?$(OAuth_params_string ${params[@]})")
	SM_rval=$?
	
	return $SM_rval
	}


SM_get_search_total () {
	# $1 q
	# $2 type

	SM_search 'xml' "$1" "$2" '1'
	SM_rval=$?

	(( $SM_rval != 0 )) && SM_ret= && return $SM_rval

	SM_ret=$(SM_extract_XML_value 'total' "$SM_ret")
	return $SM_rval
	}

