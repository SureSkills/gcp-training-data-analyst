// Copyright 2017, Google, Inc.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
const config = require('../config');
const {PubSub} = require('@google-cloud/pubsub');

const pubsub = new PubSub({
  projectId: config.get('GCLOUD_PROJECT')
});

const feedbackTopic = pubsub.topic('feedback');
const answerTopic = pubsub.topic('answers');

function publishAnswer(answer) {
  const dataBuffer=Buffer.from(JSON.stringify(answer))
  return answerTopic.publish(dataBuffer);
}

function publishFeedback(feedback) {
  const dataBuffer=Buffer.from(JSON.stringify(feedback))
  return feedbackTopic.publish(dataBuffer);
}



// [START exports]
module.exports = {
  publishAnswer,
  publishFeedback,
  
};
// [END exports]
