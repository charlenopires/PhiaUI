/**
 * PhiaVideoPlayer — Custom video player hook.
 *
 * Manages play/pause, progress seeking, volume toggle, fullscreen,
 * and time display. Follows the PhiaAudioPlayer pattern.
 *
 * HTML anatomy expected:
 *   <div phx-hook="PhiaVideoPlayer" data-autoplay="..." data-muted="...">
 *     <video data-video ...>
 *       <source src="..." type="..." />
 *     </video>
 *     <button data-play-overlay .../>
 *     <button data-play-btn ...>
 *       <svg data-icon-play .../>
 *       <svg data-icon-pause class="hidden" .../>
 *     </button>
 *     <span data-time>0:00</span>
 *     <div data-progress-bar>
 *       <div data-progress-fill style="width: 0%" />
 *     </div>
 *     <span data-duration>0:00</span>
 *     <button data-mute-btn ...>
 *       <svg data-icon-volume .../>
 *       <svg data-icon-muted class="hidden" .../>
 *     </button>
 *     <button data-fullscreen-btn .../>
 *   </div>
 */
const PhiaVideoPlayer = {
  mounted() {
    this.video = this.el.querySelector("[data-video]");
    this.playOverlay = this.el.querySelector("[data-play-overlay]");
    this.playBtn = this.el.querySelector("[data-play-btn]");
    this.iconPlay = this.el.querySelector("[data-icon-play]");
    this.iconPause = this.el.querySelector("[data-icon-pause]");
    this.timeEl = this.el.querySelector("[data-time]");
    this.durationEl = this.el.querySelector("[data-duration]");
    this.progressBar = this.el.querySelector("[data-progress-bar]");
    this.progressFill = this.el.querySelector("[data-progress-fill]");
    this.muteBtn = this.el.querySelector("[data-mute-btn]");
    this.iconVolume = this.el.querySelector("[data-icon-volume]");
    this.iconMuted = this.el.querySelector("[data-icon-muted]");
    this.fullscreenBtn = this.el.querySelector("[data-fullscreen-btn]");

    if (!this.video) return;

    const autoplay = this.el.dataset.autoplay === "true";
    const muted = this.el.dataset.muted === "true";

    if (muted) this.video.muted = true;

    // Play overlay click
    if (this.playOverlay) {
      this.playOverlay.addEventListener("click", () => this.togglePlay());
    }

    // Play/pause button
    if (this.playBtn) {
      this.playBtn.addEventListener("click", () => this.togglePlay());
    }

    // Time update
    this._onTimeUpdate = () => {
      if (this.timeEl) this.timeEl.textContent = this.formatTime(this.video.currentTime);
      if (this.progressFill && this.video.duration) {
        const pct = (this.video.currentTime / this.video.duration) * 100;
        this.progressFill.style.width = pct + "%";
      }
    };
    this.video.addEventListener("timeupdate", this._onTimeUpdate);

    // Duration loaded
    this._onLoadedMetadata = () => {
      if (this.durationEl) this.durationEl.textContent = this.formatTime(this.video.duration);
    };
    this.video.addEventListener("loadedmetadata", this._onLoadedMetadata);

    // Progress bar seeking
    if (this.progressBar) {
      this.progressBar.addEventListener("click", (e) => {
        const rect = this.progressBar.getBoundingClientRect();
        const pct = (e.clientX - rect.left) / rect.width;
        this.video.currentTime = pct * this.video.duration;
      });
    }

    // Mute toggle
    if (this.muteBtn) {
      this.muteBtn.addEventListener("click", () => {
        this.video.muted = !this.video.muted;
        this.updateMuteIcon();
      });
    }

    // Fullscreen
    if (this.fullscreenBtn) {
      this.fullscreenBtn.addEventListener("click", () => {
        if (document.fullscreenElement) {
          document.exitFullscreen();
        } else {
          this.el.requestFullscreen();
        }
      });
    }

    // Play state classes
    this._onPlay = () => {
      this.el.classList.add("playing");
      this.updatePlayIcon(true);
    };
    this._onPause = () => {
      this.el.classList.remove("playing");
      this.updatePlayIcon(false);
    };
    this._onEnded = () => {
      this.el.classList.remove("playing");
      this.updatePlayIcon(false);
    };

    this.video.addEventListener("play", this._onPlay);
    this.video.addEventListener("pause", this._onPause);
    this.video.addEventListener("ended", this._onEnded);

    this.updateMuteIcon();

    if (autoplay) {
      this.video.play().catch(() => {});
    }
  },

  togglePlay() {
    if (this.video.paused) {
      this.video.play().catch(() => {});
    } else {
      this.video.pause();
    }
  },

  updatePlayIcon(playing) {
    if (this.iconPlay) this.iconPlay.classList.toggle("hidden", playing);
    if (this.iconPause) this.iconPause.classList.toggle("hidden", !playing);
  },

  updateMuteIcon() {
    if (this.iconVolume) this.iconVolume.classList.toggle("hidden", this.video.muted);
    if (this.iconMuted) this.iconMuted.classList.toggle("hidden", !this.video.muted);
  },

  formatTime(s) {
    if (!s || isNaN(s)) return "0:00";
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return m + ":" + (sec < 10 ? "0" : "") + sec;
  },

  destroyed() {
    if (!this.video) return;
    this.video.pause();
    this.video.removeEventListener("timeupdate", this._onTimeUpdate);
    this.video.removeEventListener("loadedmetadata", this._onLoadedMetadata);
    this.video.removeEventListener("play", this._onPlay);
    this.video.removeEventListener("pause", this._onPause);
    this.video.removeEventListener("ended", this._onEnded);
  }
};

export default PhiaVideoPlayer;
