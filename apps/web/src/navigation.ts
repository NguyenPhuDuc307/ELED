// One history stack for native browser gestures and in-app back buttons.
const currentPath = () => location.hash.slice(1) || "/";
function depth() { return Number.isInteger(history.state?.eledDepth) ? history.state.eledDepth : 0; }
if (!Number.isInteger(history.state?.eledDepth)) history.replaceState({ ...history.state, eledDepth: 0 }, "");
export function navigate(path: string, data: Record<string, unknown> = {}, replace = false) {
  if (path === currentPath() && !replace) return;
  const state = { eledDepth: depth() + (replace ? 0 : 1), ...data };
  if (replace) history.replaceState(state, "", "#" + path);
  else history.pushState(state, "", "#" + path);
  window.dispatchEvent(new PopStateEvent("popstate", { state }));
  window.scrollTo({ top: 0 });
}
export function navigateBack(fallback = "/") {
  if (depth() > 0) history.back();
  else navigate(fallback, {}, true);
}
