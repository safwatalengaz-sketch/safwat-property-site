const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { test } = require('node:test');
const vm = require('node:vm');

function site(preference, privacySignals = {}, query = '?gclid=example', referrer = '') {
  const values = new Map([['safwat-snap-marketing-v1', preference ?? null]]);
  const scripts = [];
  const scriptElements = [];
  const preloads = [];
  const listeners = {};
  const browser = {
    URL,
    console: { warn() {} },
    document: {
      referrer,
      baseURI: 'https://example.test/',
      createElement: () => ({ remove() {} }),
      head: { append: (element) => {
        if (element.rel === 'preload') preloads.push(element.href);
        else {
          scripts.push(element.src);
          scriptElements.push(element);
        }
      } },
    },
    localStorage: {
      getItem: (key) => values.get(key) ?? null,
      setItem: (key, value) => { values.set(key, value); },
    },
    navigator: privacySignals,
    addEventListener: (name, callback) => { listeners[name] = callback; },
    setTimeout: (callback) => callback(),
    location: { href: 'https://example.test/properties/mb-246/' + query, reload() {} },
  };
  browser.window = browser;
  const context = vm.createContext(browser);
  for (const file of ['marketing-config.js', 'marketing.js']) {
    vm.runInContext(readFileSync(join(__dirname, '..', 'flutter_app', 'web', file), 'utf8'), context);
  }
  return { browser, scripts, scriptElements, preloads, listeners, marketing: browser.safwatMarketing };
}

test('consented calls and WhatsApp clicks reach all three configured destinations', () => {
  const { browser, scripts, marketing } = site();
  const config = browser.safwatMarketingConfig;
  marketing.dismissWelcome();
  marketing.page('/properties/mb-246');
  marketing.setAllowed(true);
  marketing.contact('phone');
  marketing.contact('whatsapp');
  marketing.contact('unsupported');

  assert.equal(scripts.length, 3);
  assert.deepEqual(Array.from(browser.snaptr.queue).filter((event) => event[1].startsWith('CUSTOM_EVENT')).map((event) => event[1]), [
    'CUSTOM_EVENT_1', 'CUSTOM_EVENT_2',
  ]);
  assert.deepEqual(Array.from(browser.ttq).filter((event) => event[0] === 'track').map((event) => event[1]), [
    'Contact', 'PhoneClick', 'Contact', 'WhatsAppClick',
  ]);
  assert.deepEqual(Array.from(browser.dataLayer).filter((event) => event[1] === 'conversion').map((event) => event[2].send_to), [
    `${config.googleAdsTagId}/${config.googleAdsPhoneLabel}`,
    `${config.googleAdsTagId}/${config.googleAdsWhatsAppLabel}`,
  ]);
});

for (const [label, preference, signals, query, referrer] of [
  ['explicit refusal', 'deny'],
  ['privacy control', null, { globalPrivacyControl: true }],
  ['Do Not Track', null, { doNotTrack: '1' }],
  ['Snap click ID', null, {}, '?ScCid=example'],
  ['TikTok click ID', null, {}, '?ttclid=example'],
  ['arbitrary query', null, {}, '?name=example'],
  ['arbitrary referrer query', null, {}, '', 'https://example.org/?email=example'],
  ['fragment', null, {}, '#example'],
]) {
  test(`no advertising requests for ${label}`, () => {
    const { browser, scripts, marketing } = site(preference, signals, query, referrer);
    marketing.dismissWelcome();
    marketing.page('/properties');
    marketing.contact('phone');
    marketing.contact('whatsapp');
    assert.equal(scripts.length, 0);
    assert.equal(browser.snaptr, undefined);
    assert.equal(browser.ttq, undefined);
    assert.equal(browser.dataLayer, undefined);
  });
}

test('a new visitor queues one limited Google view per route and one conversion per click', () => {
  const { browser, marketing, scripts } = site(null);
  marketing.page('/properties/mb-246');
  assert.equal(marketing.showWelcome(), true);
  assert.equal(scripts.length, 0);
  marketing.dismissWelcome();
  marketing.dismissWelcome();
  assert.equal(marketing.showWelcome(), false);
  assert.equal(browser.localStorage.getItem('safwat-entrance-dismissed-v1'), '1');
  assert.equal(browser.localStorage.getItem('safwat-snap-marketing-v1'), null);
  marketing.page('/properties/mb-246');
  browser.location.href = 'https://example.test/works';
  marketing.page('/works');
  marketing.page('/works');
  marketing.contact('whatsapp');
  marketing.contact('phone');
  assert.equal(marketing.allowed(), false);
  assert.equal(scripts.length, 1);
  assert.match(scripts[0], /googletagmanager\.com/);
  assert.equal(browser.snaptr, undefined);
  assert.equal(browser.ttq, undefined);
  const commands = browser.dataLayer;
  assert.equal(commands.filter(e => e[0] === 'consent').length, 1);
  assert.equal(commands[0][2].ad_storage, 'denied');
  assert.equal(commands[0][2].ad_user_data, 'denied');
  assert.equal(commands.find(e => e[1] === 'ads_data_redaction')[2], true);
  const events = commands.filter(e => e[0] === 'event');
  assert.deepEqual(Array.from(events, e => e[1]), ['page_view', 'conversion', 'conversion']);
  assert.equal(events[0][2].page_location, 'https://example.test/works');
  assert.ok(events.every(e => !e[2].page_location.includes('?') && !e[2].page_referrer));
});

