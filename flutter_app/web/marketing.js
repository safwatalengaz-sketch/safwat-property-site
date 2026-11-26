(() => {
  'use strict';

  const config = window.safwatMarketingConfig || {};
  const preferenceKey = 'safwat-snap-marketing-v1';
  const entranceKey = 'safwat-entrance-dismissed-v1';
  const denialKey = preferenceKey + '-session-denial';
  const analyticsGrant = 'allow-analytics-v1';
  const landingUrl = location.href;
  const snapScript = 'https://sc-static.net/scevent.min.js';
  const tiktokEndpoint = 'https://analytics.tiktok.com/i18n/pixel/events.js';
  const tiktokScript = tiktokEndpoint + '?sdkid=' + encodeURIComponent(config.tiktokPixelId) + '&lib=ttq';
  let preference;
  let entranceOpened = false;
  let currentPage;
  let lastSentPage;
  let lastLimitedPage;
  let initialized = false;
  let googleInitialized = false;
  let analyticsInitialized = false;
  let lastAnalyticsPage;

  const hasGrant = () => preference === 'allow' || preference === analyticsGrant;
  try {
    preference = localStorage.getItem(preferenceKey);
    entranceOpened = localStorage.getItem(entranceKey) === '1' ||
      hasGrant() || preference === 'deny';
  } catch {
    preference = 'deny';
  }
  try {
    if (sessionStorage.getItem(denialKey) === 'deny') preference = 'deny';
  } catch {}

  const allowed = () => hasGrant() && !window.navigator?.globalPrivacyControl;
  const analyticsAllowed = () => !!config.googleAnalyticsId &&
    preference === analyticsGrant && allowed() && navigator.doNotTrack !== '1';
  function googleLimited() {
    if (preference !== null || navigator.globalPrivacyControl || navigator.doNotTrack === '1') return false;
    // Redaction covers Google's click ID. Keep other identifiers and arbitrary
    // visitor-supplied URL values out of the SDK's automatic collection.
    return [landingUrl, location.href, document.referrer].every((address) => {
      if (!address) return true;
      const url = new URL(address);
      if (url.hash) return false;
      return Array.from(url.searchParams).every(([key, value]) =>
        key === 'gclid' || (key === 'gad_source' && /^\d{1,2}$/.test(value)) ||
        (key === 'gad_campaignid' && /^\d{1,20}$/.test(value)) ||
        (key === 'utm_source' && value === 'google') ||
        (key === 'utm_medium' && ['cpc', 'ppc', 'paid_search'].includes(value)));
    });
  }

  function loadScript(src, mayLoad = allowed, retry = true) {
    const script = document.createElement('script');
    script.async = true;
    script.src = src;
    if (retry) script.onerror = () => {
      script.remove();
      // Keep SDK commands already queued. Retry the script, never the events.
      window.setTimeout(() => {
        if (mayLoad()) loadScript(src, mayLoad, false);
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

  function googlePageContext() {
    const url = currentPage ? new URL(currentPage.replace(/^\//, ''), document.baseURI) : new URL(location.href);
    return { page_location: url.origin + url.pathname, page_referrer: '' };
  }

  function whenRouteMatches(path, canSend, send, retries = 8) {
    if (path !== currentPage || !canSend()) return;
    // Flutter can report the new route before updating browser history.
    // Pixel SDKs read the real URL when building the event.
    const normalize = (pathname) => pathname.replace(/\/$/, '');
    if (normalize(new URL(googlePageContext().page_location).pathname) !== normalize(new URL(location.href).pathname)) {
      if (retries) window.setTimeout(() => whenRouteMatches(path, canSend, send, retries - 1), 25);
      return;
    }
    send();
  }

  function initializeGoogle(tagId, fullMeasurement = true) {
    if (googleInitialized) {
      if (fullMeasurement && googleInitialized === 'limited') {
        googleInitialized = 'full';
        window.gtag('consent', 'update', { ad_storage: 'granted', ad_user_data: 'granted' });
        window.gtag('set', { page_location: landingUrl });
      }
      return;
    }
    googleInitialized = fullMeasurement ? 'full' : 'limited';
    window.dataLayer = window.dataLayer || [];
    window.gtag = function () { window.dataLayer.push(arguments); };
    window.gtag('consent', 'default', {
      ad_storage: 'denied', ad_user_data: 'denied',
      ad_personalization: 'denied', analytics_storage: 'denied',
    });
    window.gtag('set', 'ads_data_redaction', true);
    if (fullMeasurement) window.gtag('consent', 'update', { ad_storage: 'granted', ad_user_data: 'granted' });
    window.gtag('js', new Date());
    window.gtag('config', tagId, {
      allow_ad_personalization_signals: false,
      ...(fullMeasurement ? { page_location: landingUrl } : { ...googlePageContext(), send_page_view: false }),
    });
    loadScript('https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(tagId), () => allowed() || googleLimited());
  }

  function sendAnalytics(event) {
    if (!analyticsAllowed()) return;
    dispatch('Google Analytics', () => {
      initializeGoogle(config.googleAdsTagId || config.googleAnalyticsId);
      if (!analyticsInitialized) {
        window.gtag('consent', 'update', { analytics_storage: 'granted' });
        window.gtag('config', config.googleAnalyticsId, {
          ...googlePageContext(),
          groups: 'safwat_analytics',
          send_page_view: event === 'page_view',
          allow_google_signals: false,
          allow_ad_personalization_signals: false,
        });
        analyticsInitialized = true;
        // The GA4 config sends the first view. Only later routes need a manual event.
        if (event === 'page_view') return;
      }
      window.gtag('event', event, { ...googlePageContext(), send_to: config.googleAnalyticsId });
    });
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
    queue.page();
    // Keep the command queue available immediately while Flutter settles the
    // initial browser URL, before the TikTok SDK attaches its history listener.
    window.setTimeout(() => {
      if (allowed()) loadScript(tiktokScript);
    }, 150);
  }

  function initialize() {
    if (initialized) return;
    initialized = true;
    if (config.snapPixelId) dispatch('Snapchat', () => initializeSnap(config.snapPixelId));
    if (config.googleAdsTagId) dispatch('Google Ads', () => initializeGoogle(config.googleAdsTagId));
    if (config.tiktokPixelId) dispatch('TikTok', () => initializeTikTok(config.tiktokPixelId));
  }

  function sendPage() {
    if (!entranceOpened || !currentPage) return;
    if (analyticsAllowed() && lastAnalyticsPage !== currentPage) {
      lastAnalyticsPage = currentPage;
      sendAnalytics('page_view');
    }
    if (lastSentPage === currentPage) return;
    if (allowed()) {
      initialize();
      if (config.snapPixelId) whenRouteMatches(currentPage, allowed, () => {
        dispatch('Snapchat', () => window.snaptr('track', 'PAGE_VIEW'));
      });
    } else if (config.googleAdsTagId && lastLimitedPage !== currentPage && googleLimited()) {
      dispatch('Google Ads', () => {
        // Ads emits the initial observation on config, even with send_page_view
        // disabled. Only send explicit page views for later Flutter routes.
        if (!googleInitialized) initializeGoogle(config.googleAdsTagId, false);
        else whenRouteMatches(currentPage, googleLimited, () => {
          window.gtag('event', 'page_view', { ...googlePageContext(), send_to: config.googleAdsTagId });
        });
      });
      lastLimitedPage = currentPage;
      return;
    } else return;
    lastSentPage = currentPage;
  }

  window.safwatMarketing = {
    allowed,
    showWelcome: () => !entranceOpened,
    dismissWelcome() {
      if (entranceOpened) return;
      entranceOpened = true;
      try { localStorage.setItem(entranceKey, '1'); } catch {}
      sendPage();
    },
    privacyState: () => {
      if (navigator.globalPrivacyControl) return 'blocked';
      if (preference === analyticsGrant) return 'allow';
      if (preference === 'allow' && config.googleAnalyticsId) return 'allow-ads';
      return preference || 'unset';
    },
    setAllowed(value) {
      if (value && navigator.globalPrivacyControl) return;
      preference = value ? (config.googleAnalyticsId ? analyticsGrant : 'allow') : 'deny';
      let saved = false;
      try {
        localStorage.setItem(preferenceKey, preference);
        saved = true;
      } catch {
        if (!value) {
          try { localStorage.removeItem(preferenceKey); } catch {}
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
      if (!entranceOpened || (channel !== 'phone' && channel !== 'whatsapp')) return;
      const fullMeasurement = allowed();
      if (!fullMeasurement && !googleLimited()) return;
      if (fullMeasurement) initialize();
      if (fullMeasurement && config.snapPixelId) dispatch('Snapchat', () => {
        window.snaptr('track', channel === 'phone' ? 'CUSTOM_EVENT_1' : 'CUSTOM_EVENT_2');
      });
      if (fullMeasurement && config.tiktokPixelId) {
        dispatch('TikTok', () => window.ttq.track('Contact'));
        dispatch('TikTok', () => window.ttq.track(channel === 'phone' ? 'PhoneClick' : 'WhatsAppClick'));
      }
      const label = channel === 'phone' ? config.googleAdsPhoneLabel : config.googleAdsWhatsAppLabel;
      if (config.googleAdsTagId && label) {
        dispatch('Google Ads', () => {
          initializeGoogle(config.googleAdsTagId, fullMeasurement);
          window.gtag('event', 'conversion', {
            ...(fullMeasurement ? {} : googlePageContext()),
            send_to: config.googleAdsTagId + '/' + label,
          });
        });
      }
      sendAnalytics(channel === 'phone' ? 'phone_click' : 'whatsapp_click');
    },
  };

  window.addEventListener('storage', (event) => {
    if (event.storageArea !== localStorage ||
        (event.key !== preferenceKey && event.key !== null)) return;
    preference = event.newValue;
    if (analyticsInitialized && !analyticsAllowed()) {
      location.reload();
    } else if (allowed() && entranceOpened) {
      initialize();
      sendPage();
    } else if (initialized || googleInitialized) {
      location.reload();
    }
  });
  if (entranceOpened && allowed()) {
    // Flutter normalizes deep-link URLs. Fetch the SDKs early but defer their
    // automatic history listeners until the first measured Flutter route.
    if (config.snapPixelId) preloadScript(snapScript);
    if (config.tiktokPixelId) preloadScript(tiktokScript);
    if (config.googleAdsTagId) dispatch('Google Ads', () => initializeGoogle(config.googleAdsTagId));
  }
})();
