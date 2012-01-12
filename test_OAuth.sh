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

source OAuth.sh

oauth_consumer_key='GDdmIQH6jhtmLUypg82g'
oauth_consumer_secret='MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98'
oauth_signature_method='HMAC-SHA1'
oauth_version='1.0'
oauth_nonce='QP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk'
oauth_timestamp='1272323042'
oauth_callback='http://localhost:3005/the_dance/process_callback?service_provider_id=11'

echo "=== Acquiring a request token ===

oauth_consumer_key='GDdmIQH6jhtmLUypg82g'
oauth_consumer_secret='MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98'
oauth_signature_method='HMAC-SHA1'
oauth_version='1.0'
oauth_nonce='QP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk'
oauth_timestamp='1272323042'
oauth_callback='http://localhost:3005/the_dance/process_callback?service_provider_id=11'
"

params=(
  $(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
  $(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
  $(OAuth_param 'oauth_version' "$oauth_version")
  $(OAuth_param 'oauth_nonce' "$oauth_nonce")
  $(OAuth_param 'oauth_timestamp' "$oauth_timestamp")
  $(OAuth_param 'oauth_callback' "$oauth_callback")
  )

base_string=$(OAuth_base_string 'POST' 'https://api.twitter.com/oauth/request_token' ${params[@]})
signature=$(_OAuth_signature "$oauth_signature_method" "$base_string" "$oauth_consumer_secret" "$oauth_token_secret")

echo "base_string=$base_string"
echo
echo "signature=$signature"
echo
params[${#params[@]}]=$(OAuth_param 'oauth_signature' "$signature")
echo "Header: $(_OAuth_authorization_header_params_string ${params[@]})"
echo
echo

#####

oauth_nonce='9zWH6qe0qG7Lc1telCn7FhUbLyVdjEaL3MO5uHxn8'
oauth_timestamp='1272323047'
oauth_token='8ldIZyxQeVrFZXFOZH5tAwj6vzJYuLQpl0WUEYtWc'
oauth_token_secret='x6qpRnlEmW9JbQn4PQVVeVG8ZLPEx6A0TOebgwcuA'
oauth_verifier='pDNg55prOHapMbhv25RNf75lVRd6JDsni1AJJIDYoTY'

echo "=== Exchanging a request token for an access token ===

oauth_nonce='9zWH6qe0qG7Lc1telCn7FhUbLyVdjEaL3MO5uHxn8'
oauth_timestamp='1272323047'
oauth_token='8ldIZyxQeVrFZXFOZH5tAwj6vzJYuLQpl0WUEYtWc'
oauth_token_secret='x6qpRnlEmW9JbQn4PQVVeVG8ZLPEx6A0TOebgwcuA'
oauth_verifier='pDNg57prOHapMbhv25RNf75lVRd6JDsni1AJJIDYoTY'
"

params=(
  $(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
  $(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
  $(OAuth_param 'oauth_version' "$oauth_version")
  $(OAuth_param 'oauth_nonce' "$oauth_nonce")
  $(OAuth_param 'oauth_timestamp' "$oauth_timestamp")
  $(OAuth_param 'oauth_token' "$oauth_token")
  $(OAuth_param 'oauth_verifier' "$oauth_verifier")
  )

base_string=$(OAuth_base_string 'POST' 'https://api.twitter.com/oauth/access_token' ${params[@]})
signature=$(_OAuth_signature "$oauth_signature_method" "$base_string" "$oauth_consumer_secret" "$oauth_token_secret")

echo "base_string=$base_string"
echo
echo "signature=$signature"
echo
params[${#params[@]}]=$(OAuth_param 'oauth_signature' "$signature")
echo "Header $(_OAuth_authorization_header_params_string ${params[@]})"
echo
echo

#####

status='setting up my twitter 私のさえずりを設定する'
oauth_token='819797-Jxq8aYUDRmykzVKrgoLhXSq67TEa5ruc4GJC2rWimw'
oauth_token_secret='J6zix3FfA9LofH0awS24M3HcBYXO5nI1iYe8EfBA'
oauth_nonce='oElnnMTQIZvqvlfXM56aBLAf5noGD0AQR3Fmi7Q6Y'
oauth_timestamp='1272325550'

echo "=== Making a resource request on a user's behalf ===

status='setting up my twitter 私のさえずりを設定する'
oauth_token='819797-Jxq8aYUDRmykzVKrgoLhXSq67TEa5ruc4GJC2rWimw'
oauth_token_secret='J6zix3FfA9LofH0awS24M3HcBYXO5nI1iYe8EfBA'
oauth_nonce='oElnnMTQIZvqvlfXM56aBLAf5noGD0AQR3Fmi7Q6Y'
oauth_timestamp='1272325550'
"

params=(
  $(OAuth_param 'oauth_consumer_key' "$oauth_consumer_key")
  $(OAuth_param 'oauth_signature_method' "$oauth_signature_method")
  $(OAuth_param 'oauth_version' "$oauth_version")
  $(OAuth_param 'oauth_nonce' "$oauth_nonce")
  $(OAuth_param 'oauth_timestamp' "$oauth_timestamp")
  $(OAuth_param 'oauth_token' "$oauth_token")
  $(OAuth_param 'status' "$status")
  )

base_string=$(OAuth_base_string 'POST' 'http://api.twitter.com/1/statuses/update.json' ${params[@]})
signature=$(OAuth_signature "$base_string")

echo "base_string=$base_string"
echo
echo "signature=$signature"
echo
params[${#params[@]}]=$(OAuth_param 'oauth_signature' "$signature")
echo "Header $(_OAuth_authorization_header_params_string ${params[@]})"
echo
echo


