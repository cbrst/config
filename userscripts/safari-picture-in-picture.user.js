// ==UserScript==
// @name         Safari Picture in Picture
// @namespace    https://github.com/cbrst/config
// @version      1.0.0
// @description  Enable Picture in Picture for HTML5 videos, with first-class YouTube controls.
// @author       cbrst
// @match        http://*/*
// @match        https://*/*
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  const SCRIPT_NAME = "Safari Picture in Picture";
  const BUTTON_ID = "safari-pip-button";
  const YOUTUBE_BUTTON_CLASS = "safari-pip-youtube-button";
  const STYLE_ID = "safari-pip-styles";
  const IS_YOUTUBE = /(^|\.)youtube\.com$/i.test(location.hostname);
  let scanQueued = false;

  addStyles();
  prepareVideos();
  addControls();

  // Modern sites, especially YouTube, replace their player during in-page navigation.
  new MutationObserver(queueScan).observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  // Option+P offers a consistent path when a site's controls cover the fallback button.
  document.addEventListener("keydown", (event) => {
    if (event.defaultPrevented || !event.altKey || event.code !== "KeyP") return;

    event.preventDefault();
    void togglePictureInPicture();
  }, true);

  function queueScan() {
    // Coalesce large mutation bursts from video players into one scan per frame.
    if (scanQueued) return;
    scanQueued = true;
    requestAnimationFrame(() => {
      scanQueued = false;
      prepareVideos();
      addControls();
    });
  }

  function prepareVideos() {
    document.querySelectorAll("video").forEach((video) => {
      // Some players disable only the standard API; Safari's presentation API can still work.
      video.disablePictureInPicture = false;
      video.removeAttribute("disablepictureinpicture");
    });
  }

  function addControls() {
    // YouTube's own control strip is the least intrusive place for its PiP action.
    if (IS_YOUTUBE) {
      addYouTubeButton();
      removeFallbackButton();
      return;
    }

    // Avoid duplicate floating controls inside same-origin or userscript-enabled frames.
    if (window.top === window.self) addFallbackButton();
  }

  function addYouTubeButton() {
    document.querySelectorAll(".ytp-right-controls").forEach((controls) => {
      if (controls.querySelector(`.${YOUTUBE_BUTTON_CLASS}`)) return;

      const button = document.createElement("button");
      button.type = "button";
      button.className = `ytp-button ${YOUTUBE_BUTTON_CLASS}`;
      button.title = "Picture in Picture (⌥P)";
      button.setAttribute("aria-label", "Picture in Picture");
      // Construct the icon without innerHTML because YouTube enforces Trusted Types.
      button.append(makePictureInPictureIcon());
      button.addEventListener("click", (event) => {
        // Keep YouTube from treating the click as a player toggle.
        event.preventDefault();
        event.stopPropagation();
        void togglePictureInPicture();
      });

      // Place PiP beside YouTube's other display-mode controls.
      controls.prepend(button);
    });
  }

  function makePictureInPictureIcon() {
    // SVG elements must use their namespace when created through the DOM API.
    const svgNamespace = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(svgNamespace, "svg");
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("aria-hidden", "true");

    // Separate paths draw the player outline and its inset PiP window.
    [
      "M19 7H5v10h5v2H5a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v4h-2V7Z",
      "M12 12h9v7h-9z",
    ].forEach((pathData) => {
      const path = document.createElementNS(svgNamespace, "path");
      path.setAttribute("fill", "currentColor");
      path.setAttribute("d", pathData);
      svg.append(path);
    });

    return svg;
  }

  function addFallbackButton() {
    const hasVideo = document.querySelector("video");
    let button = document.getElementById(BUTTON_ID);

    if (!hasVideo) {
      button?.remove();
      return;
    }
    if (button) return;

    button = document.createElement("button");
    button.id = BUTTON_ID;
    button.type = "button";
    button.title = "Picture in Picture (⌥P)";
    button.setAttribute("aria-label", "Picture in Picture");
    button.textContent = "PiP";
    button.addEventListener("click", () => {
      void togglePictureInPicture();
    });
    document.documentElement.append(button);
  }

  function removeFallbackButton() {
    // YouTube receives an integrated control instead of the generic floating one.
    document.getElementById(BUTTON_ID)?.remove();
  }

  async function togglePictureInPicture() {
    const video = findBestVideo();
    if (!video) {
      reportError("No playable video found.");
      return;
    }

    try {
      // Safari exposes its reliable native presentation-mode API on video elements.
      if (typeof video.webkitSetPresentationMode === "function") {
        const currentMode = video.webkitPresentationMode;
        video.webkitSetPresentationMode(
          currentMode === "picture-in-picture" ? "inline" : "picture-in-picture",
        );
        return;
      }

      // Keep the script useful in browsers implementing the cross-browser standard.
      if (document.pictureInPictureElement) {
        await document.exitPictureInPicture();
      } else if (typeof video.requestPictureInPicture === "function") {
        await video.requestPictureInPicture();
      } else {
        throw new Error("This video does not expose a Picture in Picture API.");
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      reportError(message);
    }
  }

  function findBestVideo() {
    const videos = [...document.querySelectorAll("video")].filter(isUsableVideo);
    if (!videos.length) return null;

    // Prefer the active video, then the largest visible player on pages with previews.
    return videos.sort((left, right) => scoreVideo(right) - scoreVideo(left))[0];
  }

  function isUsableVideo(video) {
    // Safari may accept a player before metadata loads, but not one with no media source.
    return Boolean(video.currentSrc || video.src || video.querySelector("source"));
  }

  function scoreVideo(video) {
    const rect = video.getBoundingClientRect();
    const visibleWidth = Math.max(0, Math.min(rect.right, innerWidth) - Math.max(rect.left, 0));
    const visibleHeight = Math.max(0, Math.min(rect.bottom, innerHeight) - Math.max(rect.top, 0));
    const visibleArea = visibleWidth * visibleHeight;

    // Playback state outweighs size so an active background player remains selectable.
    return (!video.paused && !video.ended ? 1_000_000_000 : 0) + visibleArea;
  }

  function reportError(message) {
    // A small transient notice is clearer than silently failing on protected media.
    console.warn(`[${SCRIPT_NAME}] ${message}`);
    const notice = document.createElement("div");
    notice.className = "safari-pip-notice";
    notice.textContent = `PiP unavailable: ${message}`;
    document.documentElement.append(notice);
    setTimeout(() => notice.remove(), 4000);
  }

  function addStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      #${BUTTON_ID} {
        position: fixed;
        right: 16px;
        bottom: 16px;
        z-index: 2147483647;
        box-sizing: border-box;
        border: 1px solid rgb(255 255 255 / 24%);
        border-radius: 8px;
        padding: 8px 11px;
        color: white;
        background: rgb(24 24 27 / 88%);
        box-shadow: 0 3px 14px rgb(0 0 0 / 30%);
        font: 600 13px/1 -apple-system, BlinkMacSystemFont, sans-serif;
        cursor: pointer;
        -webkit-backdrop-filter: blur(12px);
        backdrop-filter: blur(12px);
      }

      #${BUTTON_ID}:hover {
        background: rgb(45 45 49 / 94%);
      }

      .${YOUTUBE_BUTTON_CLASS} {
        /* YouTube's control row is inline-based, so center this custom icon explicitly. */
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        vertical-align: top;
        padding: 0;
      }

      .${YOUTUBE_BUTTON_CLASS} svg {
        /* Avoid the SVG baseline and margin shifting the icon below adjacent controls. */
        display: block;
        flex: none;
        width: 24px;
        height: 24px;
        margin: 0;
      }

      .safari-pip-notice {
        position: fixed;
        left: 50%;
        bottom: 24px;
        z-index: 2147483647;
        max-width: min(520px, calc(100vw - 32px));
        transform: translateX(-50%);
        border-radius: 8px;
        padding: 10px 14px;
        color: white;
        background: rgb(25 25 28 / 94%);
        box-shadow: 0 4px 18px rgb(0 0 0 / 35%);
        font: 13px/1.35 -apple-system, BlinkMacSystemFont, sans-serif;
      }
    `;
    document.documentElement.append(style);
  }
})();
