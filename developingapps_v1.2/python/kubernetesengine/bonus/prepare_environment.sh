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

echo "Creating virtual environment"
mkdir ~/venvs
pip2 install virtualenv
virtualenv --python=/usr/bin/python2.7 ~/venvs/developingapps
#virtualenv ~/venvs/developingapps
source ~/venvs/developingapps/bin/activate

echo "Installing Python libraries"
pip2 install --upgrade pip
pip2 install -r requirements.txt
pip2 freeze > requirements.txt

echo "Creating Datastore entities"
python add_entities.py

echo "Creating quiz-account Service Account"
gcloud iam service-accounts create quiz-account --display-name "Quiz Account"
gcloud iam service-accounts keys create key.json --iam-account=quiz-account@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=key.json

echo "Setting quiz-account IAM Role"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:quiz-account@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/owner

echo "Creating Cloud Pub/Sub topics"
gcloud pubsub topics create feedback
gcloud pubsub topics create answers
gcloud pubsub subscriptions create worker-subscription --topic feedback
gcloud pubsub subscriptions create answer-subscription --topic answers

echo "Creating Cloud Spanner Instance, Database, and Tables"
gcloud spanner instances create quiz-instance --config=regional-us-central1 --description="Quiz instance" --nodes=1
gcloud spanner databases create quiz-database --instance quiz-instance --ddl "CREATE TABLE Feedback ( feedbackId STRING(100) NOT NULL, email STRING(100), quiz STRING(20), feedback STRING(MAX), rating INT64, score FLOAT64, timestamp INT64 ) PRIMARY KEY (feedbackId); CREATE TABLE Answers (answerId STRING(100) NOT NULL, id INT64, email STRING(60), quiz STRING(20), answer INT64, correct INT64, timestamp INT64) PRIMARY KEY (answerId DESC);"

echo "Creating Container Engine cluster"
gcloud container clusters create quiz-cluster --zone us-central1-a --scopes cloud-platform
gcloud container clusters get-credentials quiz-cluster --zone us-central1-a

echo "Building Containers"
gcloud builds submit -t gcr.io/$DEVSHELL_PROJECT_ID/quiz-frontend ./frontend/
gcloud builds submit -t gcr.io/$DEVSHELL_PROJECT_ID/quiz-backend ./backend/
gcloud builds submit -t gcr.io/$DEVSHELL_PROJECT_ID/quiz-answer-backend ./answer_backend/

echo "Deploying to Container Engine"
sed -i -e "s/\[GCLOUD_PROJECT\]/$DEVSHELL_PROJECT_ID/g" ./frontend-deployment.yaml
sed -i -e "s/\[GCLOUD_PROJECT\]/$DEVSHELL_PROJECT_ID/g" ./backend-deployment.yaml
sed -i -e "s/\[GCLOUD_PROJECT\]/$DEVSHELL_PROJECT_ID/g" ./answer-backend-deployment.yaml
kubectl apply -f ./frontend-deployment.yaml
kubectl apply -f ./backend-deployment.yaml
kubectl apply -f ./answer-backend-deployment.yaml
kubectl apply -f ./frontend-service.yaml

echo "Project ID: $DEVSHELL_PROJECT_ID"