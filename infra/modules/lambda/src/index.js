const Koa = require('koa');
const serverless = require('serverless-http');
const copernicusApi = require('copernicus-api');

const handler = serverless(copernicusApi.getConfiguredApp(new Koa()));

exports.handler = async (event, context) => {
    event.rawPath = event.rawPath.replace(/^\/v1/, '');
    return await handler(event, context);
};
