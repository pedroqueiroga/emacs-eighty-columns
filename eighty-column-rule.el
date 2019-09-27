
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minor mode that keeps buffers with at most 80 columns        ;;
;;                                                              ;;
;; inspired by Jordon Biondo and his gist                       ;;
;; https://gist.github.com/jordonbiondo/aa6d68b680abdb1a5f70    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(make-variable-buffer-local
 (defvar 80-balanced t
   "If margins should be balanced or not."))

(defun 80-remove ()
  "Removes margins."
  (interactive)
  (set-window-margins (get-buffer-window) 0 0))

(defun 80-toggle-balanced ()
  "Choose between balanced margins or not."
  (interactive)
  (if 80-balanced
      (progn (setq 80-balanced nil)
	     (80-remove)
	     (80-editting-columns))
    (progn (setq 80-balanced t)
	   (80-remove)
	   (80-editting-columns-balanced))))

(defun 80-editting-columns ()
  "Set the right window margin so the editable space is only 80 columns."
  (interactive)
  ; not sure about this remove, but it makes things more smooth
  (80-remove)
  (let ((margins (window-margins)))
    (if (not (= (window-width) 80))
	(set-window-margins
	 (get-buffer-window) 0 (max (- (window-width) 80) 0)))))

(defun 80-editting-columns-balanced ()
  "Set both window margins so the editable space is only 80 columns."
  (interactive)
  (80-remove)
  (let ((margins (window-margins)))
    (if (not (= (window-width) 80))
	(let* ((change (max (- (window-width) 80) 0))
	       (left (/ change 2))
	       (right (- change left)))
	  (set-window-margins (get-buffer-window) left right)))))

(defun 80-recalculate (&optional frame)
  (if 80-balanced
      (80-editting-columns-balanced)
    (80-editting-columns)))

(defun split-window-right-ignore (&optional size)
  (if (car size) size (list (/ (window-total-width) 2))))

(advice-add 'split-window-right :filter-args
            'split-window-right-ignore)

;;;###autoload
(define-minor-mode eighty-column-rule-mode
  "Toggle Eighty-Column-Rule mode.
When Eighty-Column-Rule is enabled, it is only possible to use 80 columns
of a buffer."
  ;; Indicator for the mode line.
  :lighter " eighty"
  :keymap nil
  :global nil
  ;; When window changes its size, evaluate the margins needed again
  ;; make those hooks buffer-local!
  (if eighty-column-rule-mode
      (progn
	(80-recalculate)
	(add-hook 'window-size-change-functions '80-recalculate nil t)
	(add-hook 'window-configuration-change-hook '80-recalculate nil t))
    (80-remove)
    (remove-hook 'window-size-change-functions '80-recalculate t)
    (remove-hook 'window-configuration-change-hook '80-recalculate t)))

;;;###autoload
(add-hook 'prog-mode-hook 'eighty-column-rule-mode)

(provide 'eighty-column-rule)
;;; eighty-column-rule.el ends here
