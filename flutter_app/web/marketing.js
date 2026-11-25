(() => {
  'use strict';

  const config = window.safwatMarketingConfig || {};
  const preferenceKey = 'safwat-snap-marketing-v1';
  const landingUrl = location.href;
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

  const allowed = () => preference === 'allow';
  function canSendLimitedClick() {
    if (preference != null || navigator.globalPrivacyControl || navigator.doNotTrack === '1') return false;
    // Google's redaction covers its own click ID. Other identifiers in a URL
    // can still be sent by the tag even if page_location is set explicitly.
    for (const address of [landingUrl, location.href, document.referrer]) {
      if (!address) continue;
      const url = new URL(address);
      for (const [key, value] of url.searchParams) {
        if (key === 'gclid') continue;
        if (key === 'gad_source' && /^\d{1,2}$/.test(value)) continue;
        if (key === 'gad_campaignid' && /^\d{1,20}$/.test(value)) continue;
        if (key === 'utm_source' && value === 'google') continue;
        if (key === 'utm_medium' && ['cpc', 'ppc', 'paid_search'].includes(value)) continue;
        return false;
      }
      if (url.hash) return false;
    }
    return true;
  }

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

  function initializeGoogle(tagId, fullMeasurement) {
    if (!googleInitialized) {
      window.dataLayer = window.dataLayer || [];
      window.gtag = function () { window.dataLayer.push(arguments); };
      window.gtag('consent', 'default', {
        ad_storage: 'denied', ad_user_data: 'denied',
        ad_personalization: 'denied', analytics_storage: 'denied',
      });
      window.gtag('set', 'ads_data_redaction', true);
    }
    if (fullMeasurement) {
      window.gtag('consent', 'update', { ad_storage: 'granted', ad_user_data: 'granted' });
    }
    if (!googleInitialized) window.gtag('js', new Date());
    window.gtag('config', tagId, fullMeasurement ? {
      allow_ad_personalization_signals: false,
      page_location: landingUrl,
    } : {
      send_page_view: false, allow_ad_personalization_signals: false,
      page_location: location.href.split(/[?#]/)[0], page_referrer: '',
    });
    if (!googleInitialized) {
      loadScript('https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(tagId));
      googleInitialized = true;
    }
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
    if (config.googleAdsTagId) dispatch('Google Ads', () => initializeGoogle(config.googleAdsTagId, true));
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
      else if (initialized || googleInitialized) {
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
      if (channel !== 'phone' && channel !== 'whatsapp') return;
      if (allowed()) {
        initialize();
        if (config.snapPixelId) dispatch('Snapchat', () => {
          window.snaptr('track', channel === 'phone' ? 'CUSTOM_EVENT_1' : 'CUSTOM_EVENT_2');
        });
        if (config.tiktokPixelId) dispatch('TikTok', () => {
          window.ttq.track('Contact');
          window.ttq.track(channel === 'phone' ? 'PhoneClick' : 'WhatsAppClick');
        });
      } else if (!canSendLimitedClick()) return;
      const label = channel === 'phone' ? config.googleAdsPhoneLabel : config.googleAdsWhatsAppLabel;
      if (config.googleAdsTagId && label) {
        dispatch('Google Ads', () => {
          if (!googleInitialized) initializeGoogle(config.googleAdsTagId, false);
          window.gtag('event', 'conversion', { send_to: config.googleAdsTagId + '/' + label });
        });
      }
    },
  };
})();
