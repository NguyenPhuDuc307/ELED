import { useEffect, useRef, useState } from 'react';

const TRIGGER = 64; // px (sau giảm chấn) phải kéo tới mới tải lại
const MAX = 110;
const DAMPING = 0.5;

/** Có phần tử cuộn riêng đang không ở đầu giữa điểm chạm và trang? */
function insideScrolled(el: Element | null) {
  for (let n = el; n && n !== document.body; n = n.parentElement) {
    if (n.scrollTop > 0) {
      const oy = getComputedStyle(n).overflowY;
      if (oy === 'auto' || oy === 'scroll') return true;
    }
  }
  return false;
}

const standalone = () =>
  matchMedia('(display-mode: standalone)').matches || (navigator as Navigator & { standalone?: boolean }).standalone === true;

/**
 * Vuốt xuống ở đầu trang để tải lại — chủ yếu cho iPhone khi app cài ra màn hình
 * chính (PWA không có nút tải lại của Safari).
 * standaloneOnly: trang để overscroll mặc định thì Safari tab đã có sẵn kéo để tải
 * lại; chỉ bật bản này trong PWA để không tải lại hai lần.
 */
export function PullToRefresh({ onRefresh = () => location.reload(), accent = '#0070eb', standaloneOnly = false }: {
  onRefresh?: () => unknown | Promise<unknown>;
  accent?: string;
  standaloneOnly?: boolean;
}) {
  const [pull, setPull] = useState(0);
  const [busy, setBusy] = useState(false);
  const st = useRef<{ x: number; y: number; d: number; active: boolean } | null>(null);
  const busyRef = useRef(false);
  const refresh = useRef(onRefresh);
  refresh.current = onRefresh;

  useEffect(() => {
    if (standaloneOnly && !standalone()) return;
    const start = (e: TouchEvent) => {
      if (busyRef.current || e.touches.length !== 1 || window.scrollY > 0 || insideScrolled(e.target as Element)) return;
      st.current = { x: e.touches[0].clientX, y: e.touches[0].clientY, d: 0, active: false };
    };
    const move = (e: TouchEvent) => {
      const s = st.current;
      if (!s) return;
      const dx = e.touches[0].clientX - s.x;
      const dy = e.touches[0].clientY - s.y;
      // Vuốt ngang (dải cuộn ngang, kéo thả) hoặc đẩy lên thì bỏ.
      if (!s.active && (Math.abs(dx) > Math.abs(dy) || dy < 0)) {
        if (Math.abs(dx) > 8 || dy < -8) st.current = null;
        return;
      }
      if (window.scrollY > 0) {
        st.current = null;
        setPull(0);
        return;
      }
      s.active = dy > 8;
      s.d = Math.min(MAX, Math.max(0, dy * DAMPING));
      setPull(s.d);
    };
    const end = async () => {
      const s = st.current;
      st.current = null;
      setPull(0);
      if (!s || s.d < TRIGGER || busyRef.current) return;
      busyRef.current = true;
      setBusy(true);
      navigator.vibrate?.(10);
      try {
        // Tối thiểu 500ms để luôn thấy đã tải; lỗi không làm kẹt vòng xoay.
        await Promise.all([Promise.resolve(refresh.current()).catch(() => {}), new Promise((r) => setTimeout(r, 500))]);
      } finally {
        busyRef.current = false;
        setBusy(false);
      }
    };
    window.addEventListener('touchstart', start, { passive: true });
    window.addEventListener('touchmove', move, { passive: true });
    window.addEventListener('touchend', end);
    window.addEventListener('touchcancel', end);
    return () => {
      window.removeEventListener('touchstart', start);
      window.removeEventListener('touchmove', move);
      window.removeEventListener('touchend', end);
      window.removeEventListener('touchcancel', end);
    };
  }, [standaloneOnly]);

  const ready = pull >= TRIGGER;
  return (
    <div
      aria-hidden={!busy}
      role="status"
      style={{
        position: 'fixed', top: 'env(safe-area-inset-top)', left: '50%', zIndex: 60, pointerEvents: 'none',
        transform: `translate(-50%, ${busy ? 14 : Math.min(pull, MAX) - 36}px)`,
        opacity: busy || pull > 4 ? 1 : 0,
        transition: pull ? 'none' : 'transform .25s ease, opacity .2s ease',
      }}
    >
      {/* Canvas/CanvasText: màu hệ thống theo color-scheme của trang, hợp cả nền sáng lẫn tối. */}
      <div style={{
        width: 40, height: 40, borderRadius: 999, display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: 'Canvas', color: ready || busy ? accent : 'GrayText', boxShadow: '0 6px 18px rgba(0,0,0,.18)', border: '1px solid rgba(127,127,127,.2)',
      }}>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
          style={busy ? { animation: 'ptr-spin .8s linear infinite' } : { transform: `rotate(${ready ? 180 : (pull / TRIGGER) * 180}deg)`, transition: 'transform .1s' }}>
          {busy ? <path d="M21 12a9 9 0 1 1-6.2-8.56" /> : <><path d="M12 5v14" /><path d="m19 12-7 7-7-7" /></>}
        </svg>
      </div>
      <style>{'@keyframes ptr-spin{to{transform:rotate(360deg)}}'}</style>
    </div>
  );
}
