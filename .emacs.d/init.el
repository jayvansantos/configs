(add-to-list 'load-path "~/.emacs.d")
(setq byte-compile-warnings nil)
(byte-recompile-directory "~/.emacs.d")
(byte-recompile-directory "~/.emacs.d" 0)
(setq byte-compile-warnings t)

; load my rxvt.el
(unless (or noninteractive window-system)
    (if (string-match "^rxvt.*" (getenv "TERM"))
        (progn
            (setq term-file-prefix nil)
            (require 'rxvt)
            (terminal-init-rxvt))))

; various
(defvar my-minor-mode-map (make-keymap) "my-minor-mode keymap.")
(menu-bar-mode -1)
(tool-bar-mode -1)
(if window-system
  (toggle-scroll-bar nil))
(require 'my-linum)
(setq linum-disabled-modes-list '(eshell-mode apropos-mode compilation-mode
                                fundamental-mode term-mode etags-select-mode
                                completion-list-mode help-mode dired-mode
                                desktop-menu-mode Buffer-menu-mode Man-mode Custom-mode))
(global-linum-mode 1)
(column-number-mode 1)
(global-auto-revert-mode 1)
(show-paren-mode 1)
(icomplete-mode 99)
(iswitchb-mode 1)
(setq iswitchb-default-method 'samewindow)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-buffer-menu t)
(setq initial-scratch-message nil)
(setq message-log-max nil)
(kill-buffer "*Messages*")
(kill-buffer "*Compile-Log*")
(setq Man-width 90)
(setq-default show-trailing-whitespace t)
(defalias 'yes-or-no-p 'y-or-n-p)
(require 'htmlize)
(require 'highlight-parentheses)
(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)
(require 'arduino-mode)

; backup/autosave
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(make-directory backup-dir t)
(setq backup-directory-alist `((".*" . ,backup-dir)))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(make-directory autosave-dir t)
(setq auto-save-list-file-prefix (concat autosave-dir ".auto-saves-"))
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

; session manager
(require 'desktop-menu)
(setq desktop-menu-base-filename (convert-standard-filename "session"))
(setq desktop-menu-list-file (convert-standard-filename "sessions"))
(defvar sessions-dir (expand-file-name "~/.emacs.d/sessions/"))
(make-directory sessions-dir t)
(setq desktop-menu-directory sessions-dir)

; add repositories in emacs' package manager
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

; RFC
; you can download RFCs from http://www.rfc-editor.org/download.html
(require 'rfc)
(setq rfc-archive-alist (list (file-truename "~/rfc")))

; coding
(setq c-default-style "linux")
(setq c-backspace-function 'backward-delete-char)

; tags
(require 'etags-select)
(global-set-key "\M-?" 'etags-select-find-tag-at-point)
(global-set-key "\M-." 'etags-select-find-tag)

; Tabbing support options
(require 'tabbar)
(tabbar-mode 1)
(setq tabbar-separator (quote (" ")))
(setq tabbar-use-images nil)

; fonts
(if window-system
    (setq default-frame-alist '((font . "Source Code Pro-9"))))

; theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'behelit t)

; cups pdf printer
(setq ps-printer-name "Virtual_PDF_Printer")
(setq ps-printer-name-option "-P")
(setq ps-lpr-command "/usr/bin/lpr")
(setq ps-paper-type 'a4)
(setq ps-font-size 8.5)
(setq ps-left-margin 60)
(setq ps-right-margin 40)
(setq ps-top-margin 70)
(setq ps-bottom-margin 70)
(setq ps-print-header nil)

; functions
(require 'ps-print)
(defun print-code (&optional filename)
  (interactive (list (ps-print-preprint current-prefix-arg)))
  (let ((old-ps-line-number ps-line-number)
        (old-ps-line-number-font ps-line-number-font)
        (old-ps-line-number-font-size ps-line-number-font-size)
        (old-ps-font-family ps-font-family)
        (old-highlight-parentheses-mode highlight-parentheses-mode)
        (old-custom-enabled-themes custom-enabled-themes))
    (setq ps-line-number t)
    (setq ps-font-family 'Courier)
    (setq ps-line-number-font "Courier")
    (setq ps-line-number-font-size ps-font-size)
    (highlight-parentheses-mode -1)
    (let ((list old-custom-enabled-themes)
          x)
      (while list
        (setq x (car list))
        (setq list (cdr list))
        (disable-theme x)))
    (load-theme 'print t)
    (ps-print-buffer-with-faces filename)
    (disable-theme 'print)
    (let ((list (reverse old-custom-enabled-themes))
          x)
      (while list
        (setq x (car list))
        (setq list (cdr list))
        (load-theme x t)))
    (setq ps-line-number old-ps-line-number)
    (setq ps-line-number-font old-ps-line-number-font)
    (setq ps-line-number-font-size old-ps-line-number-font-size)
    (setq ps-font-family old-ps-font-family)
    (highlight-parentheses-mode old-highlight-parentheses-mode)))

(defun other-window-backward (&optional n)
    "Select Nth previous window."
    (interactive "P")
    (other-window (- (prefix-numeric-value n))))

(defun xclip-paste ()
  (interactive)
  (shell-command "xclip -o -selection clipboard" 0 shell-command-default-error-buffer))

(defun xclip-copy ()
  (interactive)
  (if (region-active-p)
    (progn
      (call-process-region (region-beginning) (region-end) "xclip" nil 0 nil "-i" "-selection" "clipboard")
      (message "Copy region to clipboard!")
      (deactivate-mark))
    (message "No region active. Can't copy to clipboard!")))

(defun xclip-cut ()
  (interactive)
  (if (region-active-p)
    (progn
      (call-process-region (region-beginning) (region-end) "xclip" t 0 nil "-i" "-selection" "clipboard")
      (message "Cut region to clipboard!"))
    (message "No region active. Can't cut to clipboard!")))

(defun desktop-save-man ()
  (insert "\n;; Man section\n")
  (let* ((list (buffer-list))
	 (buffer (car list))
	 val)
    (while buffer
      (if (with-current-buffer buffer (boundp 'Man-arguments))
	  (progn
	    (with-current-buffer buffer (setq val Man-arguments))
	    (if val
		(progn
		  (insert "(man \"")
		  (insert val)
		  (insert "\")\n")))))
      (setq buffer (car list))
      (setq list (cdr list)))))

(defun desktop-save-rfc ()
  (insert "\n;; RFC section\n")
  (let* ((list (buffer-list))
	 (buffer (car list))
	 val)
    (while buffer
      (if (with-current-buffer buffer (boundp 'rfc-article-number))
	  (progn
	    (with-current-buffer buffer (setq val rfc-article-number))
	    (if (> val 0)
		(progn
		  (insert "(rfc-goto-number ")
		  (insert (number-to-string val))
		  (insert ")\n")))))
      (setq buffer (car list))
      (setq list (cdr list)))))

(defun shifttext-tab-right (tabs)
  (interactive "P")
  (unless tabs
      (setq tabs 1))
  (let (begin end)
    (if (mark)
	(setq begin (region-beginning)
	      end (region-end))
      (setq begin (line-beginning-position)
	     end (line-end-position)))
      (save-excursion
	(indent-rigidly begin end (* tab-width tabs))
	(setq deactivate-mark nil))))

(defun shifttext-tab-left (tabs)
  (interactive "P")
  (unless tabs
    (setq tabs 1))
  (shifttext-tab-right (- tabs)))

(defun clear-tags-path ()
  (interactive)
  (setq tags-file-name nil)
  (setq tags-table-list nil))

(defun show-file-path ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun enable-spaces ()
  "Use spaces instead of tabs"
  (interactive)
  (setq tab-width 4)
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil)
  (message "You can retab the whole buffer by pressing C-x h C-M-\\"))

(defun enable-tabs ()
  "Use tabs instead of spaces"
  (interactive)
  (setq tab-width 8)
  (setq c-basic-offset 8)
  (setq indent-tabs-mode t)
  (message "You can retab the whole buffer by pressing C-x h C-M-\\"))

; hooks for ARM assembly
(defun arm-asm-mode-set-comment-hook ()
  (when (string-match ".S$" (buffer-file-name))
    ;; asm files ending in .S are usually arm assembler
    (setq asm-comment-char ?@)))

(defun arm-asm-mode-hook ()
  ;; asm files ending in .S are usually arm assembler
  (when (string-match ".S$" (buffer-file-name))
    ;; Get the newlines right
    ;; `newline-and-indent' calls `indent-line-function'
    (set (make-local-variable 'indent-line-function) 'indent-relative)
    (define-key asm-mode-map "\C-m" 'newline-and-indent)
    ;; Get the comments right
    (setq comment-column 30)))

; hooks
(add-hook 'desktop-save-hook 'desktop-save-man)
(add-hook 'desktop-save-hook 'desktop-save-rfc)
(add-hook 'asm-mode-set-comment-hook 'arm-asm-mode-set-comment-hook)
(add-hook 'asm-mode-hook 'arm-asm-mode-hook)

; key bindings
(global-set-key (kbd "RET") 'newline-and-indent) ; auto-indent
(global-set-key (kbd "C-k") 'kill-whole-line)
(global-set-key (kbd "M->") 'shifttext-tab-right)
(global-set-key (kbd "M-<") 'shifttext-tab-left)
(global-set-key (kbd "C-c p") 'show-file-path)
(global-set-key (kbd "C-x p") 'other-window-backward)
(global-set-key (kbd "C-c b") 'browse-url-firefox)
(define-key my-minor-mode-map (kbd "<clearline>") (key-binding (kbd "<C-end>"))) ; <clearline> (in terminal) == <C-end>
(define-key my-minor-mode-map (kbd "M-l") 'tabbar-forward)
(define-key my-minor-mode-map (kbd "M-j") 'tabbar-backward)
(define-key my-minor-mode-map (kbd "ESC <up>") 'windmove-up) ; M-up in terminal
(define-key my-minor-mode-map (kbd "ESC <down>") 'windmove-down) ; M-down in terminal
(define-key my-minor-mode-map (kbd "ESC <right>") 'windmove-right) ; M-right in terminal
(define-key my-minor-mode-map (kbd "ESC <left>") 'windmove-left) ; M-left in terminal
(define-key my-minor-mode-map (kbd "<M-up>") 'windmove-up) ; M-up in gui
(define-key my-minor-mode-map (kbd "<M-down>") 'windmove-down) ; M-down in gui
(define-key my-minor-mode-map (kbd "<M-right>") 'windmove-right) ; M-right in gui
(define-key my-minor-mode-map (kbd "<M-left>") 'windmove-left) ; M-left in gui
(define-key my-minor-mode-map (kbd "C-c s") 'desktop-menu)
(define-key my-minor-mode-map (kbd "C-c v") 'xclip-paste)
(define-key my-minor-mode-map (kbd "C-c c") 'xclip-copy)
(define-key my-minor-mode-map (kbd "C-c x") 'xclip-cut)
(define-key my-minor-mode-map (kbd "C-c m") 'man)
(define-key my-minor-mode-map (kbd "C-c r") 'rfc-index)

(define-minor-mode my-minor-mode
    "A minor mode so that my key settings aren't shadowed by other major/minor modes"
    t "" 'my-minor-mode-map)
