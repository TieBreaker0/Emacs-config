;; -*- lexical-binding: t; -*-
;; Define a separate file for Emacs-generated custom settings
(setq custom-file (expand-file-name "custom-vars.el" user-emacs-directory))

;; Load it quietly if it exists, so Emacs doesn't crash if the file is empty
(when (file-exists-p custom-file)
  (load custom-file 'noerror))

;; package initilization
(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(keymap-global-set "M-o" 'other-window)
(keymap-global-set "M-;" 'compile)

(setq c-default-style
      '((java-mode . "java")
        (awk-mode . "awk")
        (other . "gnu")))

;; this is for showing file absolute path in title bar 
(setq-default frame-title-format
              '((:eval (if (buffer-file-name)
                           (abbreviate-file-name (buffer-file-name))
                         "%b"))))
(menu-bar-mode -1)
(tool-bar-mode -1)
(tab-bar-mode -1)
(scroll-bar-mode -1)
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq default-frame-alist '((fullscreen . maximized)))
(global-visual-line-mode 1)
(setq-default truncate-lines nil)
(setq-default word-wrap t)


(defun my/advise-find-file-split-right (orig-fun &rest args)
  "Make `find-file` open in a right-hand split if the current buffer is visiting a file."
  (if (and buffer-file-name            ; If current buffer is an actual file
           (not (one-window-p)))       ; AND the window isn't already split
      ;; Standard behavior if already split or blank
      (apply orig-fun args)
    ;; Otherwise, slice down the middle and open on the right
    (let ((new-window (split-window-right)))
      (with-selected-window new-window
        (apply orig-fun args)))))

(advice-add 'find-file :around #'my/advise-find-file-split-right)



(use-package vterm
  :ensure t
  :custom
  (vterm-always-compile-module t)
  (vterm-max-scrollback 10000)
  :bind
  ("C-c t" . vterm)
  :hook
  (vterm-mode . (lambda ()
		  (display-line-numbers-mode -1)
		  (hl-line-mode -1))))


(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-molokai t))

(use-package eglot
  :ensure nil 
  :hook ((c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (js-mode . eglot-ensure)) 
  :config
  ;; Keep Flymake out of Eglot globally
  (add-to-list 'eglot-stay-out-of 'flymake))

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)                 ;; Enable auto-completion globally
  (corfu-auto-delay 0.1)         ;; Popup appears almost instantly
  (corfu-auto-prefix 2)          ;; Triggers after typing 2 characters
  (corfu-quit-no-match 'separator) ;; Aggressive typing won't break the flow
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)     ;; Use TAB to cycle down
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous) ;; Shift-TAB to cycle up
        ([backtab] . corfu-previous)))

;; Allows you to type components of a variable out of order (e.g., "str cpy" matches "strcpy")
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Merges multiple backends (like file paths, keywords, and dicts) into any language
(use-package cape
  :ensure t
  :init
  ;; Add useful backends globally to completion-at-point-functions
  (add-to-list 'completion-at-point-functions #'cape-file)    ;; Complete file paths
  (add-to-list 'completion-at-point-functions #'cape-keyword) ;; Programming language keywords
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)) ;; Words already in open buffers
