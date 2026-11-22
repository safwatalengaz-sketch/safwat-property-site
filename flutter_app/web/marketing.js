(() => {
  'use strict';

  const config = window.safwatMarketingConfig || {};
  const preferenceKey = 'safwat-snap-marketing-v1';
  const landingUrl = location.href;
  let preference;
  let currentPage;
  let lastSentPage;
  let initialized = false;

  try {
    preference = localStorage.getItem(preferenceKey);
  } catch {
    // Tracking stays off when the preference is unavailable.
  }

  const allowed = () => preference === 'allow';

  function loadScript(src) {
    const script = document.createElement('script');
    script.async = true;
    script.src = src;
    document.head.append(script);
  }

  function dispatch(platform, send) {
    try {
      send();
    } catch (error) {
      console.warn('Safwat measurement failed for ' + platform, error);
    }
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
    window.gtag('consent', 'default', {
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      analytics_storage: 'denied',
    });
    window.gtag('consent', 'update', {
      ad_storage: 'granted',
      ad_user_data: 'granted',
    });
    window.gtag('js', new Date());
    window.gtag('config', tagId, {
      allow_ad_personalization_signals: false,
      page_location: landingUrl,
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
    if (config.snapPixelId) dispatch('Snapchat', () => initializeSnap(config.snapPixelId));
    if (config.googleAdsTagId) dispatch('Google Ads', () => initializeGoogle(config.googleAdsTagId));
    if (config.tiktokPixelId) dispatch('TikTok', () => initializeTikTok(config.tiktokPixelId));
  }

  function sendPage() {
    if (!allowed() || !currentPage || lastSentPage === currentPage) return;
    initialize();
    if (config.snapPixelId) dispatch('Snapchat', () => window.snaptr('track', 'PAGE_VIEW'));
    lastSentPage = currentPage;
  }

  window.safwatMarketing = {
    allowed,
    hasPreference: () => preference === 'allow' || preference === 'deny',
    setAllowed(value) {
      preference = value ? 'allow' : 'deny';
      let saved = false;
      try {
        localStorage.setItem(preferenceKey, preference);
        saved = true;
      } catch {
        // The choice still applies to events in this document.
      }
      if (value) sendPage();
      else if (initialized) {
        window.gtag?.('consent', 'update', {
          ad_storage: 'denied',
          ad_user_data: 'denied',
        });
        if (saved) location.reload();
      }
    },
    page(path) {
      currentPage = path;
      sendPage();
    },
    contact(channel) {
      if (!allowed()) return;
      if (channel !== 'phone' && channel !== 'whatsapp') return;
      initialize();
      if (config.snapPixelId) {
        dispatch('Snapchat', () => {
          window.snaptr('track', channel === 'phone' ? 'CUSTOM_EVENT_1' : 'CUSTOM_EVENT_2');
        });
      }
      if (config.tiktokPixelId) dispatch('TikTok', () => window.ttq.track('Contact'));
      const label = channel === 'phone' ? config.googleAdsPhoneLabel : config.googleAdsWhatsAppLabel;
      if (config.googleAdsTagId && label) {
        dispatch('Google Ads', () => {
          window.gtag('event', 'conversion', { send_to: config.googleAdsTagId + '/' + label });
        });
      }
    },
  };
})();
