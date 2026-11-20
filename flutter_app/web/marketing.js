(() => {
  'use strict';

  const config = window.safwatMarketingConfig;
  const preferenceKey = 'safwat-snap-marketing-v1';
  let allowed = false;
  let currentPage;
  let lastSentPage;
  let initialized = false;

  try {
    allowed = localStorage.getItem(preferenceKey) === 'allow';
  } catch {
    // Tracking stays off when the preference is unavailable.
  }

  function loadScript(src) {
    const script = document.createElement('script');
    script.async = true;
    script.src = src;
    document.head.append(script);
  }

  function initializeSnap(pixelId) {
    const snaptr = function () {
      if (snaptr.handleRequest) snaptr.handleRequest.apply(snaptr, arguments);
      else snaptr.queue.push(arguments);
    };
    snaptr.queue = [];
    window.snaptr = snaptr;
    loadScript('https://sc-static.net/scevent.min.js');
    snaptr('init', pixelId);
  }

  function initializeGoogle(tagId) {
    window.dataLayer = window.dataLayer || [];
    window.gtag = function () { window.dataLayer.push(arguments); };
    window.gtag('js', new Date());
    window.gtag('config', tagId, {
      allow_ad_personalization_signals: false,
    });
    loadScript('https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(tagId));
  }

  function initializeTikTok(pixelId) {
    const endpoint = 'https://analytics.tiktok.com/i18n/pixel/events.js';
    window.TiktokAnalyticsObject = 'ttq';
    const queue = window.ttq = window.ttq || [];
    queue.methods = [
      'page', 'track', 'identify', 'instances', 'debug', 'on', 'off',
      'once', 'ready', 'alias', 'group', 'enableCookie', 'disableCookie',
    ];
    queue.setAndDefer = (target, method) => {
      target[method] = (...args) => target.push([method, ...args]);
    };
    for (const method of queue.methods) queue.setAndDefer(queue, method);
    queue.instance = (id) => {
      const instance = queue._i[id] || [];
      for (const method of queue.methods) queue.setAndDefer(instance, method);
      return instance;
    };
    queue._i = { [pixelId]: Object.assign([], { _u: endpoint }) };
    queue._t = { [pixelId]: Date.now() };
    queue._o = { [pixelId]: {} };
    loadScript(endpoint + '?sdkid=' + encodeURIComponent(pixelId) + '&lib=ttq');
    queue.page();
  }

  function initialize() {
    if (initialized) return;
    initialized = true;
    if (config.snapPixelId) initializeSnap(config.snapPixelId);
    if (config.googleAdsTagId) initializeGoogle(config.googleAdsTagId);
    if (config.tiktokPixelId) initializeTikTok(config.tiktokPixelId);
  }

  function sendPage() {
    if (!allowed || !currentPage || lastSentPage === currentPage) return;
    initialize();
    if (config.snapPixelId) window.snaptr('track', 'PAGE_VIEW');
    lastSentPage = currentPage;
  }

  window.safwatMarketing = {
    allowed: () => allowed,
    setAllowed(value) {
      allowed = value;
      let saved = false;
      try {
        localStorage.setItem(preferenceKey, value ? 'allow' : 'deny');
        saved = true;
      } catch {
        // The choice still applies to events in this document.
      }
      if (value) sendPage();
      else if (initialized && saved) location.reload();
    },
    page(path) {
      currentPage = path;
      sendPage();
    },
    contact(channel) {
      if (!allowed) return;
      if (channel !== 'phone' && channel !== 'whatsapp') return;
      initialize();
      if (config.snapPixelId) {
        window.snaptr('track', channel === 'phone' ? 'CUSTOM_EVENT_1' : 'CUSTOM_EVENT_2');
      }
      if (config.tiktokPixelId) window.ttq.track('Contact');
      const label = channel === 'phone' ? config.googleAdsPhoneLabel : config.googleAdsWhatsAppLabel;
      if (config.googleAdsTagId && label) {
        window.gtag('event', 'conversion', { send_to: config.googleAdsTagId + '/' + label });
      }
    },
  };
})();
