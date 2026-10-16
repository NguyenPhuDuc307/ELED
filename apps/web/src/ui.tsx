import {
  useEffect,
  useState,
  useSyncExternalStore,
  type ReactNode,
} from "react";
import { X, LoaderCircle, Volume2 } from "lucide-react";
import { getProfile, subscribe } from "./storage";
import type { Word } from "./model";
export function useProfile() {
  return useSyncExternalStore(subscribe, getProfile);
}
export function useText() {
  const p = useProfile();
  return (vi: string, en: string) => (p.settings.language === "en" ? en : vi);
}
export function Button({
  children,
  onClick,
  disabled = false,
  secondary = false,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { secondary?: boolean }) {
  return (
    <button
      {...props}
      className={`btn ${secondary ? "secondary" : ""} ${props.className ?? ""}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
export function IconButton({
  label,
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { label: string }) {
  return (
    <button
      {...props}
      className={`icon-btn ${props.className ?? ""}`}
      aria-label={label}
      title={label}
    >
      {children}
    </button>
  );
}
export function Modal({
  title,
  children,
  onClose,
}: {
  title: string;
  children: ReactNode;
  onClose: () => void;
}) {
  useEffect(() => {
    const previous = document.activeElement as HTMLElement;
    const close = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
      if (e.key === "Tab") {
        const els = [
          ...document.querySelectorAll<HTMLElement>(
            '[role="dialog"] button:not(:disabled),[role="dialog"] input,[role="dialog"] textarea,[role="dialog"] select',
          ),
        ];
        const first = els[0],
          last = els.at(-1);
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last?.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first?.focus();
        }
      }
    };
    document.addEventListener("keydown", close);
    document.querySelector<HTMLElement>('[role="dialog"] button')?.focus();
    const old = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = old;
      document.removeEventListener("keydown", close);
      previous?.focus();
    };
  }, []);
  return (
    <div
      className="modal-overlay"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className="modal"
      >
        <header>
          <h2>{title}</h2>
          <IconButton label="Đóng / Close" onClick={onClose}>
            <X size={20} />
          </IconButton>
        </header>
        {children}
      </section>
    </div>
  );
}
export function Loading() {
  return (
    <div className="loading" role="status">
      <LoaderCircle className="spin" size={26} />
      <span>Đang tải / Loading…</span>
    </div>
  );
}
let audio: HTMLAudioElement | null = null;
export async function speak(text: string, word?: Word) {
  speechSynthesis.cancel();
  audio?.pause();
  if (word?.audio) {
    try {
      audio = new Audio(word.audio);
      await audio.play();
      return;
    } catch {
      /* use the browser voice when remote audio fails */
    }
  }
  const p = getProfile();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = p.settings.accent === "uk" ? "en-GB" : "en-US";
  const voice = speechSynthesis
    .getVoices()
    .find((v) => v.name === p.settings.voice);
  if (voice) utterance.voice = voice;
  speechSynthesis.speak(utterance);
}
export function Sound({ word, text }: { word?: Word; text?: string }) {
  const t = useText();
  return (
    <IconButton
      label={t("Nghe phát âm", "Play pronunciation")}
      onClick={() => speak(text ?? word?.word ?? "", word)}
    >
      <Volume2 size={22} />
    </IconButton>
  );
}
export function Empty({ children }: { children: ReactNode }) {
  return <div className="empty">{children}</div>;
}
export function Badge({ children }: { children: ReactNode }) {
  return <span className="badge">{children}</span>;
}
export function useHash() {
  const [path, setPath] = useState(location.hash.slice(1) || "/");
  useEffect(() => {
    const fn = () => setPath(location.hash.slice(1) || "/");
    window.addEventListener("hashchange", fn);
    return () => window.removeEventListener("hashchange", fn);
  }, []);
  return path;
}
export function go(path: string) {
  location.hash = path;
  window.scrollTo({ top: 0 });
}
