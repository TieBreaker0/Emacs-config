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

(defvar my/dired-opening-file nil
  "Non-nil when `find-file` is being called by Dired.")

(defvar my/dired-jump nil
  "Non-nil while `dired-jump` is running.")

(defun my/advise-dired-find-file (orig-fun &rest args)
  "Mark that `find-file` was called by `dired-find-file`."
  (let ((my/dired-opening-file t))
    (apply orig-fun args)))

(defun my/advise-dired-jump (orig-fun &rest args)
  "Mark that `dired-jump` is running."
  (let ((my/dired-jump t))
    (apply orig-fun args)))

(defun my/advise-find-file-split-right (orig-fun &rest args)
  "Ask whether to split before opening an explicitly selected file."
  (if (and (not my/dired-opening-file)
           (not my/dired-jump)
           (or buffer-file-name
               (derived-mode-p 'dired-mode)))
      (if (y-or-n-p "Split window and open file in new window? ")
          ;; User chooses yes.
          (let ((new-window (split-window-right)))
            (select-window new-window)
            (apply orig-fun args))

        ;; User chooses no.
        (apply orig-fun args))

    ;; Dired opening a file, dired-jump, scratch, etc.
    (apply orig-fun args)))

(advice-add 'dired-find-file :around #'my/advise-dired-find-file)
(advice-add 'dired-jump :around #'my/advise-dired-jump)
(advice-add 'find-file :around #'my/advise-find-file-split-right)


(defun my/delete-window-and-balance (orig-fun &rest args)
  "Delete the current window and rebalance the remaining windows."
  (apply orig-fun args)
  (balance-windows))

(advice-add 'delete-window :around #'my/delete-window-and-balance)

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
  :config
  (add-to-list 'eglot-stay-out-of 'flymake)

  :hook ((c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (json-mode . eglot-ensure)))

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


(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(x pgtk))
    (exec-path-from-shell-initialize)))

(setq-default eglot-workspace-configuration
              `((:typescript-language-server
                 (:tsserver
                  (:fallbackPath
                   ,(expand-file-name
                     "typescript/lib/"
                     (string-trim
                      (shell-command-to-string "npm root -g"))))))))