test('granting loads the three tags without replaying earlier clicks', () => {
  const { browser, scripts, marketing } = site(null, {}, '?ScCid=example');
  marketing.dismissWelcome();
  marketing.page('/properties');
  marketing.contact('whatsapp');
  marketing.setAllowed(true);
  marketing.contact('phone');
  marketing.contact('phone');
  assert.equal(scripts.length, 3);
  assert.equal(browser.dataLayer.filter(e => e[1] === 'conversion').length, 2);
  assert.deepEqual(Array.from(browser.ttq).filter(e => e[0] === 'track').map(e => e[1]),
    ['Contact', 'PhoneClick', 'Contact', 'PhoneClick']);
  assert.equal(browser.snaptr.queue.filter(e => e[1] === 'PAGE_VIEW').length, 1);
});

test('stored approval preloads SDKs and repeated route callbacks do not add views', () => {
  const { browser, scripts, preloads, marketing } = site('allow');
  assert.equal(scripts.length, 1);
  assert.equal(preloads.length, 2);
  marketing.page('/properties');
  marketing.page('/properties');
  marketing.contact('whatsapp');
  marketing.contact('whatsapp');
  assert.equal(browser.snaptr.queue.filter(e => e[1] === 'PAGE_VIEW').length, 1);
  assert.equal(browser.ttq.filter(e => e[0] === 'page').length, 1);
  assert.equal(browser.ttq.filter(e => e[1] === 'WhatsAppClick').length, 2);
  assert.equal(scripts.length, 3);
});

test('a stored grant cannot override a browser privacy signal', () => {
  const { marketing, scripts } = site('allow', { globalPrivacyControl: true });
  marketing.page('/properties');
  marketing.contact('phone');
  assert.equal(scripts.length, 0);
});

test('revoking in another tab blocks the next contact and unloads active SDKs', () => {
  const { browser, listeners, marketing } = site('allow');
  let reloads = 0;
  browser.location.reload = () => { reloads += 1; };
  listeners.storage({ storageArea: browser.localStorage, key: 'safwat-snap-marketing-v1', newValue: 'deny' });
  marketing.contact('whatsapp');
  assert.equal(reloads, 1);
  assert.equal(marketing.allowed(), false);
  assert.equal(browser.ttq, undefined);
});

test('revoking reloads to unload the SDKs and blocks further contact events', () => {
  const { browser, marketing } = site('allow');
  let reloaded = false;
  browser.location.reload = () => { reloaded = true; };
  marketing.page('/properties');
  marketing.setAllowed(false);
  marketing.contact('whatsapp');
  assert.equal(reloaded, true);
  assert.equal(marketing.allowed(), false);
  assert.equal(browser.dataLayer.filter(e => e[1] === 'conversion').length, 0);
  assert.equal(browser.ttq.filter(e => e[0] === 'track').length, 0);
});

test('one pixel failure does not block the other two destinations', () => {
  const { browser, marketing } = site();
  marketing.dismissWelcome();
  marketing.page('/contact');
  marketing.setAllowed(true);
  browser.snaptr = () => { throw new Error('Simulated pixel failure'); };
  assert.doesNotThrow(() => marketing.contact('phone'));
  assert.equal(browser.ttq.at(-1)[1], 'PhoneClick');
  assert.equal(browser.dataLayer.at(-1)[1], 'conversion');
});

test('a script load failure retries once without adding another conversion', () => {
  const { browser, scriptElements, marketing } = site('allow');
  marketing.page('/properties');
  marketing.contact('whatsapp');
  const snap = scriptElements.find(element => element.src.includes('sc-static.net'));
  snap.onerror();
  const snapLoads = scriptElements.filter(element => element.src === snap.src);
  assert.equal(snapLoads.length, 2);
  assert.equal(snapLoads[1].onerror, undefined);
  assert.equal(browser.snaptr.queue.filter(event => event[1] === 'CUSTOM_EVENT_2').length, 1);
});
