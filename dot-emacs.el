(add-to-list 'load-path "~/.emacs.d")


; undisplay toolbar or scrollbar
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(tool-bar-mode nil nil (tool-bar)))
(scroll-bar-mode -1)


; configuration for python + emacs + rope:
; http://blog.csdn.net/meteor1113/archive/2009/07/15/4349280.aspx
;; Initial Pymacs
(require 'pymacs)
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
; ;; Initial Rope
; (pymacs-load "ropemacs" "rope-")
; (setq ropemacs-enable-autoimport t)


; color-theme
(require 'color-theme)

(defun color-theme-tty-dark ()
  "Color theme by Oivvio Polite, created 2002-02-01.  Good for tty display."
  (interactive)
  (color-theme-install
   '(color-theme-tty-dark
     ((background-color . "black")
      (background-mode . dark)
      (border-color . "blue")
      (cursor-color . "red")
      (foreground-color . "white")
      (mouse-color . "black"))
     ((ispell-highlight-face . highlight)
      (list-matching-lines-face . bold)
      (tinyreplace-:face . highlight)
      (view-highlight-face . highlight))
     (default ((t (nil))))
     (bold ((t (:underline t :background "black" :foreground "white"))))
     (bold-italic ((t (:underline t :foreground "white"))))
     (calendar-today-face ((t (:underline t))))
     (diary-face ((t (:foreground "red"))))
     (font-lock-builtin-face ((t (:foreground "blue"))))
     (font-lock-comment-face ((t (:foreground "cyan"))))
     (font-lock-constant-face ((t (:foreground "magenta"))))
     (font-lock-function-name-face ((t (:foreground "cyan"))))
     (font-lock-keyword-face ((t (:foreground "red"))))
     (font-lock-string-face ((t (:foreground "green"))))
     (font-lock-type-face ((t (:foreground "yellow"))))
     (font-lock-variable-name-face ((t (:foreground "blue"))))
     (font-lock-warning-face ((t (:bold t :foreground "magenta"))))
     (highlight ((t (:background "blue" :foreground "yellow"))))
     (holiday-face ((t (:background "cyan"))))
     (info-menu-5 ((t (:underline t))))
     (info-node ((t (:italic t :bold t))))
     (info-xref ((t (:bold t))))
     (italic ((t (:underline t :background "red"))))
     (message-cited-text-face ((t (:foreground "red"))))
     (message-header-cc-face ((t (:bold t :foreground "green"))))
     (message-header-name-face ((t (:foreground "green"))))
     (message-header-newsgroups-face ((t (:italic t :bold t :foreground "yellow"))))
     (message-header-other-face ((t (:foreground "#b00000"))))
     (message-header-subject-face ((t (:foreground "green"))))
     (message-header-to-face ((t (:bold t :foreground "green"))))
     (message-header-xheader-face ((t (:foreground "blue"))))
     (message-mml-face ((t (:foreground "green"))))
     (message-separator-face ((t (:foreground "blue"))))

     (modeline ((t (:background "white" :foreground "blue"))))
     (modeline-buffer-id ((t (:background "white" :foreground "red"))))
     (modeline-mousable ((t (:background "white" :foreground "magenta"))))
     (modeline-mousable-minor-mode ((t (:background "white" :foreground "yellow"))))
     (region ((t (:background "white" :foreground "black"))))
     (zmacs-region ((t (:background "cyan" :foreground "black"))))
     (secondary-selection ((t (:background "blue"))))
     (show-paren-match-face ((t (:background "red"))))
     (show-paren-mismatch-face ((t (:background "magenta" :foreground "white"))))
     (underline ((t (:underline t)))))))

(color-theme-tty-dark)


; M-x shell to use color
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


; use clipboard with other X app
(setq x-select-enable-clipboard t)


; python config
(setq py-block-comment-prefix "# ")
(setq py-python-command "python")


; display linum
(require 'linum)
(global-linum-mode 1)


; display column number
(column-number-mode t)


; Loading a Desktop Saved from a Previous Session at Startup
; http://www.emacswiki.org/cgi-bin/wiki/DeskTop
; (desktop-save-mode 1)
; (setq history-length 250)
; (add-to-list 'desktop-globals-to-save 'file-name-history)
; (setq desktop-buffers-not-to-save
;       (concat "\\("
;               "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
;               "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
;               "\\)$"))
; (add-to-list 'desktop-modes-not-to-save 'dired-mode)
; (add-to-list 'desktop-modes-not-to-save 'Info-mode)
; (add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
; (add-to-list 'desktop-modes-not-to-save 'fundamental-mode)


; use ibuffer to handle c-x c-b
(require 'ibuffer)
(global-set-key (kbd "C-x C-b") 'ibuffer)


; use C-c t to mark
(global-set-key (kbd "C-c t") 'set-mark-command)


; use emacsclient.exe
(server-start)


; set gui fonts
(load "fontset-win")
; (huangq-fontset-consolas)
