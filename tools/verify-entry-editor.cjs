// Requires Playwright. Set ATLAS_CHROME_PATH for an installed Chrome executable;
// optionally set ATLAS_D3_PATH to a local copy of the page's existing D3 script.
// All writes use isolated browser profiles; no user content or repo files change.
const { chromium } = require('playwright');
const fs = require('node:fs/promises');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const files = new Set(['animal-evolution-tree.html', 'full-animal-tree.html', 'entry-editor.js', 'entry-content.js', 'favicon.svg']);

(async () => {
  const browser = await chromium.launch({ headless: true, ...(process.env.ATLAS_CHROME_PATH ? { executablePath: process.env.ATLAS_CHROME_PATH } : {}) });
  try {
    const serve = async route => {
      const url = new URL(route.request().url());
      if (url.hostname === 'cdn.jsdelivr.net') {
        if (!process.env.ATLAS_D3_PATH) return route.continue();
        return route.fulfill({ body: await fs.readFile(process.env.ATLAS_D3_PATH), contentType: 'application/javascript' });
      }
      const file = url.pathname.slice(1) || 'animal-evolution-tree.html';
      if (!files.has(file)) return route.fulfill({ status: 404, body: '' });
      return route.fulfill({ body: await fs.readFile(path.join(root, file)), contentType: file.endsWith('.js') ? 'application/javascript' : file.endsWith('.svg') ? 'image/svg+xml' : 'text/html' });
    };
    const context = await browser.newContext({ acceptDownloads: true, viewport: { width: 1440, height: 1000 } });
    await context.route('**/*', serve);
    const errors = [];
    context.on('page', page => page.on('pageerror', error => errors.push(error.message)));
    const page = await context.newPage();
    const ready = p => p.waitForFunction(() => document.querySelector('.entry-editor').open && !document.querySelector('#ee-text').disabled);
    const open = async (p, name) => { await p.evaluate(n => window.AnimalAtlasEntries.open(n), name); await ready(p); };
    const save = async p => { await p.locator('.ee-save').click(); await p.waitForFunction(() => document.querySelector('.ee-status').textContent.startsWith('Saved in')); };
    const checkGallery = async p => {
      await p.locator('.ee-images img').first().click();
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '1 / 3');
      assert.equal(await p.locator('.ee-viewer-prev').isVisible(), false);
      assert.equal(await p.locator('.ee-viewer-next').isVisible(), true);
      await p.locator('.ee-viewer-next').click();
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '2 / 3');
      assert.equal(await p.locator('.ee-image-viewer figcaption').innerText(), 'Second image');
      assert.equal(await p.locator('.ee-viewer-prev').isVisible(), true);
      assert.equal(await p.locator('.ee-viewer-next').isVisible(), true);
      await p.locator('.ee-viewer-next').click();
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '3 / 3');
      assert.equal(await p.locator('.ee-viewer-next').isVisible(), false);
      assert.equal(await p.locator('.ee-image-viewer figcaption').innerText(), 'Third image');
      await p.keyboard.press('ArrowRight');
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '3 / 3');
      await p.keyboard.press('ArrowLeft');
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '2 / 3');
      await p.locator('.ee-viewer-prev').click();
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '1 / 3');
      await p.keyboard.press('Escape');
      assert.equal(await p.locator('.entry-editor').isVisible(), true);
      await p.locator('.ee-images img').nth(2).click();
      assert.equal(await p.locator('.ee-viewer-count').innerText(), '3 / 3');
      await p.locator('.ee-viewer-close').click();
    };
    await page.goto('https://atlas.test/animal-evolution-tree.html');
    await page.evaluate(() => {
      const n = D.find(n => n[0] === 'Nigersaurus'); s = ts = 1;
      x = tx = view.clientWidth / 2 - n[3]; y = ty = view.clientHeight / 2 - n[4]; draw();
    });
    await page.locator('.card[data-name="Nigersaurus"]').click();
    assert.equal(await page.locator('.entry-editor').isVisible(), false);
    assert.equal(await page.locator('.card[data-name="Nigersaurus"]').evaluate(e => e.classList.contains('active')), true);
    await page.locator('.card[data-name="Tyrannosaurus"]').dispatchEvent('click');
    await page.locator('.card[data-name="Nigersaurus"]').click();
    assert.equal(await page.locator('.entry-editor').isVisible(), false);
    await page.waitForTimeout(650);
    await page.locator('.card[data-name="Nigersaurus"]').click();
    await ready(page);
    assert.equal(await page.locator('#ee-title').innerText(), 'Nigersaurus');
    const text = 'My information\n<em>Plain text, not HTML</em>';
    await page.locator('#ee-text').fill(text);
    const png = await page.evaluate(() => {
      const c = document.createElement('canvas'); c.width = 30; c.height = 20;
      c.getContext('2d').fillRect(0, 0, 30, 20); return c.toDataURL('image/png').split(',')[1];
    });
    await page.locator('#ee-files').setInputFiles({ name: 'test.png', mimeType: 'image/png', buffer: Buffer.from(png, 'base64') });
    await page.waitForFunction(() => document.querySelectorAll('.ee-images img').length === 1 && !document.querySelector('#ee-text').disabled);
    await page.locator('.ee-caption').fill('My credit');
    const thumbnailWidth = await page.locator('.ee-images img').evaluate(img => img.getBoundingClientRect().width);
    await page.locator('.ee-images img').click();
    assert.equal(await page.locator('.ee-image-viewer').isVisible(), true);
    assert.ok(await page.locator('.ee-image-viewer img').evaluate(img => img.getBoundingClientRect().width) > thumbnailWidth);
    assert.equal(await page.locator('.ee-image-viewer figcaption').innerText(), 'My credit');
    assert.equal(await page.locator('.ee-viewer-prev').isVisible(), false);
    assert.equal(await page.locator('.ee-viewer-next').isVisible(), false);
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('.ee-image-viewer').isVisible(), false);
    assert.equal(await page.locator('.entry-editor').isVisible(), true);
    assert.equal(await page.locator('#ee-text').inputValue(), text);
    assert.equal(await page.locator('.ee-caption').inputValue(), 'My credit');
    await page.locator('#ee-files').setInputFiles([
      { name: 'second.png', mimeType: 'image/png', buffer: Buffer.from(png, 'base64') },
      { name: 'third.png', mimeType: 'image/png', buffer: Buffer.from(png, 'base64') }
    ]);
    await page.waitForFunction(() => document.querySelectorAll('.ee-images img').length === 3 && !document.querySelector('#ee-text').disabled);
    await page.locator('.ee-caption').nth(1).fill('Second image');
    await page.locator('.ee-caption').nth(2).fill('Third image');
    await checkGallery(page);
    assert.equal(await page.locator('#ee-text').inputValue(), text);
    await page.locator('.ee-remove').nth(2).click();
    await page.locator('.ee-remove').nth(1).click();
    await save(page);
    const downloadPromise = page.waitForEvent('download');
    await page.locator('.ee-export').click();
    const backupText = await fs.readFile(await (await downloadPromise).path(), 'utf8');
    const backup = JSON.parse(backupText);
    assert.equal(backup.entries[0].text, text);
    assert.equal(backup.entries[0].images[0].caption, 'My credit');
    await page.locator('.ee-close').click();
    await page.reload(); await open(page, 'Nigersaurus');
    assert.equal(await page.locator('#ee-text').inputValue(), text);
    assert.equal(await page.locator('.ee-images img').count(), 1);
    await page.locator('.ee-close').click();

    const full = await context.newPage();
    await full.goto('https://atlas.test/full-animal-tree.html');
    await full.evaluate(() => {
      const d = r.descendants().find(d => d.data.id === 'nigersaurus');
      V.call(zoom.transform, d3.zoomIdentity.translate(innerWidth / 2 - d.x, (innerHeight - 100) / 2 + d.y));
    });
    const fullEntry = full.locator('.n').filter({ has: full.locator('.t', { hasText: 'Nigersaurus' }) });
    await fullEntry.click();
    assert.equal(await full.locator('.entry-editor').isVisible(), false);
    await full.waitForTimeout(650);
    await fullEntry.click();
    await ready(full);
    assert.equal(await full.locator('#ee-text').inputValue(), text);
    await open(page, 'Nigersaurus');
    await full.locator('#ee-text').fill('Newer edit from other view'); await save(full);
    await page.locator('#ee-text').fill('Stale draft'); await page.locator('.ee-save').click();
    await page.waitForFunction(() => document.querySelector('.ee-status').dataset.error === 'true');
    page.once('dialog', d => d.dismiss()); await page.locator('.ee-close').click();
    assert.equal(await page.locator('.entry-editor').isVisible(), true);
    page.once('dialog', d => d.accept()); await page.locator('.ee-close').click();

    const phoneContext = await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true });
    await phoneContext.route('**/*', serve);
    const phone = await phoneContext.newPage();
    await phone.goto('https://atlas.test/animal-evolution-tree.html');
    await phone.evaluate(() => {
      const n = D.find(n => n[0] === 'Nigersaurus'); s = ts = 1;
      x = tx = view.clientWidth / 2 - n[3]; y = ty = view.clientHeight / 2 - n[4]; draw();
    });
    await phone.locator('.card[data-name="Nigersaurus"]').tap();
    assert.equal(await phone.locator('.entry-editor').isVisible(), false);
    await phone.waitForTimeout(650);
    await phone.locator('.card[data-name="Nigersaurus"]').tap(); await ready(phone);
    assert.equal(await phone.locator('#ee-text').inputValue(), '');
    phone.once('dialog', d => d.accept());
    await phone.locator('#ee-backup').setInputFiles({ name: 'backup.json', mimeType: 'application/json', buffer: Buffer.from(backupText) });
    await phone.waitForFunction(() => document.querySelector('.ee-status').textContent.startsWith('Restored'));
    assert.equal(await phone.locator('#ee-text').inputValue(), text);
    assert.equal(await phone.locator('.ee-images img').count(), 1);
    assert.equal(await phone.locator('.entry-editor').evaluate(e => e.scrollWidth <= e.clientWidth), true);
    await phone.locator('.ee-images img').tap();
    assert.equal(await phone.locator('.ee-image-viewer').isVisible(), true);
    assert.equal(await phone.locator('.ee-image-viewer').evaluate(e => e.scrollWidth <= e.clientWidth), true);
    await phone.locator('.ee-viewer-close').tap();
    assert.equal(await phone.locator('.entry-editor').isVisible(), true);
    await phone.locator('#ee-files').setInputFiles([
      { name: 'second.png', mimeType: 'image/png', buffer: Buffer.from(png, 'base64') },
      { name: 'third.png', mimeType: 'image/png', buffer: Buffer.from(png, 'base64') }
    ]);
    await phone.waitForFunction(() => document.querySelectorAll('.ee-images img').length === 3 && !document.querySelector('#ee-text').disabled);
    await phone.locator('.ee-caption').nth(1).scrollIntoViewIfNeeded();
    await phone.locator('.ee-caption').nth(1).fill('Second image');
    await phone.locator('.ee-caption').nth(2).scrollIntoViewIfNeeded();
    await phone.locator('.ee-caption').nth(2).fill('Third image');
    await checkGallery(phone);
    await phone.locator('.ee-remove').nth(2).click();
    await phone.locator('.ee-remove').nth(1).click();
    await phone.locator('.ee-remove').click(); await save(phone); await phone.locator('.ee-close').click();
    await open(phone, 'Tyrannosaurus'); assert.equal(await phone.locator('#ee-text').inputValue(), '');
    await phone.locator('#ee-backup').setInputFiles({ name: 'bad.json', mimeType: 'application/json', buffer: Buffer.from('{"format":"wrong"}') });
    await phone.waitForFunction(() => document.querySelector('.ee-status').dataset.error === 'true');

    const reader = await context.newPage();
    const publishedEntry = { ...backup.entries[0], images: [backup.entries[0].images[0], { ...backup.entries[0].images[0], caption: 'Second image' }, { ...backup.entries[0].images[0], caption: 'Third image' }] };
    await reader.route('**/entry-content.js', route => route.fulfill({ body: 'window.ANIMAL_ATLAS_CONTENT=' + JSON.stringify({ editingEnabled: false, entries: { Nigersaurus: publishedEntry } }), contentType: 'application/javascript' }));
    await reader.goto('https://atlas.test/animal-evolution-tree.html');
    await open(reader, 'Nigersaurus');
    assert.equal(await reader.locator('.ee-save').isVisible(), false);
    assert.equal(await reader.locator('.ee-read-text').innerText(), text);
    assert.equal(await reader.locator('.ee-read-text em').count(), 0);
    assert.equal(await reader.locator('.ee-images img').count(), 3);
    await checkGallery(reader);
    await reader.locator('.ee-images img').first().click();
    assert.equal(await reader.locator('.ee-image-viewer').isVisible(), true);
    await reader.locator('.ee-viewer-close').click();

    const blockedContext = await browser.newContext({ acceptDownloads: true });
    await blockedContext.route('**/*', serve);
    const blocked = await blockedContext.newPage();
    await blocked.addInitScript(() => Object.defineProperty(indexedDB, 'open', { value: () => { throw new DOMException('Storage unavailable', 'SecurityError'); } }));
    await blocked.goto('https://atlas.test/animal-evolution-tree.html'); await open(blocked, 'Nigersaurus');
    await blocked.locator('#ee-text').fill('Rescue my draft');
    await blocked.locator('.ee-save').click();
    await blocked.waitForFunction(() => document.querySelector('.ee-status').textContent.startsWith('Could not save'));
    const rescuePromise = blocked.waitForEvent('download'); await blocked.locator('.ee-export').click();
    const rescue = JSON.parse(await fs.readFile(await (await rescuePromise).path(), 'utf8'));
    assert.equal(rescue.entries[0].text, 'Rescue my draft');
    assert.deepEqual(errors, []);
    console.log('PASS: selected-entry opening on desktop/D3/phone; single/multiple-image navigation, boundaries, captions, keyboard and arbitrary starting image on desktop/phone/read-only views; text/image save, reload, cross-view persistence, conflict/discard protection, backup/restore, phone layout, removal, entry isolation, invalid import, safe text rendering, storage-failure recovery.');
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
