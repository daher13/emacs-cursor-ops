;;; cursor-ops.el --- Custom cursor movement and deletion operations -*- lexical-binding: t; -*-

;; Author: Guilherme Daher
;; Version: 0.2
;; Package-Requires: ((emacs "24.4"))
;; Keywords: editing, navigation
;; URL: https://github.com/daher13/emacs-cursor-ops

;;; Commentary:
;;
;; This package provides custom cursor movement and deletion operations,
;; treating alphanumeric sequences, spaces, and special characters as
;; distinct "units". It introduces movement and deletion commands that
;; operate on these units, and provides a minor mode to enable keybindings.
;;
;; Unlike `forward-word`/`backward-word`, this approach separates
;; alphanumeric, whitespace, and punctuation sequences.
;;
;; Usage:
;;   (cursor-ops-mode 1)

;;; Code:

(defun cursor-ops--alnum-p (ch)
  "Return non-nil if character CH is alphanumeric."
  (and ch (string-match-p "[[:alnum:]]" (string ch))))

(defun cursor-ops--special-char-p (ch)
  "Return non-nil if character CH is a non-space, non-alphanumeric char."
  (and ch (string-match-p "[^[:alnum:][:space:]]" (string ch))))

(defun cursor-ops--space-p (ch)
  "Return non-nil if character CH is whitespace."
  (and ch (string-match-p "[[:space:]]" (string ch))))

(defun cursor-ops--operation (check-limit-fn get-char-fn get-char2-fn op-fn)
  "Generic cursor operation dispatcher.

CHECK-LIMIT-FN is called to test line limits.
GET-CHAR-FN returns the current char at point (or before).
GET-CHAR2-FN returns the next char in direction of motion.
OP-FN performs the actual operation (move/delete)."
  (cond
   ((funcall check-limit-fn)
    (funcall op-fn))
   ((and (or (cursor-ops--special-char-p (funcall get-char-fn))
             (cursor-ops--space-p (funcall get-char-fn)))
         (cursor-ops--alnum-p (funcall get-char2-fn)))
    (funcall op-fn)
    (while (and (cursor-ops--alnum-p (funcall get-char-fn))
                (not (funcall check-limit-fn)))
      (funcall op-fn)))
   ((and (or (cursor-ops--alnum-p (funcall get-char-fn))
             (cursor-ops--space-p (funcall get-char-fn)))
         (cursor-ops--special-char-p (funcall get-char2-fn)))
    (funcall op-fn)
    (while (and (cursor-ops--special-char-p (funcall get-char-fn))
                (not (funcall check-limit-fn)))
      (funcall op-fn)))
   ((cursor-ops--special-char-p (funcall get-char-fn))
    (while (and (cursor-ops--special-char-p (funcall get-char-fn))
                (not (funcall check-limit-fn)))
      (funcall op-fn)))
   ((cursor-ops--alnum-p (funcall get-char-fn))
    (while (and (cursor-ops--alnum-p (funcall get-char-fn))
                (not (funcall check-limit-fn)))
      (funcall op-fn)))
   ((cursor-ops--space-p (funcall get-char-fn))
    (while (and (cursor-ops--space-p (funcall get-char-fn))
                (not (funcall check-limit-fn)))
      (funcall op-fn)))))

;;;###autoload
(defun cursor-ops-backward-unit (&optional arg)
  "Move backward by custom unit ARG times."
  (interactive "^p")
  (dotimes (_ (or arg 1))
    (cursor-ops--operation
     #'bolp
     #'char-before
     (lambda () (char-before (1- (point))))
     (lambda () (backward-char)))))

;;;###autoload
(defun cursor-ops-forward-unit (&optional arg)
  "Move forward by custom unit ARG times."
  (interactive "^p")
  (dotimes (_ (or arg 1))
    (cursor-ops--operation
     #'eolp
     #'char-after
     (lambda () (char-after (1+ (point))))
     (lambda () (forward-char)))))

;;;###autoload
(defun cursor-ops-backward-delete-unit (&optional arg)
  "Delete backward by custom unit ARG times."
  (interactive "p")
  (dotimes (_ (or arg 1))
    (cursor-ops--operation
     #'bolp
     #'char-before
     (lambda () (char-before (1- (point))))
     (lambda () (delete-char -1)))))

;;;###autoload
(defun cursor-ops-forward-delete-unit (&optional arg)
  "Delete forward by custom unit ARG times."
  (interactive "p")
  (dotimes (_ (or arg 1))
    (cursor-ops--operation
     #'eolp
     #'char-after
     (lambda () (char-after (1+ (point))))
     (lambda () (delete-char 1)))))

;;;###autoload
(defun cursor-ops-delete-lines ()
  "Delete the current line(s)."
  (interactive)
  (if (use-region-p)
      (progn
        (delete-char -1)
        (unless (eolp)
          (set-mark (point))
          (end-of-line)
          (delete-char -1)))
    (let ((position (current-column)))
      (delete-line)
      (line-move-to-column position))))

;; Define a minor mode with its own keymap
(defvar cursor-ops-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [remap left-word] #'cursor-ops-backward-unit)
    (define-key map [remap right-word] #'cursor-ops-forward-unit)
    (define-key map [remap backward-kill-word] #'cursor-ops-backward-delete-unit)
    (define-key map [remap kill-word] #'cursor-ops-forward-delete-unit)
    (define-key map (kbd "C-S-<backspace>") #'cursor-ops-delete-lines)
    (define-key map (kbd "<home>") #'beginning-of-line-text)
    map)
  "Keymap for `cursor-ops-mode'.")

(define-minor-mode alnum-word-mode
  "Toggle the interpretation of words as alpha-numerical sequences."
  :lighter " FWM"
  (setq-local
   find-word-boundary-function-table
   (let ((tab (make-char-table nil)))
     (when alnum-word-mode
       (let ((fn (lambda (pos limit)
                   (save-excursion
                     (goto-char pos)
                     (funcall (if (< pos limit)
				  #'skip-chars-forward
				#'skip-chars-backward)
                              "[:alnum:]" limit)
                     (point))))
             (sym (make-symbol "fn")))
         (fset sym fn)
         (set-char-table-range tab t sym)))
     tab)))


;;;###autoload
(define-minor-mode cursor-ops-mode
  "Minor mode for custom cursor operations."
  :lighter " C-Ops"
  :keymap cursor-ops-mode-map)

;;;###autoload
(define-globalized-minor-mode global-cursor-ops-mode
  cursor-ops-mode
  (lambda () (cursor-ops-mode 1)))

(provide 'cursor-ops)

;;; cursor-ops.el ends here
