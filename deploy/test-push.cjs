// Run inside the API container. Uses an isolated PG schema and mock push transport.
const assert = require('node:assert/strict');
const { randomBytes, createECDH } = require('node:crypto');
const { Pool } = require('pg');
const webpush = require('web-push');
const { PushController, initPush, runPushTick } = require('/app/dist/push');
const schema = 'eled_push_qa_' + randomBytes(6).toString('hex');
const admin = new Pool({ connectionString: process.env.DATABASE_URL });
const pool = new Pool({ connectionString: process.env.DATABASE_URL, options: '-c search_path=' + schema });
const delivered = [];
let expire = false;
webpush.sendNotification = async (_, payload, options) => {
  assert.equal(options.topic, undefined, "Omit optional Topic header for Apple compatibility");
  if (expire) throw Object.assign(new Error('expired'), { statusCode: 410 });
  delivered.push(JSON.parse(payload));
  return { statusCode: 201 };
};
(async () => {
  await admin.query('CREATE SCHEMA ' + schema);
  const keys = webpush.generateVAPIDKeys();
  process.env.VAPID_PUBLIC_KEY = keys.publicKey;
  process.env.VAPID_PRIVATE_KEY = keys.privateKey;
  await initPush(pool, [
    ['cat', 'mèo', 'noun', '/kæt/', '', '', ['A1'], ['Animals - Pets']],
    ['dog', 'chó', 'noun', '/dɒɡ/', '', '', ['A1'], ['Animals - Pets']],
    ['car', 'xe', 'noun', '', '', '', ['A1'], ['Travel']],
  ]);
  const controller = new PushController();
  const token = randomBytes(32).toString('hex');
  const ecdh = createECDH('prime256v1'); ecdh.generateKeys();
  const subscription = { endpoint: 'https://fcm.googleapis.com/fcm/send/eled-isolated-test', keys: { p256dh: ecdh.getPublicKey().toString('base64url'), auth: randomBytes(16).toString('base64url') } };
  const settings = { interval: 30, count: 2, start: '00:00', end: '23:59', timezone: 'UTC', levels: ['A1'], topics: ['Animals'], excluded: ['dog'], language: 'vi' };
  const req = { ip: 'isolated-test' };
  const res = { setHeader() {} };
  await assert.rejects(controller.status('bad', res));
  await controller.save(token, { subscription, settings }, req);
  const now = new Date('2026-10-16T05:00:00Z');
  await pool.query('UPDATE eled_push_devices SET next_at=$1', [new Date(now.getTime() - 60000)]);
  // Refreshing identical settings must not postpone a pending reminder.
  const before = (await controller.status(token, res)).nextAt;
  await controller.save(token, { subscription, settings }, req);
  assert.equal(String((await controller.status(token, res)).nextAt), String(before));
  await runPushTick(now);
  await runPushTick(now);
  assert.equal(delivered.length, 1);
  assert.deepEqual(delivered[0].words, ['cat']);
  assert.ok(delivered[0].body.includes('/kæt/'));
  const status = await controller.status(token, res);
  assert.equal(status.history.length, 1);
  assert.ok(status.nextAt > now);
  await controller.exclude(token, { words: ['cat'] });
  await pool.query('UPDATE eled_push_devices SET next_at=$1', [now]);
  await runPushTick(now);
  assert.equal(delivered.length, 1, 'Immediately excludes a newly known word from reminders');
  await pool.query('UPDATE eled_push_devices SET next_at=$1,settings=jsonb_set(jsonb_set(settings,\'{start}\',\'"02:00"\'),\'{end}\',\'"04:00"\')', [now]);
  await runPushTick(now);
  assert.equal(delivered.length, 1, 'Quiet hours prevent a late send');
  await controller.test(token);
  assert.equal(delivered.length, 2);
  assert.ok(delivered[1].title.includes('Thông báo thử'));
  await controller.save(token, { subscription, settings }, req);
  expire = true;
  await pool.query('UPDATE eled_push_devices SET next_at=$1', [now]);
  await runPushTick(now);
  assert.equal((await controller.status(token, res)).active, false);
  expire = false;
  await controller.save(token, { subscription, settings }, req);
  await controller.remove(token);
  await runPushTick(now);
  assert.equal(delivered.length, 2);
  console.log('PASS: PostgreSQL subscription/save, schedule claims, quiet hours, filtered IPA payload, history, test push, expiry and disable');
})().catch(error => { console.error(error.message); process.exitCode = 1; }).finally(async () => {
  await pool.end();
  await admin.query('DROP SCHEMA IF EXISTS ' + schema + ' CASCADE');
  await admin.end();
  process.exit(process.exitCode || 0);
});
