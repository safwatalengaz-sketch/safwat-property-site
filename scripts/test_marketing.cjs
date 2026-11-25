const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { test } = require('node:test');
const vm = require('node:vm');

function site(preference, privacySignals = {}, query = '?gclid=example', referrer = '') {
  const scripts = [];
  const browser = {
    URL,
    console: { warn() {} },
    document: {
      referrer,
      createElement: () => ({}),
      head: { append: (script) => scripts.push(script.src) },
    },
    localStorage: {
      getItem: () => preference,
      setItem: (_, value) => { preference = value; },
    },
    navigator: privacySignals,
    location: { href: 'https://example.test/properties/mb-246/' + query, reload() {} },
  };
  browser.window = browser;
  const context = vm.createContext(browser);
  for (const file of ['marketing-config.js', 'marketing.js']) {
    vm.runInContext(readFileSync(join(__dirname, '..', 'flutter_app', 'web', file), 'utf8'), context);
  }
  return { browser, scripts, marketing: browser.safwatMarketing };
}

test('consented calls and WhatsApp clicks reach all three configured destinations', () => {
  const { browser, scripts, marketing } = site();
  const config = browser.safwatMarketingConfig;
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

test('both first-click labels are queued with storage denied and one Google tag', () => {
  const { browser, scripts, marketing } = site(null, {}, '?utm_source=google&utm_medium=cpc&gad_source=1&gad_campaignid=123&gclid=example');
  marketing.page('/properties');
  assert.equal(scripts.length, 0);
  marketing.contact('whatsapp');
  marketing.contact('phone');
  assert.equal(scripts.length, 1);
  assert.equal(browser.snaptr, undefined);
  assert.equal(browser.ttq, undefined);
  const commands = Array.from(browser.dataLayer);
  assert.deepEqual(Object.values(commands[0][2]), Array(4).fill('denied'));
  assert.equal(commands.some(e => e[0] === 'consent' && e[1] === 'update'), false);
  assert.equal(commands.find(e => e[0] === 'config')[2].page_location, 'https://example.test/properties/mb-246/');
  assert.equal(commands.find(e => e[0] === 'set' && e[1] === 'ads_data_redaction')[2], true);
  const config = browser.safwatMarketingConfig;
  assert.deepEqual(commands.filter(e => e[1] === 'conversion').map(e => e[2].send_to), [
    config.googleAdsTagId + '/' + config.googleAdsWhatsAppLabel,
    config.googleAdsTagId + '/' + config.googleAdsPhoneLabel,
  ]);
  marketing.setAllowed(false);
  const prior = browser.dataLayer.length;
  marketing.contact('phone');
  assert.equal(browser.dataLayer.length, prior);
});

test('a foreign identifier, unknown query or tagged referrer suppresses limited tracking', () => {
  for (const [query, referrer] of [
    ['?gclid=example&ScCid=private', ''], ['?ttclid=private', ''], ['?utm_source=private', ''],
    ['', 'https://example.test/?ttclid=private'], ['#private', ''],
  ]) {
    const { marketing, scripts } = site(null, {}, query, referrer);
    marketing.contact('phone');
    assert.equal(scripts.length, 0);
  }
});

test('stored refusal and browser privacy signals suppress automatic pings', () => {
  for (const [pref, signals] of [['deny', {}], [null, { globalPrivacyControl: true }], [null, { doNotTrack: '1' }]]) {
    const { browser, scripts, marketing } = site(pref, signals);
    marketing.contact('whatsapp');
    assert.equal(scripts.length, 0);
    assert.equal(browser.dataLayer, undefined);
  }
});

test('granting after a limited click starts the other pixels without replaying the click', () => {
  const { browser, scripts, marketing } = site();
  marketing.page('/properties');
  marketing.contact('whatsapp');
  marketing.setAllowed(true);
  marketing.contact('phone');
  assert.equal(scripts.length, 3);
  assert.equal(browser.dataLayer.filter(e => e[1] === 'conversion').length, 2);
  assert.deepEqual(Array.from(browser.ttq).filter(e => e[0] === 'track').map(e => e[1]), ['Contact','PhoneClick']);
});

test('one pixel failure does not block the other two destinations', () => {
  const { browser, marketing } = site();
  marketing.page('/contact');
  marketing.setAllowed(true);
  browser.snaptr = () => { throw new Error('Simulated pixel failure'); };
  assert.doesNotThrow(() => marketing.contact('phone'));
  assert.equal(browser.ttq.at(-1)[1], 'PhoneClick');
  assert.equal(browser.dataLayer.at(-1)[1], 'conversion');
});
