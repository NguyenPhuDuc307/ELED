import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import { initNotifications } from "./notifications";
import "./style.css";
import "./fonts.css";
import "./original.css";
import { PullToRefresh } from "./PullToRefresh";
// Retire the former Flutter cache while retaining every localStorage data key.
if ("serviceWorker" in navigator)
  navigator.serviceWorker
    .getRegistrations()
    .then((registrations) =>
      registrations
        .filter((r) =>
          r.active?.scriptURL.includes("flutter_service_worker.js"),
        )
        .forEach((r) => r.unregister()),
    )
    .catch(() => {});
class AppBoundary extends React.Component<
  { children: React.ReactNode },
  { failed: boolean }
> {
  state = { failed: false };
  static getDerivedStateFromError() {
    return { failed: true };
  }
  render() {
    return this.state.failed ? (
      <div className="initial-loading">
        <h1>English Learning</h1>
        <p>Không tải được trang. Vui lòng thử lại. / Please reload the page.</p>
        <button className="btn" onClick={() => location.reload()}>
          Tải lại / Reload
        </button>
      </div>
    ) : (
      this.props.children
    );
  }
}
createRoot(document.getElementById("root")!).render(
  <AppBoundary>
    <PullToRefresh accent="#b512ce" standaloneOnly />
    <App />
  </AppBoundary>,
);
initNotifications();
