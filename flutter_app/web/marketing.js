(() => {
  'use strict';

  const config = window.safwatMarketingConfig || {};
  const preferenceKey = 'safwat-snap-marketing-v1';
  const denialKey = preferenceKey + '-session-denial';
  const landingUrl = location.href;
  const snapScript = 'https://sc-static.net/scevent.min.js';
  const tiktokEndpoint = 'https://analytics.tiktok.com/i18n/pixel/events.js';
  const tiktokScript = tiktokEndpoint + '?sdkid=' + encodeURIComponent(config.tiktokPixelId) + '&lib=ttq';
  let preference;
  let currentPage;
  let lastSentPage;
  let initialized = false;
  let googleInitialized = false;

  try {
    preference = localStorage.getItem(preferenceKey);
  } catch {
    preference = 'deny';
  }
  try {
    if (sessionStorage.getItem(denialKey) === 'deny') preference = 'deny';
  } catch {}

  const allowed = () => preference === 'allow' && !window.navigator?.globalPrivacyControl;
  function loadScript(src, retry = true) {
    const script = document.createElement('script');
    script.async = true;
    script.src = src;
    if (retry) script.onerror = () => {
      script.remove();
      // Keep SDK commands already queued. Retry the script, never the events.
      window.setTimeout(() => {
        if (allowed()) loadScript(src, false);
      }, 1000);
    };
    document.head.append(script);
  }

  function preloadScript(src) {
    const link = document.createElement('link');
    link.rel = 'preload';
    link.as = 'script';
    link.href = src;
    document.head.append(link);
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
    loadScript(snapScript);
    snaptr('init', pixelId);
  }

  function initializeGoogle(tagId) {
    if (googleInitialized) return;
    googleInitialized = true;
    window.dataLayer = window.dataLayer || [];
    window.gtag = function () { window.dataLayer.push(arguments); };
    window.gtag('consent', 'default', {
      ad_storage: 'denied', ad_user_data: 'denied',
      ad_personalization: 'denied', analytics_storage: 'denied',
    });
    window.gtag('consent', 'update', { ad_storage: 'granted', ad_user_data: 'granted' });
    window.gtag('js', new Date());
    window.gtag('config', tagId, {
      allow_ad_personalization_signals: false,
      page_location: landingUrl,
    });
    loadScript('https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(tagId));
  }

  function initializeTikTok(pixelId) {
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
    queue._i = { [pixelId]: Object.assign([], { _u: tiktokEndpoint }) };
    queue._t = { [pixelId]: Date.now() };
    queue._o = { [pixelId]: {} };
    loadScript(tiktokScript);
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
    setAllowed(value) {
      preference = value ? 'allow' : 'deny';
      let saved = false;
      try {
        localStorage.setItem(preferenceKey, preference);
        saved = true;
      } catch {
        if (!value) {
          try {
            localStorage.removeItem(preferenceKey);
            saved = true;
          } catch {}
        }
      }
      try {
        if (value) sessionStorage.removeItem(denialKey);
        else if (!saved) {
          sessionStorage.setItem(denialKey, 'deny');
          saved = true;
        }
      } catch {}
      if (value) sendPage();
      else if ((initialized || googleInitialized) && saved) {
        // Reload to unload the already-running SDKs and their automatic listeners.
        location.reload();
      }
    },
    page(path) {
      currentPage = path;
      sendPage();
    },
    contact(channel) {
      if (!allowed() || (channel !== 'phone' && channel !== 'whatsapp')) return;
      initialize();
      if (config.snapPixelId) dispatch('Snapchat', () => {
        window.snaptr('track', channel === 'phone' ? 'CUSTOM_EVENT_1' : 'CUSTOM_EVENT_2');
      });
      if (config.tiktokPixelId) {
        dispatch('TikTok', () => window.ttq.track('Contact'));
        dispatch('TikTok', () => window.ttq.track(channel === 'phone' ? 'PhoneClick' : 'WhatsAppClick'));
      }
      const label = channel === 'phone' ? config.googleAdsPhoneLabel : config.googleAdsWhatsAppLabel;
      if (config.googleAdsTagId && label) {
        dispatch('Google Ads', () => {
          window.gtag('event', 'conversion', { send_to: config.googleAdsTagId + '/' + label });
        });
      }
    },
  };

  window.addEventListener('storage', (event) => {
    if (event.storageArea !== localStorage ||
        (event.key !== preferenceKey && event.key !== null)) return;
    preference = event.newValue;
    if (allowed()) {
      initialize();
      sendPage();
    } else if (initialized || googleInitialized) {
      location.reload();
    }
  });
  if (allowed()) {
    // Flutter normalizes deep-link URLs. Fetch the SDKs early but defer their
    // automatic history listeners until the first measured Flutter route.
    if (config.snapPixelId) preloadScript(snapScript);
    if (config.tiktokPixelId) preloadScript(tiktokScript);
    if (config.googleAdsTagId) dispatch('Google Ads', () => initializeGoogle(config.googleAdsTagId));
  }
})();
