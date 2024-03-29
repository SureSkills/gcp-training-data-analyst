#!/bin/bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Creating Datastore/App Engine instance"
gcloud app create --region "us-central"

echo "Creating bucket: gs://$DEVSHELL_PROJECT_ID-media"
gsutil mb gs://$DEVSHELL_PROJECT_ID-media

echo "Exporting GCLOUD_PROJECT and GCLOUD_BUCKET"
export GCLOUD_PROJECT=$DEVSHELL_PROJECT_ID
export GCLOUD_BUCKET=$DEVSHELL_PROJECT_ID-media

#echo "Creating virtual environment"
#mkdir ~/venvs
#pip2 install virtualenv
#virtualenv --python=/usr/bin/python2.7 ~/venvs/developingapps
#source ~/venvs/developingapps/bin/activate

echo "Installing Python libraries"
sudo pip2 install --upgrade pip
sudo pip2 install -r requirements.txt

echo "Creating Datastore entities"
python add_entities.py

echo "Project ID: $DEVSHELL_PROJECT_ID"
