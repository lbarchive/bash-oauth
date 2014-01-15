#!/bin/bash
# Copyright (c) 2014 Mathew Paret
# Copyright (c) 2012 Michael Nowack
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

TWITTEROAUTH_VERSION=0.2.0

T_API_VERSION="1.1"

# Twitter API endpoints

T_ACCOUNT_UPDATE_PROFILE_IMAGE="https://api.twitter.com/$T_API_VERSION/account/update_profile_image"
T_STATUSES_UPDATE="https://api.twitter.com/$T_API_VERSION/statuses/update"
T_STATUSES_HOME_TIMELINE="https://api.twitter.com/${T_API_VERSION}/statuses/home_timeline"

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
  # $1 status
  # $2 in_reply_to_status_id
  # The followins are not implemented yet:
  # $3 lat
  # $4 long
  # $5 place_id
  # $6 display_coordinates
  local format="json"
  
  local params=(
    $(OAuth_param 'status' "$1")
    )
  [[ "$2" != "" ]] && params[${#params[@]}]=$(OAuth_param 'in_reply_to_status_id' "$2") && local in_reply_to_status_id=( '--data-urlencode' "in_reply_to_status_id=$2" )
  
  local auth_header=$(OAuth_authorization_header 'Authorization' 'http://api.twitter.com' '' '' 'POST' "$T_STATUSES_UPDATE.$format" ${params[@]})
  
  TO_ret=$(curl -s -H "$auth_header" --data-urlencode "status=$1" ${in_reply_to_status_id[@]} "$T_STATUSES_UPDATE.$format")

  TO_rval=$?
  return $TO_rval
  }

TO_account_update_profile_image () {
  # $1 image (filename)
  local format="json"
  
  local auth_header=$(OAuth_authorization_header 'Authorization' 'http://api.twitter.com' '' '' 'POST' "$T_ACCOUNT_UPDATE_PROFILE_IMAGE.$format")

  TO_ret=$(curl -s -H "$auth_header" -H "Expect:" -F "image=@$1" "$T_ACCOUNT_UPDATE_PROFILE_IMAGE.$format")

  TO_rval=$?
  return $TO_rval
  }

# gets the user home_timeline.
#
# @sets TO_ret API response
# @returns status
# @public
TO_statuses_home_timeline () {
  # $1 screen_name
  # $2 count
  local format="json"
  local screen_name="$1"
  local count="$2"
  [[ "$count" == "" ]] && count=1

  local params=(
    $(OAuth_param 'screen_name' $screen_name)
    $(OAuth_param 'count' $count)
    )

  local auth_header=$(OAuth_authorization_header 'Authorization' 'http://api.twitter.com' '' '' 'GET' "$T_STATUSES_HOME_TIMELINE.$format" ${params[@]})

  convscreen=$(OAuth_PE "$screen_name");
  TO_ret=$(curl -s --get "${T_STATUSES_HOME_TIMELINE}.${format}" --data "screen_name=${convscreen}&count=${count}" --header "${auth_header}")
  TO_rval=$?

  return $TO_rval
  }
