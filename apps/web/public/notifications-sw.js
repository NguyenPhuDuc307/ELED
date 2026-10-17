// Only handles notifications; app requests and browser caches remain untouched.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', event => event.waitUntil(self.clients.claim()));
self.addEventListener('push', event => {
  event.waitUntil((async () => {
    let payload;
    try { payload = event.data?.json(); } catch { /* Always show a visible notification. */ }
    payload ||= { title: 'ELED', body: 'Đến giờ học từ vựng. / Time to learn vocabulary.' };
    await self.registration.showNotification(payload.title || 'ELED', {
      body: payload.body, icon: '/icon.png', badge: '/icon.png', tag: payload.tag || 'eled-vocabulary',
      data: { url: '/#/history' },
    });
    const tabs = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    tabs.forEach(tab => tab.postMessage({ type: 'eled-push' }));
  })());
});
self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil((async () => {
    const target = new URL('/#/history', self.location.origin).href;
    const tabs = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const tab of tabs) {
      if (new URL(tab.url).origin === self.location.origin) {
        await tab.navigate(target);
        return tab.focus();
      }
    }
    return self.clients.openWindow(target);
  })());
});
