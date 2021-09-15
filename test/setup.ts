import { exec, execSync } from 'child_process';
import { promisify } from 'util';
const asyncExec = promisify(exec);
import path from 'path';

const standaloneWaitTime = 60000;

console.log(`Setting up pulsar standalone`);

(async () => {
  try {
    await asyncExec('docker --help');
  } catch (e) {
    console.log('Docker must be installed on the running host');
    process.exit(1);
  }

  const containerName = 'pulsar-standalone-abap-pulsar';
  try {
    console.log('Removing old deployments..');
    await asyncExec(`docker rm ${containerName} -f`);
    console.log(`Successfully found and removed docker with name ${containerName}`);
  } catch (e) {
    // not found, ok
  }

  execSync("docker pull apachepulsar/pulsar:2.8.0", {stdio: "inherit"});

  const dockerComposeFilePath = path.join(__dirname, `docker-compose.yml`);

  console.log(`Creating pulsar via docker-compose from path ${dockerComposeFilePath}`);

  asyncExec(`docker-compose -f ${dockerComposeFilePath} up --build`)
    .then((m) => {console.dir(m); console.log('docker-compose gracefully shut down');})
    .catch((e) => console.log(`docker-compose killed ${e}`));

  console.log(`Waiting ${standaloneWaitTime}ms for pulsar-standalone to start`);

  await new Promise((resolve) => setTimeout(resolve, standaloneWaitTime));

  console.log(`Validating pulsar is up`);

  const { stdout } = await asyncExec(`docker ps`);

  if (!stdout.includes(containerName)) {
    throw new Error(
      containerName +
        'has been closed, tests setup aborted - maybe try to increase wait standaloneWaitTime'
    );
  } else {
    console.log(`Found a running pulsar container, continuing`);
  }

  console.log('Creating test topic public/default/test');
  await asyncExec(
    `docker exec ${containerName} /pulsar/bin/pulsar-admin topics create public/default/test`
  );
  console.log('Creating subscription subscription');

  await asyncExec(
    `docker exec ${containerName} /pulsar/bin/pulsar-admin topics create-subscription -s subscription public/default/test`
  );

  console.log('You can run the your tests now!');
  process.exit(0);
})();