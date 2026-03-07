/**
 * PhiaChart — vanilla JS hook for Apache ECharts integration.
 *
 * The chart container div is rendered server-side with JSON configuration
 * in `data-config` and series data in `data-series`. This hook handles:
 *  - mounted()   — initialises echarts instance (or Chart.js fallback)
 *  - updated()   — syncs chart with fresh data when LiveView patches attrs
 *  - destroyed() — disposes chart instance to prevent memory leaks
 *  - handleEvent("update-chart-{id}") — server-driven data updates via push_event
 *  - phia:theme-changed — reinitialises with dark/light theme
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaChart"`, `id`, `data-config`, `data-series`
 *   - Optional: `data-chart-placeholder` — text shown when no library detected
 *
 * Setup:
 *   import PhiaChart from "./hooks/chart"
 *   let liveSocket = new LiveSocket("/live", Socket, {hooks: {PhiaChart}})
 *
 * Install ECharts:
 *   npm install echarts
 *   import * as echarts from "echarts"
 *   window.echarts = echarts
 */
const PhiaChart = {
  mounted() {
    this._chart = null;
    this._onThemeChanged = this._onThemeChanged.bind(this);
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    window.addEventListener("phia:theme-changed", this._onThemeChanged);

    this._initChart();

    this.handleEvent(`update-chart-${this.el.id}`, ({ series }) => {
      if (!this._chart) return;
      const config = this._parseConfig();
      if (!config) return;
      config.series = series;
      this._chart.setOption(config, { replaceMerge: ["series"] });
    });
  },

  updated() {
    if (!this._chart) {
      this._initChart();
      return;
    }
    const config = this._parseConfig();
    const series = this._parseSeries();
    if (config && series) {
      config.series = series;
      this._chart.setOption(config, { notMerge: true });
    }
  },

  destroyed() {
    window.removeEventListener("phia:theme-changed", this._onThemeChanged);
    if (this._chart) {
      this._chart.dispose();
      this._chart = null;
    }
  },

  _initChart() {
    const isDark = document.documentElement.classList.contains("dark");
    const theme = isDark ? "dark" : null;

    if (window.echarts) {
      this._chart = window.echarts.init(this.el, theme);
      const config = this._parseConfig();
      const series = this._parseSeries();
      if (config && series) {
        config.series = series;
        // Disable animations when user prefers reduced motion
        if (this._reducedMotion) {
          config.animation = false;
        }
        this._chart.setOption(config);
      }
      return;
    }

    if (window.Chart) {
      // Chart.js fallback: create a canvas and mount Chart.js
      const canvas = document.createElement("canvas");
      canvas.style.width = "100%";
      canvas.style.height = "100%";
      this.el.appendChild(canvas);
      const series = this._parseSeries();
      const config = this._parseConfig();
      const labels = config && config.xAxis ? config.xAxis.data : [];
      const datasets = (series || []).map((s) => ({
        label: s.name,
        data: s.data,
      }));
      this._chart = new window.Chart(canvas, {
        type: config && config.series && config.series[0]
          ? config.series[0].type
          : "line",
        data: { labels, datasets },
      });
      return;
    }

    // No chart library found — show placeholder
    const placeholder = this.el.getAttribute("data-chart-placeholder");
    if (placeholder) {
      this.el.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#888;font-size:0.875rem;">${_esc(placeholder)}</div>`;
    }
  },

  _onThemeChanged({ detail }) {
    if (!this._chart || !window.echarts) return;
    const config = this._parseConfig();
    const series = this._parseSeries();
    this._chart.dispose();
    const theme = detail && detail.theme === "dark" ? "dark" : null;
    this._chart = window.echarts.init(this.el, theme);
    if (config && series) {
      config.series = series;
      this._chart.setOption(config);
    }
  },

  _parseConfig() {
    try {
      return JSON.parse(this.el.getAttribute("data-config") || "{}");
    } catch (_) {
      return null;
    }
  },

  _parseSeries() {
    try {
      return JSON.parse(this.el.getAttribute("data-series") || "[]");
    } catch (_) {
      return [];
    }
  },
};

function _esc(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

export default PhiaChart;
