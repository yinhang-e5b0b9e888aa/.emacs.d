(defvar dcpl-mode-hook nil)

;; (defface font-lock-hex-integer-face
;;   '((t (:foreground "#0E8B9B")))
;;   "Font Lock mode face used to highlight hex integer value in DCPL."
;;   :group 'font-lock-highlighting-faces)
;; (defvar font-lock-hex-integer-face 'font-lock-hex-integer-face)

(defface font-lock-hex-string-face
  '((t (:foreground "#8513CC")))
  "Font Lock mode face used to highlight hex string value in DCPL."
  :group 'font-lock-highlighting-faces)
(defvar font-lock-hex-string-face 'font-lock-hex-string-face)

(defconst dcpl-font-lock-keywords-1
  '(
    ("\\<\\(#include\\|include\\)\\>[ \t]*\\(.*\\)"
     (1 font-lock-preprocessor-face) (2 font-lock-constant-face nil t))
    ("\\<\\(call\\)\\>[ \t]*\\(.*\\)"
     (1 font-lock-keyword-face) (2 font-lock-function-name-face nil t)))
  "Subdued level highlighting for DCPL mode.")

(defconst dcpl-font-lock-keywords-2
  (append
   dcpl-font-lock-keywords-1
   `(
     ;; Integer Expressions
     ,(concat "\\<"
	      (regexp-opt '("or" "and" "bitor" "bitxor" "bitand" "left"
			    "right" "div" "mod" "not" "bitnot") t)
	      "\\>")
     ;; String Expressions
     ,(concat "\\<"
	      (regexp-opt '("nullif" "nullthen") t)
	      "\\>")
     ;; Statements
     ,(concat "\\<"
	     (regexp-opt '("encode" "locate" "parse" "pattern" "break"
			   "call" "continue" "exp" "switch" "endswitch"
			   "case" "endcase" "other" "exit" "for" "endfor"
			   "if" "else" "endif" "pause" "return" "wait"
			   "while" "endwhile" "comment" "prompt" "add"
			   "display" "protocol" "log" "badfcs" "codec"
			   "on" "off" "forward" "to" "stop" "free"
			   "gwrite" "append" "timestamp" "keyboard"
			   "load" "noglobals" "logpolicy" "logsize"
			   "totalsize" "preprocess" "print" "received"
			   "remove" "send" "screen" "clear" "sprint"
			   "store" "sysmon" "timeslot" "unload" "view"
			   "write" "wsprint" "start_itimer" "stop_itimer"
			   "tag" "index" "units" "phase" "read_itimer"
			   "ajust_itimer" "array" "default" "context"
			   "main" "portspec" "variant" "variable") t)
	     "\\>")
     ("\\(\\w+\\)\\s-*\(" 1 font-lock-function-call-face)
     ("[&%]\\(\\w+\\)" 1 font-lock-variable-name-face)
     ;; highlight-numbers minor mode override this, fix to do
     ;; ("\\(#[a-fA-F0-9]+\\)" 1 font-lock-hex-integer-face)
     ("#\\([a-fA-F0-9]+\\)" 1 font-lock-constant-face)
     ("\$\\([a-fA-F0-9]+\\)" 1 font-lock-hex-string-face)
     ))
  "Gaudy level highlighting for DCPL mode.")

(defvar dcpl-font-lock-keywords dcpl-font-lock-keywords-2
  "Default expressions to highlight in DCPL mode.")

(defun dcpl-current-line-contents ()
  "Current line string without properties."
  (buffer-substring-no-properties (point-at-bol) (point-at-eol)))

(defconst dcpl--include-regexp
  "\\`\\s-*\\(?:#include\\|include\\)\\s-+\\(.*\\)")

(defconst dcpl--call-regexp
  "\\`\\s-*call\\s-+\\(.*\\)")

;; (defun dcpl-find-definition ()
;;   "Find symbol definition."
;;   (interactive)
;;   (let ((line (dcpl-current-line-contents)))
;;     (if (string-match dcpl--call-regexp line)
;;         (let ((helm-gtags-use-input-at-cursor t))
;;           (helm-gtags-find-files (concat "/" (match-string-no-properties 1 line))))
;;       (if (thing-at-point 'symbol)
;;           (helm-gtags-find-tag-from-here)
;;         (call-interactively 'helm-gtags-find-tag)))))

(defun dcpl-find-definition ()
  "Find symbol definition."
  (interactive)
  (let ((line (dcpl-current-line-contents)))
    (if (string-match dcpl--include-regexp line)
	(let ((helm-gtags-use-input-at-cursor t))
	  (helm-gtags-find-files (concat "/" (match-string-no-properties 1 line))))
      (if (string-match dcpl--call-regexp line)
	  (let ((helm-gtags-use-input-at-cursor t))
	    (helm-gtags-find-files (concat "/" (match-string-no-properties 1 line) ".d" )))))))

(defun dcpl-find-references ()
  "Find symbol references."
  (interactive)
  (let ((line (dcpl-current-line-contents)))
    (if (thing-at-point 'symbol)
	(helm-gtags-find-tag-from-here)
      (call-interactively 'helm-gtags-find-tag))))

(defun dcpl-previous-location ()
  "Jump to previous location on context stack."
  (interactive)
  (helm-gtags-previous-history))

(defun dcpl-next-location ()
  "Jump to next location on context stack."
  (interactive)
  (helm-gtags-next-history))

(defvar dcpl-mode-map
  (let ((map (make-keymap)))
    (define-key map (kbd "M-.") 'dcpl-find-definition)
    (define-key map (kbd "M-]") 'dcpl-find-references)
    (define-key map (kbd "M-*") 'dcpl-previous-location)
    (define-key map (kbd "M-(") 'dcpl-next-location)
    map)
  "Keymap for DCPL major mode")

(add-to-list 'auto-mode-alist '("\\.\\(d\\|def\\)\\'" . dcpl-mode))

(defun check_symbol()
  "print current symbol."
  (interactive)
  (message "%s" (thing-at-point 'symbol)))

(defvar dcpl-mode-syntax-table
  (let ((dcpl-mode-syntax-table (make-syntax-table (standard-syntax-table))))
    (modify-syntax-entry ?& "/" dcpl-mode-syntax-table)
    (modify-syntax-entry ?% "/" dcpl-mode-syntax-table)
    (modify-syntax-entry ?= "." dcpl-mode-syntax-table)
    (modify-syntax-entry ?_ "w" dcpl-mode-syntax-table)
    dcpl-mode-syntax-table)
  "Syntax table for dcpl-mode")

(define-derived-mode dcpl-mode c-mode
;; (defun dcpl-mode ()
  "Major mode for editing Digital Communications Programming Language (DCPL)"
;;  (interactive)
;;  (kill-all-local-variables)
  (use-local-map dcpl-mode-map)
  (set-syntax-table dcpl-mode-syntax-table)
  (setq font-lock-defaults '(dcpl-font-lock-keywords))
  (setq major-mode 'dcpl-mode)
  (setq mode-name "DCPL")
  (run-hooks 'dcpl-mode-hook))

(provide 'dcpl-mode)