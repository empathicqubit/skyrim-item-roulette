const CDP = require('chrome-remote-interface');
const waitPort = require('wait-port')
const util = require('util')

const main = async() => {
    const port = parseInt(process.env.KICK_PORT);
    await waitPort({
        host: '127.0.0.1',
        port: port,
    })
    let client;
    while(!client) {
        try {
            client = await CDP({
                host: '127.0.0.1',
                port: port,
            });
        }
        catch(e) {
            console.error(e);
        }
    }
    console.log('Connected to CDP')
    let target;
    while(!target || splash) {
        await new Promise(res => setTimeout(res, 100))
        const targets = await client.Target.getTargets();
        splash = targets.targetInfos.find(y => y.url.endsWith('splash.html'))
        target = targets.targetInfos.find(y => y.url.endsWith('index.html'))
    }
    console.log('Found target!')
    await new Promise(res => client.close(res));
    client = await CDP({
        host: '127.0.0.1',
        port: port,
    });
    await client.Runtime.evaluate({
        awaitPromise: true,
        expression: '(' + (async function() {
            await new Promise(function(res, rej) {
                async function handler() {
                    if(_API && _API.events && _API.events.emit) {
                        await _API.awaitUI();
                        _API.events.emit("deploy-mods", res);
                    }
                    else {
                        setTimeout(handler, 100);
                    }
                }
                handler();
            });
        }).toString() + ')()'
    })
    client.close();
    console.log('Finished everything!')
};

main().catch(console.error)