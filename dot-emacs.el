; undisplay toolbar or scrollbar
(custom-set-variables
 '(tool-bar-mode nil nil (tool-bar)))
(scroll-bar-mode -1)


;; configuration for python + emacs + rope:
;; http://blog.csdn.net/meteor1113/archive/2009/07/15/4349280.aspx
;;; Initial Pymacs
;(require 'pymacs)
;(autoload 'pymacs-apply "pymacs")
;(autoload 'pymacs-call "pymacs")
;(autoload 'pymacs-eval "pymacs" nil t)
;(autoload 'pymacs-exec "pymacs" nil t)
;(autoload 'pymacs-load "pymacs" nil t)
;;; Initial Rope
;(pymacs-load "ropemacs" "rope-")
;(setq ropemacs-enable-autoimport t)


; color-theme
(require 'color-theme)
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
(global-linum-mode)


; display column number
(column-number-mode t)


; Loading a Desktop Saved from a Previous Session at Startup
; http://www.emacswiki.org/cgi-bin/wiki/DeskTop
(desktop-save-mode 1)
(setq history-length 250)
(add-to-list 'desktop-globals-to-save 'file-name-history)
(setq desktop-buffers-not-to-save
      (concat "\\("
	      "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
	      "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
	      "\\)$"))
(add-to-list 'desktop-modes-not-to-save 'dired-mode)
(add-to-list 'desktop-modes-not-to-save 'Info-mode)
(add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
(add-to-list 'desktop-modes-not-to-save 'fundamental-mode)


; use ibuffer to handle c-x c-b
(require 'ibuffer)
(global-set-key (kbd "C-x C-b") 'ibuffer)


; use C-c t to mark
(global-set-key (kbd "C-c t") 'set-mark-command)