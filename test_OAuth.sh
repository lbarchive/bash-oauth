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


