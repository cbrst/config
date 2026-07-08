// ==UserScript==
// @name         Wallhaven Wallpaper Downloader
// @namespace    https://github.com/cbrst/config
// @version      2.0.1
// @description  Add wallpaper download buttons with optional WebP conversion.
// @author       cbrst
// @match        https://wallhaven.cc/*
// @run-at       document-idle
// @require      https://unpkg.com/@saschazar/wasm-webp@3.0.1/wasm_webp.js
// @grant        GM.download
// @grant        GM.getValue
// @grant        GM.setValue
// @grant        GM.registerMenuCommand
// @grant        GM.xmlHttpRequest
// @grant        GM_download
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_registerMenuCommand
// @grant        GM_xmlhttpRequest
// @connect      unpkg.com
// ==/UserScript==

(function () {
  "use strict";

  const SCRIPT_NAME = "Wallhaven Wallpaper Downloader";
  const STYLE_ID = "wallhaven-downloader-styles";
  const SETTINGS_BUTTON_ID = "wallhaven-downloader-settings-button";
  const SETTINGS_DIALOG_ID = "wallhaven-downloader-settings";
  const CONFIG_KEYS = {
    convertToWebp: "wallhaven-downloader.convert-to-webp",
    downloadLocation: "wallhaven-downloader.download-location",
    webpQuality: "wallhaven-downloader.webp-quality",
  };
  const WEBP_WASM_URL = "https://unpkg.com/@saschazar/wasm-webp@3.0.1/wasm_webp.wasm";

  let scanQueued = false;
  let webpWasmBinaryPromise = null;

  // Normalize the modern and legacy userscript-manager APIs behind one interface.
  const gm = {
    getValue: async (key, fallback) => {
      if (typeof GM !== "undefined" && GM.getValue) return GM.getValue(key, fallback);
      if (typeof GM_getValue === "function") return GM_getValue(key, fallback);

      const value = localStorage.getItem(key);
      return value == null ? fallback : JSON.parse(value);
    },
    setValue: async (key, value) => {
      if (typeof GM !== "undefined" && GM.setValue) return GM.setValue(key, value);
      if (typeof GM_setValue === "function") return GM_setValue(key, value);

      localStorage.setItem(key, JSON.stringify(value));
      return undefined;
    },
    registerMenuCommand: (label, handler) => {
      if (typeof GM !== "undefined" && GM.registerMenuCommand) {
        GM.registerMenuCommand(label, handler);
      } else if (typeof GM_registerMenuCommand === "function") {
        GM_registerMenuCommand(label, handler);
      }
    },
  };

  addStyles();
  addSettingsButton();
  addDownloadButtons();
  gm.registerMenuCommand("Wallhaven download settings", showSettings);

  // Wallhaven can replace gallery contents without a full navigation.
  new MutationObserver(queueScan).observe(document.body, {
    childList: true,
    subtree: true,
  });

  function queueScan() {
    // Coalesce mutation bursts into a single inexpensive DOM scan.
    if (scanQueued) return;
    scanQueued = true;
    requestAnimationFrame(() => {
      scanQueued = false;
      addDownloadButtons();
    });
  }

  function addDownloadButtons() {
    // Add an overlay button to each gallery/search thumbnail.
    document.querySelectorAll("figure.thumb[data-wallpaper-id]").forEach((thumbnail) => {
      if (thumbnail.querySelector(".wallhaven-download-button")) return;

      const button = makeDownloadButton(thumbnail.dataset.wallpaperId, "Download wallpaper");
      // Reuse Wallhaven's native thumbnail-control styling and hover behavior.
      button.classList.add("thumb-btn", "wallhaven-download-button--thumbnail");
      button.innerHTML = '<i class="far fa-download"></i>';
      thumbnail.append(button);
    });

    // Add a native-looking item to the Tools section on wallpaper pages.
    const wallpaper = document.querySelector("#wallpaper[data-wallpaper-id]");
    const tools = document.querySelector("ul.showcase-tools");
    if (wallpaper && tools && !tools.querySelector(".wallhaven-download-tool")) {
      const item = document.createElement("li");
      const button = makeDownloadButton(
        wallpaper.dataset.wallpaperId,
        "Download wallpaper",
        wallpaper.currentSrc || wallpaper.src,
      );

      item.className = "wallhaven-download-tool";
      button.classList.add("wallhaven-download-button--tool");
      button.innerHTML = '<i class="far fa-fw fa-download"></i>Download wallpaper';
      item.append(button);
      tools.append(item);
    }
  }

  function addSettingsButton() {
    // Safari's Userscripts extension has no registerMenuCommand interface.
    if (document.getElementById(SETTINGS_BUTTON_ID)) return;

    const button = document.createElement("button");
    button.id = SETTINGS_BUTTON_ID;
    button.type = "button";
    button.title = "Wallhaven download settings";
    button.setAttribute("aria-label", "Wallhaven download settings");
    button.innerHTML = '<i class="fas fa-cog" aria-hidden="true"></i>';
    button.addEventListener("click", () => {
      void showSettings();
    });
    document.body.append(button);
  }

  function makeDownloadButton(wallpaperId, label, knownUrl = "") {
    // Buttons, rather than links, prevent Wallhaven's preview navigation.
    const button = document.createElement("button");
    button.type = "button";
    button.className = "wallhaven-download-button";
    button.title = label;
    button.setAttribute("aria-label", label);
    button.textContent = "↓";
    button.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      void downloadWallpaper(wallpaperId, knownUrl, button);
    });
    return button;
  }

  async function downloadWallpaper(wallpaperId, knownUrl, button) {
    // Resolve, optionally convert, and save the original full-resolution image.
    if (button.disabled) return;
    button.disabled = true;
    button.classList.add("is-busy");

    try {
      const config = await getConfig();
      const imageUrl = knownUrl || await resolveWallpaperUrl(wallpaperId);
      const sourceFilename = filenameFromUrl(imageUrl, wallpaperId);
      let downloadUrl = imageUrl;
      let filename = sourceFilename;
      let temporaryUrl = "";

      if (config.convertToWebp) {
        const source = await fetchImageBlob(imageUrl);
        const webp = await convertBlobToWebp(source, config.webpQuality);
        const optimizedBlob = webp && webp.size < source.size ? webp : source;
        temporaryUrl = URL.createObjectURL(optimizedBlob);
        downloadUrl = temporaryUrl;

        // Keep an already smaller original rather than increasing its file size.
        if (optimizedBlob === webp) {
          filename = sourceFilename.replace(/\.[^.]+$/, "") + ".webp";
        }
      }

      await saveDownload(downloadUrl, joinDownloadPath(config.downloadLocation, filename));
      notify(`Downloaded ${filename}.`, "success");

      // Keep object URLs alive briefly so the download manager can consume them.
      if (temporaryUrl) setTimeout(() => URL.revokeObjectURL(temporaryUrl), 60_000);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error(`[${SCRIPT_NAME}]`, error);
      notify(`Download failed: ${message}`, "error");
    } finally {
      button.disabled = false;
      button.classList.remove("is-busy");
    }
  }

  async function resolveWallpaperUrl(wallpaperId) {
    // Read the detail page because original uploads may be either JPEG or PNG.
    const response = await fetch(`/w/${encodeURIComponent(wallpaperId)}`, {
      credentials: "include",
    });
    if (!response.ok) throw new Error(`wallpaper page returned HTTP ${response.status}`);

    const documentCopy = new DOMParser().parseFromString(await response.text(), "text/html");
    const imageUrl = documentCopy.querySelector("#wallpaper")?.getAttribute("src");
    if (!imageUrl) throw new Error("could not find the full-resolution image");
    return new URL(imageUrl, location.href).href;
  }

  async function fetchImageBlob(url) {
    // Wallhaven permits cross-origin image reads; fetching preserves the original bytes.
    const response = await fetch(url, {
      credentials: "omit",
      mode: "cors",
    });
    if (!response.ok) throw new Error(`image returned HTTP ${response.status}`);
    return response.blob();
  }

  async function convertBlobToWebp(blob, quality) {
    // Canvas decodes the source into the raw RGBA pixels expected by libwebp.
    const bitmap = await createImageBitmap(blob);
    const canvas = document.createElement("canvas");
    canvas.width = bitmap.width;
    canvas.height = bitmap.height;
    const context = canvas.getContext("2d");
    if (!context) throw new Error("WebP conversion is unavailable");

    context.drawImage(bitmap, 0, 0);
    bitmap.close();

    const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
    const encoder = await getWebpEncoder();
    const encoded = encoder.encode(
      imageData.data,
      imageData.width,
      imageData.height,
      4,
      makeWebpOptions(quality),
    );
    const webp = new Blob([new Uint8Array(encoded)], { type: "image/webp" });

    // Release libwebp's output allocation after copying it into the Blob.
    encoder.free();
    return webp.size < blob.size ? webp : null;
  }

  function makeWebpOptions(quality) {
    // These settings mirror `cwebp -q <quality> -m 6` with complete libwebp defaults.
    return {
      quality,
      target_size: 0,
      target_PSNR: 0,
      method: 6,
      sns_strength: 50,
      filter_strength: 60,
      filter_sharpness: 0,
      filter_type: 1,
      partitions: 0,
      segments: 4,
      pass: 1,
      show_compressed: 0,
      preprocessing: 0,
      autofilter: 0,
      partition_limit: 0,
      alpha_compression: 1,
      alpha_filtering: 1,
      alpha_quality: 100,
      lossless: 0,
      exact: 0,
      image_hint: 0,
      emulate_jpeg_size: 0,
      thread_level: 0,
      low_memory: 0,
      near_lossless: 100,
      use_delta_palette: 0,
      use_sharp_yuv: 0,
    };
  }

  async function getWebpEncoder() {
    // `free()` invalidates an encoder, so reuse only the binary and create a fresh module.
    if (typeof wasm_webp !== "function") {
      throw new Error("libwebp encoder dependency did not load");
    }

    if (!webpWasmBinaryPromise) {
      webpWasmBinaryPromise = fetchWebpWasm();
    }

    const wasmBinary = await webpWasmBinaryPromise;
    return wasm_webp({ wasmBinary });
  }

  async function fetchWebpWasm() {
    // Prefer privileged XHR so Wallhaven's CSP and cross-origin rules cannot block WASM.
    if (typeof GM !== "undefined" && GM.xmlHttpRequest) {
      const response = await GM.xmlHttpRequest({
        method: "GET",
        url: WEBP_WASM_URL,
        responseType: "arraybuffer",
      });
      if (response.status < 200 || response.status >= 300) {
        throw new Error(`libwebp download returned HTTP ${response.status}`);
      }
      return response.response;
    }

    if (typeof GM_xmlhttpRequest === "function") {
      return new Promise((resolve, reject) => {
        GM_xmlhttpRequest({
          method: "GET",
          url: WEBP_WASM_URL,
          responseType: "arraybuffer",
          onload: (response) => {
            if (response.status >= 200 && response.status < 300) {
              resolve(response.response);
            } else {
              reject(new Error(`libwebp download returned HTTP ${response.status}`));
            }
          },
          onerror: () => reject(new Error("could not download the libwebp encoder")),
        });
      });
    }

    const response = await fetch(WEBP_WASM_URL, { mode: "cors" });
    if (!response.ok) throw new Error(`libwebp download returned HTTP ${response.status}`);
    return response.arrayBuffer();
  }

  async function saveDownload(url, name) {
    // Prefer the userscript download API because it supports relative subfolders.
    const options = { url, name, saveAs: false };
    if (typeof GM !== "undefined" && GM.download) {
      await GM.download(options);
      return;
    }

    if (typeof GM_download === "function") {
      await new Promise((resolve, reject) => {
        GM_download({
          ...options,
          onload: resolve,
          onerror: (error) => reject(new Error(error?.error || "userscript download failed")),
          ontimeout: () => reject(new Error("userscript download timed out")),
        });
      });
      return;
    }

    // Safari ignores `download` for cross-origin URLs, so save a local blob URL.
    let fallbackUrl = url;
    let temporaryUrl = "";
    if (!url.startsWith("blob:")) {
      const blob = await fetchImageBlob(url);
      temporaryUrl = URL.createObjectURL(blob);
      fallbackUrl = temporaryUrl;
    }

    const link = document.createElement("a");
    link.href = fallbackUrl;
    link.download = name.split("/").pop();
    link.hidden = true;
    document.body.append(link);
    link.click();
    link.remove();

    // Give Safari enough time to consume the blob before releasing it.
    if (temporaryUrl) setTimeout(() => URL.revokeObjectURL(temporaryUrl), 60_000);
  }

  async function getConfig() {
    // Missing values intentionally produce conservative defaults.
    return {
      convertToWebp: Boolean(await gm.getValue(CONFIG_KEYS.convertToWebp, false)),
      downloadLocation: normalizeDownloadLocation(
        await gm.getValue(CONFIG_KEYS.downloadLocation, "Wallhaven"),
      ),
      webpQuality: normalizeWebpQuality(await gm.getValue(CONFIG_KEYS.webpQuality, 92)),
    };
  }

  async function showSettings() {
    // Recreate the dialog so its fields always reflect persisted settings.
    document.getElementById(SETTINGS_DIALOG_ID)?.remove();
    const config = await getConfig();
    const supportsDownloadLocation = hasUserscriptDownloadApi();
    const locationSetting = supportsDownloadLocation
      ? `
        <label>
          Download location
          <input name="downloadLocation" type="text" placeholder="Wallhaven" autocomplete="off">
        </label>
        <p>Location is a subfolder inside your browser's Downloads folder.</p>
      `
      : `
        <p class="wallhaven-settings-notice">
          Safari Userscripts cannot choose a download subfolder. Change the global
          location in Safari Settings → General → File download location.
        </p>
      `;
    const dialog = document.createElement("dialog");
    dialog.id = SETTINGS_DIALOG_ID;
    dialog.innerHTML = `
      <form method="dialog">
        <h2>Wallhaven downloads</h2>
        <label class="wallhaven-settings-check">
          <input name="convertToWebp" type="checkbox">
          Convert wallpapers to WebP
        </label>
        <label>
          WebP quality
          <input name="webpQuality" type="number" min="1" max="100" step="1">
        </label>
        <p>Uses the maximum-compression libwebp method 6. Lower quality produces smaller files.</p>
        ${locationSetting}
        <div class="wallhaven-settings-actions">
          <button value="cancel">Cancel</button>
          <button value="save" class="wallhaven-settings-save">Save</button>
        </div>
      </form>
    `;

    const convertInput = dialog.querySelector("[name=convertToWebp]");
    const qualityInput = dialog.querySelector("[name=webpQuality]");
    const locationInput = dialog.querySelector("[name=downloadLocation]");
    convertInput.checked = config.convertToWebp;
    qualityInput.value = String(config.webpQuality);
    if (locationInput) locationInput.value = config.downloadLocation;

    dialog.addEventListener("close", async () => {
      if (dialog.returnValue === "save") {
        await gm.setValue(CONFIG_KEYS.convertToWebp, convertInput.checked);
        await gm.setValue(CONFIG_KEYS.webpQuality, normalizeWebpQuality(qualityInput.value));
        // Only managers with a download API can preserve a relative folder path.
        if (locationInput) {
          await gm.setValue(
            CONFIG_KEYS.downloadLocation,
            normalizeDownloadLocation(locationInput.value),
          );
        }
        notify("Download settings saved.", "success");
      }
      dialog.remove();
    });

    document.body.append(dialog);
    dialog.showModal();
  }

  function hasUserscriptDownloadApi() {
    // quoid/userscripts intentionally does not provide either download API.
    return Boolean(
      typeof GM !== "undefined" && GM.download
      || typeof GM_download === "function",
    );
  }

  function normalizeDownloadLocation(locationValue) {
    // Keep paths relative and strip characters forbidden by common download managers.
    return String(locationValue || "")
      .replace(/\\/g, "/")
      .split("/")
      .map((part) => part.trim().replace(/[<>:"|?*\u0000-\u001f]/g, "-"))
      .filter((part) => part && part !== "." && part !== "..")
      .join("/");
  }

  function normalizeWebpQuality(value) {
    // Keep user input within libwebp's supported quality range.
    const quality = Number.parseInt(String(value), 10);
    return Number.isFinite(quality) ? Math.min(100, Math.max(1, quality)) : 92;
  }

  function joinDownloadPath(locationValue, filename) {
    // An empty location saves directly into the normal Downloads folder.
    return locationValue ? `${locationValue}/${filename}` : filename;
  }

  function filenameFromUrl(url, wallpaperId) {
    // Decode safe URL filenames while retaining a predictable fallback.
    try {
      return decodeURIComponent(new URL(url).pathname.split("/").pop()) || `wallhaven-${wallpaperId}.jpg`;
    } catch (_error) {
      return `wallhaven-${wallpaperId}.jpg`;
    }
  }

  function notify(message, type) {
    // Lightweight toasts communicate progress without blocking the page.
    const toast = document.createElement("div");
    toast.className = `wallhaven-download-toast wallhaven-download-toast--${type}`;
    toast.textContent = message;
    document.body.append(toast);
    requestAnimationFrame(() => toast.classList.add("is-visible"));
    setTimeout(() => {
      toast.classList.remove("is-visible");
      setTimeout(() => toast.remove(), 200);
    }, 3500);
  }

  function addStyles() {
    // Keep all injected presentation isolated under script-specific class names.
    if (document.getElementById(STYLE_ID)) return;
    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      figure.thumb { position: relative; }
      .wallhaven-download-button {
        border: 0;
        color: #fff;
        cursor: pointer;
        font: inherit;
      }
      .wallhaven-download-button:disabled { cursor: wait; opacity: .7; }
      .thumb .wallhaven-download-button--thumbnail {
        position: absolute;
        z-index: 141;
        top: -.56666667em;
        right: 1.4em;
        background-color: #6a9f38;
      }
      .thumb .wallhaven-download-button--thumbnail:hover { background-color: #9fca56; }
      .wallhaven-download-button--tool {
        width: 100%;
        padding: 0;
        background: transparent;
        color: inherit;
        text-align: left;
      }
      .wallhaven-download-button--tool:hover { color: #9fca56; }
      .wallhaven-download-button.is-busy { animation: wallhaven-download-pulse .8s infinite alternate; }
      #${SETTINGS_BUTTON_ID} {
        position: fixed;
        z-index: 10000;
        right: 1rem;
        bottom: 1rem;
        display: grid;
        place-items: center;
        width: 2.75rem;
        height: 2.75rem;
        border: 1px solid #555d63;
        border-radius: 50%;
        background: #22272b;
        color: #ddd;
        cursor: pointer;
        font-size: 1.15rem;
        box-shadow: 0 .25rem 1rem rgba(0, 0, 0, .5);
      }
      #${SETTINGS_BUTTON_ID}:hover {
        border-color: #9fca56;
        background: #30363b;
        color: #9fca56;
      }
      #${SETTINGS_DIALOG_ID} {
        width: min(28rem, calc(100vw - 2rem));
        border: 1px solid #4b5055;
        border-radius: .4rem;
        padding: 1.25rem;
        background: #22272b;
        color: #ddd;
        box-shadow: 0 1rem 3rem rgba(0, 0, 0, .55);
      }
      #${SETTINGS_DIALOG_ID}::backdrop { background: rgba(0, 0, 0, .7); }
      #${SETTINGS_DIALOG_ID} h2 { margin: 0 0 1.25rem; color: #fff; }
      #${SETTINGS_DIALOG_ID} label { display: grid; gap: .4rem; margin: 1rem 0; }
      #${SETTINGS_DIALOG_ID} .wallhaven-settings-check {
        display: flex;
        align-items: center;
        gap: .65rem;
      }
      #${SETTINGS_DIALOG_ID} input[type="checkbox"] {
        -webkit-appearance: none;
        appearance: none;
        position: static;
        display: grid;
        visibility: visible;
        flex: 0 0 auto;
        place-content: center;
        width: 1.2rem;
        height: 1.2rem;
        margin: 0;
        border: 1px solid #737b81;
        border-radius: .2rem;
        background: #171a1d;
        opacity: 1;
        cursor: pointer;
      }
      #${SETTINGS_DIALOG_ID} input[type="checkbox"]::before {
        content: "";
        width: .55rem;
        height: .3rem;
        border-bottom: .15rem solid #fff;
        border-left: .15rem solid #fff;
        transform: translateY(-.08rem) rotate(-45deg) scale(0);
        transition: transform .1s ease;
      }
      #${SETTINGS_DIALOG_ID} input[type="checkbox"]:checked {
        border-color: #6a9f38;
        background: #6a9f38;
      }
      #${SETTINGS_DIALOG_ID} input[type="checkbox"]:checked::before {
        transform: translateY(-.08rem) rotate(-45deg) scale(1);
      }
      #${SETTINGS_DIALOG_ID} input[type="checkbox"]:focus-visible {
        outline: 2px solid #9fca56;
        outline-offset: 2px;
      }
      #${SETTINGS_DIALOG_ID} input[type="text"],
      #${SETTINGS_DIALOG_ID} input[type="number"] {
        box-sizing: border-box;
        width: 100%;
        border: 1px solid #555d63;
        border-radius: .25rem;
        padding: .65rem;
        background: #171a1d;
        color: #fff;
      }
      #${SETTINGS_DIALOG_ID} p { color: #aab0b5; font-size: .85rem; }
      #${SETTINGS_DIALOG_ID} .wallhaven-settings-notice {
        margin: 1rem 0;
        border-left: .2rem solid #d5bf2a;
        padding: .65rem .8rem;
        background: #191d20;
        color: #d5d8da;
        line-height: 1.45;
      }
      .wallhaven-settings-actions { display: flex; justify-content: flex-end; gap: .6rem; }
      .wallhaven-settings-actions button {
        border: 0;
        border-radius: .25rem;
        padding: .6rem 1rem;
        cursor: pointer;
      }
      .wallhaven-settings-save { background: #6a9f38; color: #fff; }
      .wallhaven-download-toast {
        position: fixed;
        z-index: 100000;
        right: 1rem;
        bottom: 4.5rem;
        max-width: min(30rem, calc(100vw - 2rem));
        border-left: .3rem solid #6a9f38;
        border-radius: .25rem;
        padding: .8rem 1rem;
        background: #22272b;
        color: #fff;
        box-shadow: 0 .4rem 1.5rem rgba(0, 0, 0, .45);
        opacity: 0;
        transform: translateY(.75rem);
        transition: .2s ease;
      }
      .wallhaven-download-toast--error { border-left-color: #d9534f; }
      .wallhaven-download-toast.is-visible { opacity: 1; transform: translateY(0); }
      @keyframes wallhaven-download-pulse { to { filter: brightness(1.6); } }
    `;
    document.head.append(style);
  }
}());
