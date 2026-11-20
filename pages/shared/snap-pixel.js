(() => {
  'use strict';
  if (window.safwatPixelReady) return;
  window.safwatPixelReady = true;

  const pixelId = '070d7c58-8d60-4a03-a0a8-99455901ea3b';
  const preferenceKey = 'safwat-snap-marketing-v1';
  let allowed = false;
  let initialized = false;
  let pageViewSent = false;

  function readPreference() {
    try { return localStorage.getItem(preferenceKey); } catch { return null; }
  }

  function startPixel() {
    if (!allowed) return;
    if (!initialized) {
      if (!window.snaptr) {
        const snaptr = function () {
          if (snaptr.handleRequest) snaptr.handleRequest.apply(snaptr, arguments);
          else snaptr.queue.push(arguments);
        };
        snaptr.queue = [];
        window.snaptr = snaptr;
        const sdk = document.createElement('script');
        sdk.async = true;
        sdk.src = 'https://sc-static.net/scevent.min.js';
        document.head.append(sdk);
      }
      window.snaptr('init', pixelId);
      initialized = true;
    }
    if (!pageViewSent) {
      window.snaptr('track', 'PAGE_VIEW');
      pageViewSent = true;
    }
  }

  function contactEvent(destination) {
    if (!allowed || !initialized || typeof destination !== 'string') return;
    let url;
    try { url = new URL(destination, location.href); } catch { return; }
    if (url.protocol === 'tel:') window.snaptr('track', 'CUSTOM_EVENT_1');
    if (url.protocol === 'https:' &&
        ['wa.me', 'api.whatsapp.com'].includes(url.hostname)) {
      window.snaptr('track', 'CUSTOM_EVENT_2');
    }
  }

  const settings = document.querySelector('[data-safwat-privacy]');

  const dialog = document.createElement('dialog');
  dialog.dir = 'rtl';
  dialog.setAttribute('aria-label', 'خصوصية الإعلانات');
  dialog.style.cssText = 'max-width:min(360px,85vw);border:1px solid #ddd;border-radius:12px;padding:18px;color:#132638;background:#fff;font:16px system-ui';
  dialog.innerHTML = '<p>هل توافق على استخدام Snapchat Pixel لقياس زيارات الصفحات ونقرات الاتصال وواتساب؟ قد يستخدم سناب ملفات تعريف الارتباط لهذا القياس. يمكنك تغيير اختيارك من إعدادات الخصوصية في صفحة التواصل.</p><button type="button" data-choice="allow">أوافق</button> <button type="button" data-choice="deny">رفض</button>';
  if (settings) document.body.append(dialog);
  settings?.addEventListener('click', () => dialog.showModal());
  dialog.addEventListener('click', (event) => {
    const choice = event.target.closest('button[data-choice]')?.dataset.choice;
    if (!choice) return;
    const hadStarted = initialized;
    allowed = choice === 'allow';
    let saved = false;
    try { localStorage.setItem(preferenceKey, choice); saved = true; } catch {}
    dialog.close();
    if (allowed) startPixel();
    else if (hadStarted && saved) location.reload();
  });
  allowed = readPreference() === 'allow';
  startPixel();

  document.addEventListener('click', (event) => {
    if (!event.isTrusted || event.defaultPrevented) return;
    const link = event.composedPath().find((element) => element instanceof HTMLAnchorElement);
    if (link) contactEvent(link.href);
  });

  // Flutter's web URL launcher calls window.open rather than rendering a link.
  if (document.currentScript?.hasAttribute('data-flutter')) {
    const open = window.open;
    window.open = function (...args) {
      contactEvent(args[0]);
      return Reflect.apply(open, this, args);
    };
  }
})();
