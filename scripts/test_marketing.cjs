const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { test } = require('node:test');
const vm = require('node:vm');

function site() {
  const scripts = [];
  let preference;
  const browser = {
    console: { warn() {} },
    document: {
      createElement: () => ({}),
      head: { append: (script) => scripts.push(script.src) },
    },
    localStorage: {
      getItem: () => preference,
      setItem: (_, value) => { preference = value; },
    },
    location: { href: 'https://example.test/properties/mb-246/' },
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
    'Contact', 'Contact',
  ]);
  assert.deepEqual(Array.from(browser.dataLayer).filter((event) => event[1] === 'conversion').map((event) => event[2].send_to), [
    `${config.googleAdsTagId}/${config.googleAdsPhoneLabel}`,
    `${config.googleAdsTagId}/${config.googleAdsWhatsAppLabel}`,
  ]);
});

test('the site keeps measurement off before consent and after refusal', () => {
  const { browser, scripts, marketing } = site();
  marketing.page('/contact');
  marketing.contact('phone');
  marketing.setAllowed(false);
  marketing.contact('whatsapp');
  assert.equal(scripts.length, 0);
  assert.equal(browser.dataLayer, undefined);
});

test('one pixel failure does not block the other two destinations', () => {
  const { browser, marketing } = site();
  marketing.page('/contact');
  marketing.setAllowed(true);
  browser.snaptr = () => { throw new Error('Simulated pixel failure'); };
  assert.doesNotThrow(() => marketing.contact('phone'));
  assert.equal(browser.ttq.at(-1)[1], 'Contact');
  assert.equal(browser.dataLayer.at(-1)[1], 'conversion');
});
