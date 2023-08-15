// const axios = require('axios')
// const url = 'http://checkip.amazonaws.com/';
const https = require('https');

/**
 *
 * Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format
 * @param {Object} event - API Gateway Lambda Proxy Input Format
 *
 * Context doc: https://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-context.html 
 * @param {Object} context
 *
 * Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
 * @returns {Object} object - API Gateway Lambda Proxy Output Format
 * 
 */

async function getJson() {
    return new Promise(async (resolve, reject) => {
        const DEV_JSON = "https://dev-funky-fresh-webdev-work-bucket-baby123.s3.amazonaws.com/reimagineTopnavConfigs.json"
        const PROD_JSON = "https://prod-cdn-work-test.bski.one/reimagineTopnavConfigs.json"

        const req = https.get(DEV_JSON, (res) => {
            let data = '';
            let obj = {};

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                console.log('')
                console.log('we are back baby')
                console.log('')
                // console.log(data);
                obj = JSON.parse(data);
                resolve(data);
            });
        })
        req.on("error", (err) => {
            console.log("Error: " + err.message);
            reject(e);
        });
    })
}

exports.lambdaHandler = async (event, context) => {
    const httpMethod = event.httpMethod;

    const queryStringParameters = event.queryStringParameters;
    const headers = event.headers;
    const body = event.body;
    console.log("httpMethod:", httpMethod);
    console.log("queryStringParameters: %j", queryStringParameters);
    console.log("headers: %j", headers);
    console.log("body: " + body);
    console.log("");
    console.log(queryStringParameters.language);
    console.log();
    console.log();
    console.log();
    let x = await getJson();
    console.log("x")
    console.log("x")
    console.log("x")
    console.log("x")
    console.log("x")
    var count = Object.keys(x).length;
    console.log(count)
    // console.log(x)
    const html = `
        <html>
            <head>
                <title>My HTML Page</title>
            </head>
            <body>
                <h1>Welcome to my Lambda function! 123</h1>
            </body>
        </html>
    `;

    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html',
        },
        body: html,
    };

    return response;

};



// exports.lambdaHandler = async (event, context) => {
//     try {
//         // const ret = await axios(url);
//         response = {
//             'statusCode': 200,
//             'body': JSON.stringify({
//                 message: 'hello world, shazam v3 -------------z',
//                 // location: ret.data.trim()
//             })
//         }
//     } catch (err) {
//         console.log(err);
//         return err;
//     }

//     return response
// };
