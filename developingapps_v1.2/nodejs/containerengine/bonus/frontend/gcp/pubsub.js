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

'use strict';

const config = require('../config');
const {PubSub} = require('@google-cloud/pubsub');

const GCLOUD_PROJECT = config.get('GCLOUD_PROJECT');

const pubsub = new PubSub({GCLOUD_PROJECT});
const feedbackTopic = pubsub.topic('feedback');
const answerTopic = pubsub.topic('answers');

function publishFeedback(feedback) {
  const dataBuffer=Buffer.from(JSON.stringify(feedback))
  return feedbackTopic.publish(dataBuffer);
}

function registerFeedbackNotification(cb) {
    const feedbackSubscription = feedbackTopic.subscription('worker-subscription', { autoAck: true });
    feedbackSubscription.get().then(results => {
        const subscription    = results[0];
        
        subscription.on('message', message => {
            cb(message.data);
        });

        subscription.on('error', err => {
            console.error(err);
        });
    });
    
}

function publishAnswer(answer) {
  const dataBuffer=Buffer.from(JSON.stringify(answer))
  return answerTopic.publish(dataBuffer);
}

// [START exports]
module.exports = {
  publishFeedback,
  publishAnswer,
  registerFeedbackNotification,
};
// [END exports]
