import { test } from 'node:test';
import assert from 'node:assert/strict';
import { inActiveHours, nextReminder, reminderMeaning, reminderPayload, selectReminderWords, validatePushSubscription, validateReminder, type ReminderSettings } from './push-schedule';
const settings: ReminderSettings = { interval: 30, count: 2, start: '09:00', end: '19:00', timezone: 'Asia/Ho_Chi_Minh', levels: ['A1'], topics: [], excluded: [], language: 'vi' };
test('Respects active hours in device timezone and full interval, including after server restarts', () => {
  assert.equal(nextReminder(new Date('2026-10-16T02:00:45Z'), settings).toISOString(), '2026-10-16T02:30:00.000Z');
  assert.equal(nextReminder(new Date('2026-10-16T11:50:00Z'), settings).toISOString(), '2026-10-17T02:00:00.000Z');
  assert.equal(inActiveHours(new Date('2026-10-16T12:00:00Z'), settings), false);
  assert.equal(inActiveHours(new Date('2026-10-16T01:59:00Z'), settings), false);
});
test('Overnight windows and daylight saving transition use local clock', () => {
  const overnight = { ...settings, start: '22:00', end: '06:00' };
  assert.equal(inActiveHours(new Date('2026-10-16T18:00:00Z'), overnight), true);
  assert.equal(nextReminder(new Date('2026-10-16T00:00:00Z'), overnight).toISOString(), '2026-10-16T15:00:00.000Z');
  const dst = { ...settings, timezone: 'America/New_York' };
  assert.equal(nextReminder(new Date('2026-11-01T05:30:00Z'), dst).toISOString(), '2026-11-01T14:00:00.000Z');
});
test('Validates reminder bounds and disallows internal or untrusted push endpoints', () => {
  assert.throws(() => validateReminder({ ...settings, interval: 0 }));
  assert.throws(() => validateReminder({ ...settings, count: 6 }));
  assert.throws(() => validateReminder({ ...settings, start: '25:00' }));
  assert.throws(() => validateReminder({ ...settings, end: settings.start }));
  assert.throws(() => validateReminder({ ...settings, timezone: 'bad/timezone' }));
  const keys = { p256dh: 'B'.repeat(87), auth: 'a'.repeat(22) };
  assert.throws(() => validatePushSubscription({ endpoint: 'https://127.0.0.1/push', keys }));
  assert.throws(() => validatePushSubscription({ endpoint: 'https://fcm.googleapis.com.attacker.com/push', keys }));
  assert.throws(() => validatePushSubscription({ endpoint: 'http://fcm.googleapis.com/push', keys }));
  assert.equal(validatePushSubscription({ endpoint: 'https://fcm.googleapis.com/fcm/send/test', keys }).keys.auth, keys.auth);
});
test('Uses vocabulary filters, excludes known words, rotates and includes IPA in notifications', () => {
  const vocabulary = [
    ['cat','mèo','noun','/kæt/','','',['A1'],['Animals - Pets']],
    ['dog','chó','noun','/dɒɡ/','','',['A1'],['Animals - Pets']],
    ['car','xe','noun','','','',['A1'],['Travel']],
    ['rare','hiếm','adjective','','','',['C1'],['Animals']],
  ];
  const filtered = { ...settings, topics: ['Animals'], excluded: ['dog'] };
  const words = selectReminderWords(vocabulary, filtered, 3);
  assert.equal(words.length, 1);
  assert.equal(words[0][0], 'cat');
  assert.equal(selectReminderWords(vocabulary, { ...settings, count: 1 }, 1)[0][0], 'dog');
  const payload = reminderPayload(words, 'vi');
  // Một từ: tiêu đề là chính từ + phiên âm, thân là nghĩa.
  assert.equal(payload.title, 'cat /kæt/');
  assert.equal(payload.body, 'mèo');
  const many = reminderPayload(vocabulary.slice(0, 2), 'vi');
  assert.equal(many.title, 'cat · dog');
  assert.equal(many.body, 'cat: mèo\ndog: chó');
  assert.deepEqual(payload.words, ['cat']);
  assert.deepEqual(selectReminderWords([], settings, 0), []);
});
test('Reminders stay on the clock grid from the window start instead of drifting', () => {
  const hourly = { ...settings, interval: 60 };
  // Sent a few seconds late (15 s scheduler tick): the next one is still exactly 10:00, not 09:59 or 10:00:12.
  assert.equal(nextReminder(new Date('2026-10-16T02:00:12Z'), hourly).toISOString(), '2026-10-16T03:00:00.000Z');
  assert.equal(nextReminder(new Date('2026-10-16T02:59:40Z'), hourly).toISOString(), '2026-10-16T03:00:00.000Z');
  // Odd intervals count from the window start: 09:00, 09:25, 09:50…
  assert.equal(nextReminder(new Date('2026-10-16T02:00:05Z'), { ...settings, interval: 25 }).toISOString(), '2026-10-16T02:25:00.000Z');
  // Window starting off the hour keeps its own grid: 08:15, 09:15…
  assert.equal(nextReminder(new Date('2026-10-16T01:20:00Z'), { ...hourly, start: '08:15' }).toISOString(), '2026-10-16T02:15:00.000Z');
  // Overnight window wraps past midnight on the same grid.
  assert.equal(nextReminder(new Date('2026-10-16T17:00:30Z'), { ...hourly, start: '22:00', end: '06:00' }).toISOString(), '2026-10-16T18:00:00.000Z');
});
test('Notification meanings keep only the core sense of each part of speech', () => {
  const swing = ['swing', 'v. đu đưa… · n. sự đu đưa…', 'verb; noun', '', '', '', ['B1'], [],
    [['verb', ['đu đưa, đong đưa, đung đưa, lúc lắc, vung vẩy; lắc, lay']], ['noun', ['sự đu đưa, sự lúc lắc; độ đu đưa']]]];
  assert.equal(reminderMeaning(swing), 'v. đu đưa, đong đưa, đung đưa · n. sự đu đưa, sự lúc lắc');
  assert.equal(reminderMeaning(['cat', 'mèo', 'noun']), 'mèo');
});
