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

# Gmail non-public-API endpoints

GMAIL_UNREAD='https://mail.google.com/mail/feed/atom/'

GMAIL_REQUEST_TOKEN='https://www.google.com/accounts/OAuthGetRequestToken'
GMAIL_ACCESS_TOKEN='https://www.google.com/accounts/OAuthAuthorizeToken'
GMAIL_AUTHORIZE_TOKEN='https://www.google.com/accounts/OAuthGetAccessToken'

GMAIL_SCOPE='https://mail.google.com/mail/feed/atom/'

# Source OAuth.sh

OAuth_sh=$(which OAuth.sh)
(( $? != 0 )) && echo 'Unable to locate OAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

GMAIL_debug () {
	# Print out all parameters, each in own line
	[[ "$GMAIL_DEBUG" == "" ]] && return
	local t=$(date +%FT%T.%N)
	while (( $# > 0 )); do
		echo "[GMAIL][DEBUG][$t] $1"
		shift 1
		done
	}

GMAIL_nonce () {
	echo "$RANDOM$RANDOM"
	}

GMAIL_extract_value () {
	# $1 key name
	# $2 string to find
	egrep -o "$1=[a-zA-Z0-9-]*" <<< "$2" | cut -d\= -f 2
	}


SM_extract_XML_value () {
	# $1 entity name
	# $2 string to find
	echo -n "$2" | egrep -o "<$1>[^<]+" | sed -e "s/<$1>//"
	}


GMAIL_init() {
	# Initialize TwitterOAuth
	oauth_version='1.0'
	oauth_signature_method='HMAC-SHA1'
	oauth_basic_params=(
		$(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
		$(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
		$(OAuth_param 'oauth_version' "$oauth_version")
		)
	}


GMAIL_access_token_helper () {
	# Help guide user to get access token

	local resp PIN

	# Request Token
	
	local auth_header="$(_OAuth_authorization_header 'Authorization' '' "$oauth_consumer_key" "$oauth_consumer_secret" '' '' "$oauth_signature_method" "$oauth_version" "$(GMAIL_nonce)" "$(OAuth_timestamp)" 'POST' "$GMAIL_REQUEST_TOKEN", "$(OAuth_param_quote 'scope' "$GMAIL_SCOPE")")"
	#local auth_header="$(_OAuth_authorization_header 'Authorization' '' "$oauth_consumer_key" "$oauth_consumer_secret" '' '' "$oauth_signature_method" "$oauth_version" "$(GMAIL_nonce)" "$(OAuth_timestamp)" 'POST' "$GMAIL_REQUEST_TOKEN?scope=https%3A%2F%2Fmail.google.com%2Fmail%2Ffeed%2Fatom%2F", "$(OAuth_param_quote 'oauth_callback' "oob")", "$(OAuth_param_quote 'scope' "$GMAIL_SCOPE")"), $(OAuth_param_quote 'oauth_callback' "oob")"
#	echo "$auth_header"
	#resp=$(curl -v -d "scope=$GMAIL_SCOPE" -H "$auth_header" "$GMAIL_REQUEST_TOKEN")
	#resp=$(curl -v -d "scope=$(OAuth_PE $GMAIL_SCOPE)" -H "$auth_header" "$GMAIL_REQUEST_TOKEN")
	#resp=$(curl -v -d '' -H "$auth_header" "$GMAIL_REQUEST_TOKEN?scope=$GMAIL_SCOPE")
	resp=$(curl -v -d "scope=$GMAIL_SCOPE" -H "$auth_header" "$GMAIL_REQUEST_TOKEN")
	GMAIL_rval=$?
	echo "$resp"
	(( $? != 0 )) && return $GMAIL_rval

	local _oauth_token=$(GMAIL_extract_value 'oauth_token' "$resp")
	local _oauth_token_secret=$(GMAIL_extract_value 'oauth_token_secret' "$resp")
	
	echo 'Please go to the following link to get the PIN:'
	echo "  ${GMAIL_AUTHORIZE_TOKEN}?oauth_token=$_oauth_token"
	
	read -p 'PIN: ' PIN

	# Access Token

	local auth_header="$(_OAuth_authorization_header 'Authorization' '' "$oauth_consumer_key" "$oauth_consumer_secret" "$_oauth_token" "$_oauth_token_secret" "$oauth_signature_method" "$oauth_version" "$(OAuth_nonce)" "$(OAuth_timestamp)" 'POST' "$GMAIL_ACCESS_TOKEN" "$(OAuth_param 'oauth_verifier' "$PIN")"), $(OAuth_param_quote 'oauth_verifier' "$PIN")"
	
	resp=$(curl -s -d "" -H "$auth_header" "$GMAIL_ACCESS_TOKEN")
	GMAIL_rval=$?
	(( $? != 0 )) && return $GMAIL_rval
	
	GMAIL_ret=(
		$(GMAIL_extract_value 'oauth_token' "$resp")
		$(GMAIL_extract_value 'oauth_token_secret' "$resp")
		)
	}

# APIs
######

GMAIL_unread () {
	# Get unread emails

	local params=(
		)

	local auth_header=$(OAuth_authorization_header 'Authorization' '' '' '' 'GET' "$GM_UNREAD" ${params[@]})

	GM_ret=$(curl -s -H "$auth_header" "$GM_UNREAD")
	GM_rval=$?
	
	return $GM_rval
	}
