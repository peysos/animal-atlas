(() => {
  'use strict';
  const config = window.ANIMAL_ATLAS_CONTENT || { editingEnabled: true, entries: {} };
  const editing = config.editingEnabled !== false;
  const canonical = name => name === 'Animalia / Metazoa' ? 'Animalia' : name;
  const MAX_IMAGES = 12;
  const MAX_IMAGE_BYTES = 15 * 1024 * 1024;
  const allowedImage = /^data:image\/(?:jpeg|png|webp);base64,[A-Za-z0-9+/=]+$/;
  let dbPromise, current = null, dirty = false, busy = false, opener = null, loadToken = 0;
  let storedAtOpen = null;

  const style = document.createElement('style');
  style.textContent = `
    .entry-editor{box-sizing:border-box;width:min(860px,94vw);max-height:90dvh;padding:0;border:1px solid #66877d;border-radius:18px;background:var(--bg,#173938);color:var(--txt,#eef6ef);box-shadow:0 24px 90px #0009;font:13px/1.5 ui-monospace,Consolas,monospace;overflow:auto}
    .entry-editor::backdrop{background:#031311bd;backdrop-filter:blur(4px)}
    .entry-editor *{box-sizing:border-box}.entry-editor header{height:auto;padding:20px 24px;display:flex;align-items:flex-start;justify-content:space-between;gap:16px;background:#ffffff06;border-bottom:1px solid #ffffff20;position:sticky;top:0;z-index:2;backdrop-filter:blur(20px)}
    .entry-editor h2{margin:0;font:700 24px/1.2 Georgia,serif;overflow-wrap:anywhere}.entry-editor .ee-subtitle{margin:6px 0 0;color:#bdcec4;font-size:11px}.entry-editor .ee-close{min-width:36px;font-size:21px;line-height:24px;padding:4px 8px}
    .entry-editor button,.entry-editor .ee-upload{display:inline-flex;align-items:center;justify-content:center;gap:6px;background:#ffffff0a;color:inherit;border:1px solid #66877d;border-radius:8px;padding:8px 12px;font:inherit;cursor:pointer;white-space:nowrap}
    .entry-editor button:hover,.entry-editor .ee-upload:hover{background:#ffffff18;border-color:#bcd3c7}.entry-editor button:focus-visible,.entry-editor textarea:focus-visible,.entry-editor input:focus-visible,.entry-editor .ee-upload:focus-within{outline:2px solid #a5d5c2;outline-offset:3px}
    .entry-editor button:disabled{opacity:.5;cursor:wait}.entry-editor .ee-main{padding:22px 24px}.entry-editor .ee-note{margin:0 0 20px;padding:10px 12px;border:1px solid #66877d66;border-radius:9px;color:#bdcec4;font-size:11px;background:#ffffff05}
    .entry-editor .ee-label{display:block;margin-bottom:7px;font-weight:bold}.entry-editor textarea{width:100%;min-height:200px;resize:vertical;background:#0002;color:inherit;border:1px solid #66877d;border-radius:10px;padding:12px;font:inherit;line-height:1.65}
    .entry-editor .ee-images-head{display:flex;justify-content:space-between;align-items:center;gap:12px;margin:22px 0 12px}.entry-editor h3{margin:0;font:700 17px Georgia,serif}.entry-editor .ee-upload input{position:absolute;width:1px;height:1px;opacity:0}
    .entry-editor .ee-images{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}.entry-editor figure{margin:0;padding:9px;background:#ffffff06;border:1px solid #ffffff20;border-radius:11px;min-width:0}.entry-editor figure img{display:block;width:100%;height:140px;object-fit:contain;border-radius:6px;background:#0002}
    .entry-editor .ee-caption{display:block;width:100%;margin:8px 0;background:#0002;border:1px solid #66877d;color:inherit;border-radius:6px;padding:7px;font:11px/1.5 ui-monospace,Consolas,monospace}.entry-editor figcaption{overflow-wrap:anywhere;font-size:11px;margin-top:8px;white-space:pre-wrap}
    .entry-editor .ee-remove{font-size:11px;padding:4px 8px}.entry-editor .ee-empty{margin:6px 0;color:#bdcec4;font-size:12px}.entry-editor .ee-footer{padding:16px 24px;border-top:1px solid #ffffff20;display:flex;align-items:center;gap:9px;flex-wrap:wrap;background:#ffffff05}
    .entry-editor .ee-save{background:#2c6756;border-color:#8ebfac;font-weight:bold}.entry-editor .ee-status{flex:1 1 100%;min-height:20px;margin:0;color:#bdcec4;font-size:11px}.entry-editor .ee-status[data-error=true]{color:#ffb6a8}.entry-editor .ee-read-text{white-space:pre-wrap;overflow-wrap:anywhere;line-height:1.8}
    .entry-editor .ee-time{font-size:10px;color:#bdcec4;margin:10px 0 0}.entry-editor [hidden]{display:none!important}
    .entry-editor .ee-image-open{display:block;width:100%;padding:0;border:0;background:none;cursor:zoom-in;border-radius:6px}
    .ee-image-viewer{box-sizing:border-box;width:min(1200px,96vw);height:min(900px,94dvh);max-width:96vw;max-height:94dvh;margin:auto;padding:16px;border:1px solid #66877d;border-radius:14px;background:var(--bg,#173938);color:var(--txt,#eef6ef);box-shadow:0 24px 90px #000b;overflow:hidden}
    .ee-image-viewer::backdrop{background:#020b0ded;backdrop-filter:blur(6px)}.ee-image-viewer[open]{display:flex;flex-direction:column;gap:12px}
    .ee-image-viewer .ee-viewer-close{align-self:flex-end;background:#ffffff0a;color:inherit;border:1px solid #66877d;border-radius:8px;padding:8px 12px;font:13px ui-monospace,Consolas,monospace;cursor:pointer}
    .ee-image-viewer .ee-viewer-close:focus-visible{outline:2px solid #a5d5c2;outline-offset:3px}.ee-image-viewer figure{display:flex;flex-direction:column;flex:1;min-height:0;margin:0}
    .ee-image-viewer img{display:block;flex:1;min-height:0;width:100%;height:100%;object-fit:contain}.ee-image-viewer figcaption{flex:none;max-height:18dvh;overflow:auto;margin-top:10px;font:12px/1.5 ui-monospace,Consolas,monospace;white-space:pre-wrap;overflow-wrap:anywhere;text-align:center}
    .ee-image-viewer .ee-viewer-nav{position:absolute;top:50%;transform:translateY(-50%);display:grid;place-items:center;width:42px;height:48px;padding:0;background:#071b20dc;color:#eef6ef;border:1px solid #9bb7ab;border-radius:9px;font:28px Georgia,serif;cursor:pointer;box-shadow:0 3px 12px #0008;z-index:1}
    .ee-image-viewer .ee-viewer-prev{left:20px}.ee-image-viewer .ee-viewer-next{right:20px}.ee-image-viewer .ee-viewer-nav:hover{background:#28534c}.ee-image-viewer .ee-viewer-nav:focus-visible{outline:2px solid #a5d5c2;outline-offset:3px}.ee-image-viewer [hidden]{display:none!important}
    .ee-image-viewer .ee-viewer-count{position:absolute;top:24px;left:24px;color:#bdcec4;font:12px ui-monospace,Consolas,monospace}
    @media(max-width:650px){.entry-editor{width:96vw;max-height:94dvh;border-radius:13px}.entry-editor header{padding:16px}.entry-editor h2{font-size:21px}.entry-editor .ee-main{padding:17px 16px}.entry-editor .ee-footer{padding:14px 16px}.entry-editor .ee-images{grid-template-columns:repeat(2,minmax(0,1fr))}.entry-editor textarea{min-height:180px;font-size:16px}.entry-editor .ee-caption{font-size:16px}.entry-editor figure img{height:115px}.entry-editor .ee-footer button{flex:1 1 auto}}
  `;
  document.head.append(style);
  const dialog = document.createElement('dialog');
  dialog.className = 'entry-editor';
  dialog.setAttribute('aria-labelledby', 'ee-title');
  dialog.innerHTML = `
    <header><div><h2 id="ee-title"></h2><p class="ee-subtitle" id="ee-subtitle"></p></div><button type="button" class="ee-close" aria-label="Close entry">×</button></header>
    <div class="ee-main">
      <p class="ee-note">Your writing and images are saved in this browser on this device. They are not published to GitHub. Download a backup to keep a copy or move your work to another browser.</p>
      <section class="ee-edit"><label class="ee-label" for="ee-text">Your information</label><textarea id="ee-text" placeholder="Write what you want people to know about this entry…"></textarea></section>
      <div class="ee-read-text" hidden></div>
      <div class="ee-images-head"><h3>Images</h3><label class="ee-upload">+ Add images<input id="ee-files" type="file" accept="image/jpeg,image/png,image/webp,image/avif" multiple></label></div>
      <div class="ee-images"></div><p class="ee-empty">No images added yet.</p><p class="ee-time"></p>
    </div>
    <footer class="ee-footer"><button class="ee-save" type="button">Save</button><button class="ee-copy" type="button">Copy name</button><button class="ee-export" type="button">Download backup</button><button class="ee-import" type="button">Restore backup</button><input id="ee-backup" type="file" accept="application/json,.json" hidden><p class="ee-status" role="status" aria-live="polite"></p></footer>`;
  document.body.append(dialog);
  const imageViewer = document.createElement('dialog');
  imageViewer.className = 'ee-image-viewer'; imageViewer.setAttribute('aria-label', 'Enlarged entry image');
  imageViewer.innerHTML = '<span class="ee-viewer-count" aria-live="polite"></span><button type="button" class="ee-viewer-close" aria-label="Close enlarged image">Close ×</button><button type="button" class="ee-viewer-nav ee-viewer-prev" aria-label="Previous image" hidden>‹</button><button type="button" class="ee-viewer-nav ee-viewer-next" aria-label="Next image" hidden>›</button><figure><img alt=""><figcaption></figcaption></figure>';
  document.body.append(imageViewer);
  let imageOpener = null, imageIndex = 0;
  function closeImage() { imageViewer.close(); imageViewer.querySelector('img').removeAttribute('src'); imageOpener?.focus({ preventScroll: true }); }
  function enlargeImage(image, button) {
    imageOpener = button;
    imageIndex = current.images.indexOf(image);
    if (imageIndex < 0) return;
    showViewerImage();
    imageViewer.showModal();
  }
  function showViewerImage() {
    const image = current.images[imageIndex];
    const picture = imageViewer.querySelector('img'), caption = imageViewer.querySelector('figcaption');
    picture.src = image.data; picture.alt = image.caption || `Image of ${current.name}`;
    caption.textContent = image.caption || current.name;
    const previous = imageViewer.querySelector('.ee-viewer-prev'), next = imageViewer.querySelector('.ee-viewer-next');
    const focused = document.activeElement;
    previous.hidden = imageIndex === 0; next.hidden = imageIndex === current.images.length - 1;
    const count = imageViewer.querySelector('.ee-viewer-count');
    count.textContent = `${imageIndex + 1} / ${current.images.length}`; count.hidden = current.images.length < 2;
    if (focused === previous && previous.hidden) (next.hidden ? imageViewer.querySelector('.ee-viewer-close') : next).focus();
    if (focused === next && next.hidden) (previous.hidden ? imageViewer.querySelector('.ee-viewer-close') : previous).focus();
  }
  function moveImage(direction) {
    const target = imageIndex + direction;
    if (target < 0 || target >= current.images.length) return;
    imageIndex = target; showViewerImage();
  }
  imageViewer.querySelector('.ee-viewer-close').addEventListener('click', closeImage);
  imageViewer.querySelector('.ee-viewer-prev').addEventListener('click', () => moveImage(-1));
  imageViewer.querySelector('.ee-viewer-next').addEventListener('click', () => moveImage(1));
  imageViewer.addEventListener('keydown', event => {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      event.preventDefault(); event.stopPropagation(); moveImage(event.key === 'ArrowLeft' ? -1 : 1);
    }
  });
  imageViewer.addEventListener('cancel', event => { event.preventDefault(); event.stopPropagation(); closeImage(); });
  imageViewer.addEventListener('click', event => {
    const bounds = imageViewer.getBoundingClientRect();
    if (event.target === imageViewer && (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom)) closeImage();
  });
  const $ = selector => dialog.querySelector(selector);
  const textarea = $('#ee-text'), fileInput = $('#ee-files'), backupInput = $('#ee-backup');
  function status(message, error = false) { $('.ee-status').textContent = message; $('.ee-status').dataset.error = String(error); }
  function setBusy(value) {
    busy = value;
    dialog.querySelectorAll('button,textarea,input').forEach(el => { el.disabled = value; });
    dialog.setAttribute('aria-busy', String(value));
  }
  function changed() { dirty = true; status('Unsaved changes'); }
  function database() {
    if (!dbPromise) dbPromise = new Promise((resolve, reject) => {
      const request = indexedDB.open('animal-atlas-entries', 1);
      request.onupgradeneeded = () => request.result.createObjectStore('entries', { keyPath: 'name' });
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error || new Error('Browser storage is unavailable.'));
      request.onblocked = () => reject(new Error('Close other Animal Atlas tabs and try again.'));
    }).catch(error => { dbPromise = null; throw error; });
    return dbPromise;
  }
  async function transaction(mode, action) {
    const db = await database();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('entries', mode), request = action(tx.objectStore('entries'));
      tx.oncomplete = () => resolve(request?.result);
      tx.onerror = () => reject(tx.error || new Error('Could not save to browser storage.'));
      tx.onabort = () => reject(tx.error || new Error('Browser storage is full or unavailable.'));
    });
  }
  const get = name => transaction('readonly', store => store.get(name));
  const getAll = () => transaction('readonly', store => store.getAll());
  function validateRecord(record) {
    if (!record || typeof record.name !== 'string' || !record.name.trim() || record.name.length > 200 || typeof record.text !== 'string' || record.text.length > 200000 || !Array.isArray(record.images) || record.images.length > MAX_IMAGES) throw new Error('This backup contains an invalid entry.');
    const images = record.images.map(img => {
      if (!img || typeof img.data !== 'string' || img.data.length > 8 * 1024 * 1024 || !allowedImage.test(img.data) || typeof img.caption !== 'string' || img.caption.length > 2000) throw new Error('This backup contains an invalid image.');
      return { data: img.data, caption: img.caption };
    });
    return { name: canonical(record.name), text: record.text, images, updatedAt: typeof record.updatedAt === 'string' ? record.updatedAt : new Date().toISOString() };
  }
  function snapshot() { return { name: current.name, text: textarea.value, images: current.images.map(img => ({ ...img })), updatedAt: new Date().toISOString() }; }
  function renderImages() {
    const grid = $('.ee-images'); grid.replaceChildren();
    $('.ee-empty').hidden = current.images.length !== 0;
    current.images.forEach((img, index) => {
      const figure = document.createElement('figure'), picture = document.createElement('img');
      picture.src = img.data; picture.alt = img.caption || `Image of ${current.name}`;
      const enlarge = document.createElement('button'); enlarge.type = 'button'; enlarge.className = 'ee-image-open'; enlarge.title = 'Click to enlarge'; enlarge.setAttribute('aria-label', `Enlarge image ${index + 1} of ${current.name}`);
      enlarge.append(picture); enlarge.addEventListener('click', () => enlargeImage(img, enlarge)); figure.append(enlarge);
      if (editing) {
        const caption = document.createElement('input'); caption.type = 'text'; caption.className = 'ee-caption'; caption.value = img.caption; caption.maxLength = 2000; caption.placeholder = 'Caption / image credit'; caption.setAttribute('aria-label', `Caption or credit for image ${index + 1}`);
        caption.addEventListener('input', () => { img.caption = caption.value; picture.alt = caption.value || `Image of ${current.name}`; changed(); });
        const remove = document.createElement('button'); remove.type = 'button'; remove.className = 'ee-remove'; remove.textContent = 'Remove image'; remove.addEventListener('click', () => { current.images.splice(index, 1); renderImages(); changed(); }); figure.append(caption, remove);
      } else if (img.caption) { const caption = document.createElement('figcaption'); caption.textContent = img.caption; figure.append(caption); }
      grid.append(figure);
    });
  }
  function render(record) {
    current = { name: record.name, text: record.text || '', images: (record.images || []).map(img => ({ ...img })), updatedAt: record.updatedAt };
    textarea.value = current.text; textarea.maxLength = 200000;
    $('.ee-read-text').textContent = current.text || 'No information has been added yet.';
    $('.ee-time').textContent = current.updatedAt ? `Last saved: ${new Date(current.updatedAt).toLocaleString()}` : '';
    renderImages(); dirty = false;
  }
  function close() {
    if (busy) return;
    if (dirty && !window.confirm('Close without saving your changes?')) return;
    ++loadToken; dialog.close(); current = null; dirty = false; opener?.focus({ preventScroll: true });
  }
  async function open(name, subtitle = '') {
    if (dialog.open) return;
    opener = document.activeElement; const token = ++loadToken;
    name = canonical(name); current = { name, text: '', images: [] }; storedAtOpen = null; dirty = false;
    $('#ee-title').textContent = name; $('#ee-subtitle').textContent = subtitle;
    $('.ee-edit').hidden = !editing; $('.ee-read-text').hidden = editing;
    for (const selector of ['.ee-note', '.ee-upload', '.ee-save', '.ee-export', '.ee-import']) $(selector).hidden = !editing;
    render(current); status(editing ? 'Loading saved work…' : ''); setBusy(true); dialog.showModal(); dialog.scrollTop = 0;
    try {
      const local = editing ? await get(name) : null;
      if (token !== loadToken) return;
      const published = Object.hasOwn(config.entries || {}, name) ? config.entries[name] : null;
      render(local || { ...published, name }); storedAtOpen = local?.updatedAt || null;
      status(editing ? (local ? 'Saved work loaded from this browser.' : 'Ready for your text and images.') : '');
    } catch { if (token === loadToken) status('Browser storage is unavailable. You can still write and download a backup; Save will try again.', true); }
    finally { if (token === loadToken) { setBusy(false); if (editing) textarea.focus(); } }
  }
  async function save() {
    if (!current || busy || !editing) return;
    setBusy(true); status('Saving…');
    try {
      const record = validateRecord(snapshot());
      // Read and compare in the same transaction as the write to avoid silently
      // replacing an edit saved by a second tab since this entry was opened.
      await transaction('readwrite', store => {
        const request = store.get(record.name);
        request.onsuccess = () => {
          if ((request.result?.updatedAt || null) !== storedAtOpen) { store.transaction.abort(); return; }
          store.put(record);
        };
        return request;
      });
      storedAtOpen = record.updatedAt; current.updatedAt = record.updatedAt; dirty = false;
      $('.ee-time').textContent = `Last saved: ${new Date(record.updatedAt).toLocaleString()}`;
      status('Saved in this browser. Download a backup to keep another copy.');
    } catch { status('Could not save. Another tab may have changed this entry, or browser storage is full/unavailable. Download a backup before closing.', true); }
    finally { setBusy(false); }
  }
  async function imageData(file) {
    if (!/^image\/(jpeg|png|webp|avif)$/.test(file.type)) throw new Error('Choose JPG, PNG, WebP or AVIF images.');
    if (file.size > MAX_IMAGE_BYTES) throw new Error('Choose images smaller than 15 MB each.');
    const url = URL.createObjectURL(file), img = new Image();
    try {
      img.src = url; await img.decode();
      const scale = Math.min(1, 1600 / Math.max(img.naturalWidth, img.naturalHeight));
      const canvas = document.createElement('canvas'); canvas.width = Math.max(1, Math.round(img.naturalWidth * scale)); canvas.height = Math.max(1, Math.round(img.naturalHeight * scale));
      canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);
      return { data: canvas.toDataURL('image/webp', .86), caption: '' };
    } finally { URL.revokeObjectURL(url); }
  }
  fileInput.addEventListener('change', async () => {
    const files = [...fileInput.files]; fileInput.value = '';
    if (!files.length || !current || busy) return;
    if (current.images.length + files.length > MAX_IMAGES) { status(`You can add up to ${MAX_IMAGES} images per entry.`, true); return; }
    setBusy(true); status('Preparing images…');
    try { const images = []; for (const file of files) images.push(await imageData(file)); current.images.push(...images); renderImages(); changed(); }
    catch (error) { status(error.message || 'Could not open that image.', true); }
    finally { setBusy(false); }
  });
  async function exportBackup() {
    if (busy || !current) return;
    setBusy(true);
    try {
      let records = []; let storageFailed = false;
      try { records = await getAll(); } catch { storageFailed = true; }
      const entries = new Map(records.map(r => [r.name, r]));
      // Include the current draft even if Save failed or has not been pressed.
      entries.set(current.name, validateRecord(snapshot()));
      const data = { format: 'animal-atlas-entry-backup', schemaVersion: 1, exportedAt: new Date().toISOString(), entries: [...entries.values()] };
      const url = URL.createObjectURL(new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' }));
      const link = document.createElement('a'); link.href = url; link.download = `animal-atlas-backup-${new Date().toISOString().slice(0, 10)}.json`; dialog.append(link); link.click(); link.remove(); setTimeout(() => URL.revokeObjectURL(url), 60000);
      status(storageFailed ? 'Downloaded this entry only: browser storage could not be read.' : `Downloaded a backup of ${entries.size} saved/draft entries. Keep this file for restoration or publishing.`, storageFailed);
    } catch (error) { status(error.message || 'Could not download a backup.', true); }
    finally { setBusy(false); }
  }
  backupInput.addEventListener('change', async () => {
    const file = backupInput.files[0]; backupInput.value = '';
    if (!file || busy) return;
    try {
      if (file.size > 150 * 1024 * 1024) throw new Error('This backup is too large. Choose a file smaller than 150 MB.');
      const data = JSON.parse(await file.text());
      if (data.format !== 'animal-atlas-entry-backup' || data.schemaVersion !== 1 || !Array.isArray(data.entries) || data.entries.length > 5000) throw new Error('Choose an Animal Atlas entry backup file.');
      const records = data.entries.map(validateRecord);
      if (!window.confirm(`Restore ${records.length} entries? Matching entries saved in this browser will be replaced, including any unsaved changes for this entry.`)) return;
      setBusy(true);
      await transaction('readwrite', store => { for (const record of records) store.put(record); });
      const record = await get(current.name); if (record) { render(record); storedAtOpen = record.updatedAt; }
      status(`Restored ${records.length} entries in this browser.`);
    } catch (error) { status(error.message || 'Could not restore that backup.', true); }
    finally { setBusy(false); }
  });
  textarea.addEventListener('input', changed);
  $('.ee-close').addEventListener('click', close);
  dialog.addEventListener('cancel', event => { event.preventDefault(); close(); });
  $('.ee-save').addEventListener('click', save);
  $('.ee-export').addEventListener('click', exportBackup);
  $('.ee-import').addEventListener('click', () => backupInput.click());
  $('.ee-copy').addEventListener('click', async () => {
    try {
      if (navigator.clipboard && window.isSecureContext) await navigator.clipboard.writeText(current.name);
      else { const input = document.createElement('textarea'); input.value = current.name; dialog.append(input); input.select(); const copied = document.execCommand('copy'); input.remove(); if (!copied) throw new Error(); }
      status('Name copied.');
    } catch { status('Could not copy the name. You can select it in the heading.', true); }
  });
  dialog.addEventListener('keydown', event => { if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 's' && editing) { event.preventDefault(); save(); } });
  window.addEventListener('beforeunload', event => { if (dirty) { event.preventDefault(); event.returnValue = ''; } });
  document.querySelectorAll('.card,.n').forEach(node => {
    node.tabIndex = 0; node.setAttribute('role', 'button'); node.setAttribute('aria-haspopup', 'dialog');
    node.addEventListener('keydown', event => {
      if (event.target === node && (event.key === 'Enter' || event.key === ' ')) {
        event.preventDefault(); event.stopPropagation(); node.dispatchEvent(new MouseEvent('click', { bubbles: true }));
        open(node.dataset.name || node.__data__?.data?.title, node.dataset.subtitle || node.__data__?.data?.subtitle || '');
      }
    });
  });
  function activate(name, subtitle, wasSelected = false) {
    if (!dialog.open && wasSelected) open(name, subtitle);
  }
  window.AnimalAtlasEntries = { open, activate };
})();
