// ==UserScript==
// @name         Send NZBs to SABnzbd
// @namespace    https://github.com/cbrst/config
// @version      1.2.3
// @description  Intercept NZB downloads and send them directly to SABnzbd.
// @author       cbrst
// @match        *://*/*
// @run-at       document-start
// @grant        GM.xmlHttpRequest
// @grant        GM.getValue
// @grant        GM.setValue
// @grant        GM.registerMenuCommand
// @grant        GM_xmlhttpRequest
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_registerMenuCommand
// @connect      *
// ==/UserScript==

(function () {
  "use strict";

  const SCRIPT_NAME = "Send NZBs to SABnzbd";
  const CONFIG_KEYS = {
    sabUrl: "send-nzb-to-sabnzbd.url",
    apiKey: "send-nzb-to-sabnzbd.apiKey",
  };
  const DEFAULT_SAB_URL = "http://localhost:8080";
  const NOTIFICATION_MS = 4000;
  const STYLE_ID = "send-nzb-to-sabnzbd-style";
  const MENU_ID = "send-nzb-to-sabnzbd-menu";
  const MENU_BUTTON_ID = "send-nzb-to-sabnzbd-menu-button";
  const MENU_POPOVER_ID = "send-nzb-to-sabnzbd-menu-popover";
  let pageScanQueued = false;
  let pageMenuDismissed = false;

  // Normalize Userscripts, Tampermonkey, and bare-browser APIs behind one shape.
  const gm = {
    request: typeof GM !== "undefined" && GM.xmlHttpRequest
      ? GM.xmlHttpRequest.bind(GM)
      : typeof GM_xmlhttpRequest === "function"
        ? GM_xmlhttpRequest
        : null,
    getValue: async (key, fallback) => {
      if (typeof GM !== "undefined" && GM.getValue) return GM.getValue(key, fallback);
      if (typeof GM_getValue === "function") return GM_getValue(key, fallback);

      const value = localStorage.getItem(key);
      return value == null ? fallback : value;
    },
    setValue: async (key, value) => {
      if (typeof GM !== "undefined" && GM.setValue) return GM.setValue(key, value);
      if (typeof GM_setValue === "function") return GM_setValue(key, value);

      localStorage.setItem(key, value);
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

  gm.registerMenuCommand("Configure SABnzbd NZB catcher", () => {
    void configure();
  });

  // Capture candidate NZB clicks early so sites do not start their own download first.
  document.addEventListener("click", (event) => {
    if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey) {
      return;
    }

    const anchor = event.target instanceof Element ? event.target.closest("a[href]") : null;
    if (!anchor || !looksLikeNzbLink(anchor)) return;

    if (event.altKey && event.shiftKey) {
      event.preventDefault();
      event.stopPropagation();
      void configure();
      return;
    }

    if (event.altKey || event.shiftKey) {
      notify("Bypassed SABnzbd catcher for this download.", "info");
      return;
    }

    event.preventDefault();
    event.stopPropagation();
    void sendNzbFromLink(anchor);
  }, true);

  // Safari/macOS may compose Option+Shift+N into "˜", so use physical key code.
  document.addEventListener("keydown", (event) => {
    if (event.defaultPrevented || !event.altKey || !event.shiftKey || event.code !== "KeyN") {
      return;
    }

    event.preventDefault();
    void configure();
  }, true);

  document.addEventListener("click", (event) => {
    const menu = document.getElementById(MENU_ID);
    if (!menu || event.target instanceof Node && menu.contains(event.target)) return;

    closeConfigMenu();
  }, true);

  detectRelevantPages();

  async function sendNzbFromLink(anchor) {
    const href = anchor.href;
    const config = await getConfig();

    if (!config.apiKey) {
      notify("SABnzbd API key is not configured yet.", "error");
      await configure(config);
      return;
    }

    try {
      notify("Sending NZB to SABnzbd...", "info");
      const nzb = await downloadNzb(href);
      await uploadToSabnzbd(config, nzb);
      notify("NZB sent to SABnzbd.", "success");
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error(`[${SCRIPT_NAME}]`, error);
      notify(`Could not send NZB: ${message}`, "error");
    }
  }

  function looksLikeNzbLink(anchor) {
    const values = [
      anchor.href,
      anchor.getAttribute("download") || "",
      anchor.textContent || "",
    ];

    if (isNzbfinderDownloadUrl(anchor.href)) return true;

    return values.some((value) => /\.nzb(?:[?#].*)?$/i.test(value.trim()))
      || /\.nzb(?:[?#/&=]|$)/i.test(anchor.href)
      || /(?:download|dl|nzb)/i.test(anchor.className || "")
        && /nzb/i.test(anchor.textContent || "");
  }

  // NZBFinder exposes downloads as /getnzb?id=... instead of .nzb URLs.
  function isNzbfinderDownloadUrl(href) {
    try {
      const url = new URL(href, location.href);
      return /(^|\.)nzbfinder\.ws$/i.test(url.hostname)
        && url.pathname.replace(/\/+$/, "") === "/getnzb"
        && url.searchParams.has("id");
    } catch (_error) {
      return false;
    }
  }

  async function getConfig() {
    const sabUrl = normalizeSabUrl(await gm.getValue(CONFIG_KEYS.sabUrl, DEFAULT_SAB_URL));
    const apiKey = String(await gm.getValue(CONFIG_KEYS.apiKey, "") || "").trim();
    return { sabUrl, apiKey };
  }

  async function configure(existingConfig) {
    const current = existingConfig || await getConfig();
    const sabUrlInput = prompt("SABnzbd URL", current.sabUrl);
    if (sabUrlInput == null) return;

    const apiKeyInput = prompt("SABnzbd API key", current.apiKey);
    if (apiKeyInput == null) return;

    const sabUrl = normalizeSabUrl(sabUrlInput || DEFAULT_SAB_URL);
    const apiKey = apiKeyInput.trim();
    await gm.setValue(CONFIG_KEYS.sabUrl, sabUrl);
    await gm.setValue(CONFIG_KEYS.apiKey, apiKey);
    notify("SABnzbd settings saved.", "success");
  }

  function normalizeSabUrl(url) {
    return String(url || DEFAULT_SAB_URL).trim().replace(/\/+$/, "");
  }

  async function downloadNzb(url) {
    // Same-origin fetch preserves the page's active login session more reliably.
    if (isSameOriginUrl(url)) {
      return downloadNzbWithFetch(url);
    }

    // Cross-origin downloads need userscript XHR to avoid normal page CORS limits.
    if (gm.request) {
      return downloadNzbWithGmRequest(url);
    }

    return downloadNzbWithFetch(url);
  }

  async function downloadNzbWithFetch(url) {
    const response = await fetch(url, { credentials: "include" });
    if (!response.ok) throw new Error(`download returned HTTP ${response.status}`);

    const blob = await response.blob();
    await validateNzbBlob(blob, response.headers.get("content-type") || "");

    return {
      blob,
      filename: filenameFromDownload(url, response.url, response.headers.get("content-disposition") || ""),
    };
  }

  async function downloadNzbWithGmRequest(url) {
    return gmRequest({
      method: "GET",
      url,
      headers: {
        Accept: "application/x-nzb, application/xml, text/xml, */*",
      },
      responseType: "blob",
      withCredentials: true,
    }).then(async (response) => {
      if (!isOkStatus(response.status)) {
        throw new Error(`download returned HTTP ${response.status}`);
      }

      const blob = response.response instanceof Blob
        ? response.response
        : new Blob([response.response], { type: "application/x-nzb" });

      await validateNzbBlob(blob, response.responseHeaders || "");

      return {
        blob,
        filename: filenameFromDownload(url, response.finalUrl || url, response.responseHeaders || ""),
      };
    });
  }

  function isSameOriginUrl(href) {
    try {
      return new URL(href, location.href).origin === location.origin;
    } catch (_error) {
      return false;
    }
  }

  async function validateNzbBlob(blob, responseMeta) {
    // Avoid sending login/error/challenge HTML to SABnzbd as if it were an NZB.
    const head = await blob.slice(0, 1024).text();
    if (/<nzb(?:\s|>)/i.test(head)) return;

    if (/<(?:!doctype\s+html|html|head|body)(?:\s|>)/i.test(head)) {
      throw new Error("download returned an HTML page instead of an NZB; are you still logged in?");
    }

    if (/login|sign\s*in|csrf|cloudflare/i.test(head)) {
      throw new Error("download returned an auth/challenge page instead of an NZB");
    }

    if (!/xml|nzb/i.test(responseMeta)) {
      throw new Error("download did not look like an NZB file");
    }
  }

  async function uploadToSabnzbd(config, nzb) {
    const endpoint = buildSabApiUrl(config.sabUrl);
    endpoint.searchParams.set("mode", "addfile");
    endpoint.searchParams.set("output", "json");
    endpoint.searchParams.set("apikey", config.apiKey);

    const form = new FormData();
    form.append("nzbfile", nzb.blob, nzb.filename);

    if (gm.request) {
      const response = await gmRequest({
        method: "POST",
        url: endpoint.toString(),
        data: form,
        responseType: "json",
      });

      if (!isOkStatus(response.status)) {
        throw new Error(`SABnzbd returned HTTP ${response.status}`);
      }

      validateSabResponse(parseSabResponse(response));
      return;
    }

    const response = await fetch(endpoint, { method: "POST", body: form });
    if (!response.ok) throw new Error(`SABnzbd returned HTTP ${response.status}`);
    validateSabResponse(await response.json());
  }

  function buildSabApiUrl(sabUrl) {
    const url = new URL(sabUrl);
    const path = url.pathname.replace(/\/+$/, "");

    // Accept root URLs, reverse-proxy base paths, and full /api URLs.
    if (/\/api$/i.test(path)) {
      url.pathname = path;
    } else if (path && path !== "/") {
      url.pathname = `${path}/api`;
    } else {
      url.pathname = "/sabnzbd/api";
    }

    return url;
  }

  function gmRequest(details) {
    return new Promise((resolve, reject) => {
      const request = gm.request({
        ...details,
        onload: resolve,
        onerror: () => reject(new Error("request failed")),
        ontimeout: () => reject(new Error("request timed out")),
        onabort: () => reject(new Error("request aborted")),
      });

      if (request && typeof request.catch === "function") {
        request.then(resolve, reject);
      }
    });
  }

  function validateSabResponse(response) {
    if (!response || typeof response !== "object") return;
    if (response.status === false) {
      throw new Error(response.error || "SABnzbd rejected the NZB");
    }
  }

  function parseSabResponse(response) {
    if (response.response && typeof response.response === "object") {
      return response.response;
    }

    if (typeof response.responseText === "string" && response.responseText.trim()) {
      return JSON.parse(response.responseText);
    }

    return null;
  }

  function isOkStatus(status) {
    return status >= 200 && status < 300;
  }

  function filenameFromDownload(originalUrl, finalUrl, responseMeta) {
    // Indexers often hide the useful release name in Content-Disposition.
    const headerFilename = filenameFromContentDisposition(responseMeta);
    if (headerFilename) return ensureNzbExtension(headerFilename);

    return filenameFromUrl(originalUrl, finalUrl);
  }

  function filenameFromContentDisposition(responseMeta) {
    const header = contentDispositionHeader(responseMeta);
    if (!header) return "";

    const encodedMatch = header.match(/filename\*=([^;]+)/i);
    if (encodedMatch) {
      const value = encodedMatch[1].trim().replace(/^UTF-8''/i, "");
      try {
        return decodeURIComponent(value.replace(/^"|"$/g, ""));
      } catch (_error) {
        return value.replace(/^"|"$/g, "");
      }
    }

    const plainMatch = header.match(/filename=(?:"([^"]+)"|([^;]+))/i);
    return plainMatch ? (plainMatch[1] || plainMatch[2] || "").trim() : "";
  }

  function contentDispositionHeader(responseMeta) {
    if (!responseMeta) return "";
    const meta = String(responseMeta);
    const match = meta.match(/^content-disposition:\s*(.+)$/im);
    return match ? match[1].trim() : meta;
  }

  function filenameFromUrl(originalUrl, finalUrl) {
    const url = new URL(finalUrl || originalUrl, location.href);
    const lastPathPart = decodeURIComponent(url.pathname.split("/").filter(Boolean).pop() || "");
    const fallback = decodeURIComponent(new URL(originalUrl, location.href).pathname.split("/").filter(Boolean).pop() || "");
    const filename = lastPathPart || fallback || "download.nzb";
    return ensureNzbExtension(filename);
  }

  function ensureNzbExtension(filename) {
    return /\.nzb$/i.test(filename) ? filename : `${filename}.nzb`;
  }

  function detectRelevantPages() {
    const start = () => {
      scanPageForNzbLinks();

      // Result lists on indexers are often rendered or updated after page load.
      const observer = new MutationObserver(schedulePageScan);
      observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ["href", "download", "class"],
        childList: true,
        subtree: true,
      });
    };

    if (document.documentElement) {
      start();
    } else {
      document.addEventListener("DOMContentLoaded", start, { once: true });
    }
  }

  function schedulePageScan() {
    if (pageScanQueued) return;

    pageScanQueued = true;
    window.setTimeout(() => {
      pageScanQueued = false;
      scanPageForNzbLinks();
    }, 250);
  }

  function scanPageForNzbLinks() {
    if (pageMenuDismissed) return;

    // Keep the config UI page-sensitive without hard-coding supported sites.
    const hasNzbLinks = Array.from(document.links).some(looksLikeNzbLink);
    if (hasNzbLinks) {
      showConfigMenuButton();
    } else {
      removeConfigMenuButton();
    }
  }

  function showConfigMenuButton() {
    if (document.getElementById(MENU_ID)) return;

    ensureNotificationStyle();

    const menu = document.createElement("div");
    menu.id = MENU_ID;
    menu.innerHTML = `
      <button id="${MENU_BUTTON_ID}" type="button" title="SABnzbd NZB catcher settings" aria-haspopup="menu" aria-expanded="false">NZB</button>
      <div id="${MENU_POPOVER_ID}" role="menu" hidden>
        <button type="button" data-action="configure" role="menuitem">Configure SABnzbd...</button>
        <button type="button" data-action="hide" role="menuitem">Hide on this page</button>
      </div>
    `;

    menu.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();

      const target = event.target;
      if (!(target instanceof HTMLElement)) return;

      if (target.id === MENU_BUTTON_ID) {
        toggleConfigMenu();
      } else if (target.dataset.action === "configure") {
        closeConfigMenu();
        void configure();
      } else if (target.dataset.action === "hide") {
        pageMenuDismissed = true;
        removeConfigMenuButton();
      }
    });

    document.documentElement.appendChild(menu);
    document.documentElement.style.setProperty("--send-nzb-to-sabnzbd-toast-bottom", "64px");
  }

  function removeConfigMenuButton() {
    const menu = document.getElementById(MENU_ID);
    if (menu) menu.remove();
    document.documentElement.style.removeProperty("--send-nzb-to-sabnzbd-toast-bottom");
  }

  function toggleConfigMenu() {
    const button = document.getElementById(MENU_BUTTON_ID);
    const popover = document.getElementById(MENU_POPOVER_ID);
    if (!button || !popover) return;

    const willOpen = popover.hasAttribute("hidden");
    popover.toggleAttribute("hidden", !willOpen);
    button.setAttribute("aria-expanded", String(willOpen));
  }

  function closeConfigMenu() {
    const button = document.getElementById(MENU_BUTTON_ID);
    const popover = document.getElementById(MENU_POPOVER_ID);
    if (!button || !popover) return;

    popover.setAttribute("hidden", "");
    button.setAttribute("aria-expanded", "false");
  }

  function notify(message, kind) {
    const show = () => {
      ensureNotificationStyle();

      const node = document.createElement("div");
      node.className = `send-nzb-to-sabnzbd-toast send-nzb-to-sabnzbd-${kind}`;
      node.textContent = message;
      document.documentElement.appendChild(node);

      window.setTimeout(() => {
        node.remove();
      }, NOTIFICATION_MS);
    };

    if (document.documentElement) {
      show();
    } else {
      document.addEventListener("DOMContentLoaded", show, { once: true });
    }
  }

  function ensureNotificationStyle() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      .send-nzb-to-sabnzbd-toast {
        position: fixed;
        z-index: 2147483647;
        right: 16px;
        bottom: var(--send-nzb-to-sabnzbd-toast-bottom, 16px);
        max-width: min(420px, calc(100vw - 32px));
        padding: 10px 12px;
        border-radius: 6px;
        background: #202124;
        color: #ffffff;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
        font: 13px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      .send-nzb-to-sabnzbd-success { background: #17633a; }
      .send-nzb-to-sabnzbd-error { background: #9f1d27; }
      .send-nzb-to-sabnzbd-info { background: #202124; }
      #send-nzb-to-sabnzbd-menu {
        position: fixed;
        z-index: 2147483646;
        right: 16px;
        bottom: 16px;
        font: 13px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      #send-nzb-to-sabnzbd-menu button {
        appearance: none;
        border: 0;
        margin: 0;
        font: inherit;
        cursor: default;
      }
      #send-nzb-to-sabnzbd-menu-button {
        min-width: 44px;
        height: 34px;
        padding: 0 10px;
        border-radius: 6px;
        background: #202124;
        color: #ffffff;
        box-shadow: 0 6px 18px rgba(0, 0, 0, 0.25);
        font-weight: 700;
      }
      #send-nzb-to-sabnzbd-menu-popover {
        position: absolute;
        right: 0;
        bottom: 42px;
        width: 190px;
        padding: 4px;
        border-radius: 6px;
        background: #ffffff;
        color: #202124;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
      }
      #send-nzb-to-sabnzbd-menu-popover[hidden] {
        display: none;
      }
      #send-nzb-to-sabnzbd-menu-popover button {
        display: block;
        width: 100%;
        padding: 7px 8px;
        border-radius: 4px;
        background: transparent;
        color: inherit;
        text-align: left;
      }
      #send-nzb-to-sabnzbd-menu-popover button:hover,
      #send-nzb-to-sabnzbd-menu-popover button:focus {
        background: #e8f0fe;
        outline: none;
      }
    `;
    document.documentElement.appendChild(style);
  }
})();
