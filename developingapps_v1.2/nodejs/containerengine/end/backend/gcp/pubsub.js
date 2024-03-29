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


function publishFeedback(feedback) {
  const dataBuffer=Buffer.from(JSON.stringify(feedback))
  return feedbackTopic.publish(dataBuffer);
}


function registerFeedbackNotification(cb) {

  feedbackTopic.createSubscription('feedback-subscription', { autoAck: true }, (err, subscription) => {
      // subscription already exists
      if (err && err.code == 6) {
          console.log("Feedback subscription already exists")
      }
  });

  const feedbackSubscription=feedbackTopic.subscription('feedback-subscription', { autoAck: true });    
  feedbackSubscription.get().then(results => {
      const subscription    = results[0];
      
      subscription.on('message', message => {
          cb(message.data);
      });

      subscription.on('error', err => {
          console.error(err);
      });
  }).catch(error => { console.log("Error getting feedback subscription", error)});;

}

// [START exports]
module.exports = {
  publishFeedback,
  registerFeedbackNotification,
};
// [END exports]
