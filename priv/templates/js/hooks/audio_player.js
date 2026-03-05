/**
 * PhiaAudioPlayer — vanilla JS hook for audio playback.
 *
 * Reads the audio URL from `data-src` and manages play/pause state,
 * progress bar updates, and timestamp display.
 *
 * HTML anatomy expected:
 *   <div phx-hook="PhiaAudioPlayer" data-src="..." data-duration="..." data-autoplay="...">
 *     <button data-play-btn aria-label="Play">
 *       <svg data-icon-play ...>...</svg>
 *       <svg data-icon-pause class="hidden" ...>...</svg>
 *     </button>
 *     <div data-track ...>
 *       <div data-progress style="width: 0%" .../>
 *     </div>
 *     <span data-timestamp>0:00</span>
 *     <span data-duration-display>...</span>
 *     <audio data-audio src="..." .../>
 *   </div>
 */
const PhiaAudioPlayer = {
  mounted() {
    this.audio = this.el.querySelector('[data-audio]');
    this.playBtn = this.el.querySelector('[data-play-btn]');
    this.playIcon = this.el.querySelector('[data-icon-play]');
    this.pauseIcon = this.el.querySelector('[data-icon-pause]');
    this.progress = this.el.querySelector('[data-progress]');
    this.track = this.el.querySelector('[data-track]');
    this.timestamp = this.el.querySelector('[data-timestamp]');
    this.durationDisplay = this.el.querySelector('[data-duration-display]');

    if (!this.audio) return;

    // Set src from data-src if not already set
    const src = this.el.dataset.src;
    if (src && !this.audio.src) {
      this.audio.src = src;
    }

    this._onTimeUpdate = () => this.updateProgress();
    this._onEnded = () => this.reset();
    this._onLoadedMetadata = () => this.updateDurationDisplay();

    this.audio.addEventListener('timeupdate', this._onTimeUpdate);
    this.audio.addEventListener('ended', this._onEnded);
    this.audio.addEventListener('loadedmetadata', this._onLoadedMetadata);

    this.playBtn && this.playBtn.addEventListener('click', () => this.togglePlay());
    this.track && this.track.addEventListener('click', (e) => this.seek(e));

    if (this.el.dataset.autoplay === 'true') {
      this.audio.play().catch(() => {});
    }
  },

  togglePlay() {
    if (!this.audio) return;
    if (this.audio.paused) {
      this.audio.play();
      this.setPlaying(true);
    } else {
      this.audio.pause();
      this.setPlaying(false);
    }
  },

  setPlaying(playing) {
    if (this.playBtn) {
      this.playBtn.setAttribute('aria-label', playing ? 'Pause' : 'Play');
    }
    if (this.playIcon) this.playIcon.classList.toggle('hidden', playing);
    if (this.pauseIcon) this.pauseIcon.classList.toggle('hidden', !playing);
  },

  updateProgress() {
    if (!this.audio) return;
    const { currentTime, duration } = this.audio;
    if (duration > 0) {
      const pct = (currentTime / duration) * 100;
      if (this.progress) this.progress.style.width = `${pct}%`;
    }
    if (this.timestamp) {
      this.timestamp.textContent = this.formatTime(currentTime);
    }
  },

  updateDurationDisplay() {
    if (!this.audio || !this.durationDisplay) return;
    const dur = this.audio.duration;
    if (isFinite(dur)) {
      this.durationDisplay.textContent = this.formatTime(dur);
    }
  },

  seek(event) {
    if (!this.audio || !this.track) return;
    const rect = this.track.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const pct = Math.max(0, Math.min(1, x / rect.width));
    this.audio.currentTime = pct * (this.audio.duration || 0);
  },

  reset() {
    this.setPlaying(false);
    if (this.progress) this.progress.style.width = '0%';
    if (this.timestamp) this.timestamp.textContent = '0:00';
  },

  formatTime(seconds) {
    if (!isFinite(seconds) || seconds < 0) return '0:00';
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}:${s.toString().padStart(2, '0')}`;
  },

  destroyed() {
    if (!this.audio) return;
    this.audio.pause();
    this.audio.removeEventListener('timeupdate', this._onTimeUpdate);
    this.audio.removeEventListener('ended', this._onEnded);
    this.audio.removeEventListener('loadedmetadata', this._onLoadedMetadata);
  }
};

export default PhiaAudioPlayer;
