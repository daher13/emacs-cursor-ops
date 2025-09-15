(require 'cl-lib)

(cl-defun is-alnum (ch)
  (and ch (string-match "[[:alnum:]]" (string ch))))

(cl-defun is-special-char (ch)
  (and ch (string-match "[^[:alnum:][:space:]]" (string ch))))

(cl-defun is-space (ch)
  (and ch (string-match "[[:space:]]" (string ch))))

(cl-defun cursor-operation ()
  (if (check-line-limit)
      (operation)
    (if (and (or (is-special-char (get-char)) (is-space (get-char))) (is-alnum (get-char2))) ;; special char or space followed by alnum
	(progn
	  (operation)
	  (while (and (is-alnum (get-char)) (not (check-line-limit)))
	    (operation)))
      (if (and (or (is-alnum (get-char)) (is-space (get-char))) (is-special-char (get-char2))) ;; alnum or space followed by special char
	  (progn
	    (operation)
	    (while (and (is-special-char (get-char)) (not (check-line-limit)))
	      (operation)))
	(if (is-special-char (get-char)) ;; special char sequence
	    (while (and (is-special-char (get-char)) (not (check-line-limit)))
	      (operation))
	  (if (is-alnum (get-char)) ;; alnum sequence
	      (while (is-alnum (get-char))
		(operation))
	    (if (is-space (get-char)) ;; space sequence
		(while (is-space (get-char))
		  (operation)))))))))


(defun cursor-ops--backward-expr (&optional arg)
  "Backward move"
  (interactive "^p")
  (defun check-line-limit () (bolp))
  (defun get-char () (char-before))
  (defun get-char2 () (char-before (- (point) 1)))
  (defun operation () (backward-char))
  (cursor-operation))

(defun cursor-ops--forward-expr (&optional arg)
  "Forward move"
  (interactive "^p")
  (defun check-line-limit () (eolp))
  (defun get-char () (char-after))
  (defun get-char2 () (char-after (+ (point) 1)))
  (defun operation () (forward-char))
  (cursor-operation))

(defun cursor-ops--backward-delete-expr ()
  "Backward delete"
  (interactive)
  (defun check-line-limit () (bolp))
  (defun get-char () (char-before))
  (defun get-char2 () (char-before (- (point) 1)))
  (defun operation () (backward-delete-char 1))
  (cursor-operation))

(defun cursor-ops--forward-delete-expr ()
  "Forward delete"
  (interactive)
  (defun check-line-limit () (eolp))
  (defun get-char () (char-after))
  (defun get-char2 () (char-after (+ (point) 1)))
  (defun operation () (delete-char 1))
  (cursor-operation))

(defun cursor-ops--delete-lines ()
  (interactive)
  (if (use-region-p)
      (progn
        (backward-delete-char 1)
        (if (not (eolp))
            (progn
              (set-mark (point))
              (end-of-line)
              (backward-delete-char 1))))
    (progn
      (setq position (current-column))
      (delete-line)
      (line-move-to-column position))))


(global-set-key [remap left-word] 'cursor-ops--backward-expr)
(global-set-key [remap right-word] 'cursor-ops--forward-expr)
(global-set-key [remap backward-kill-word] 'cursor-ops--backward-delete-expr)
(global-set-key [remap kill-word] 'cursor-ops--forward-delete-expr)
(global-set-key (kbd "C-S-<backspace>") 'cursor-ops--delete-lines)
(global-set-key (kbd "<home>") 'beginning-of-line-text)

(provide 'cursor-ops)
