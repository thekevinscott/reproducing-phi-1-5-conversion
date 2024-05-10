import http from 'http';
import querystring from 'querystring';
import url from 'url';

import { pipeline, env } from '@xenova/transformers';

env.localModelPath = '/models/';
env.allowRemoteModels = false;

const model = await pipeline("text-generation", "phi-1_5_dev");
const prompt = 'Write me a poem';
const response = await model(prompt);
console.log(response);
