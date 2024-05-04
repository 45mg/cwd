 ;;; cwd.el --- Emacs integration with `cwd' -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024
;;
;; Author:  45mg
;; Maintainer:  45mg
;; Created: May 04, 2024
;; Modified: May 04, 2024
;; Version: 0.0.1
;; Keywords: files local maint tools unix
;; Homepage: TODO
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  `cwd' is a tiny shell script that provides a single Common Working Directory
;;  for terminals, text editors, and the like. It should be simple to integrate
;;  into a number of applications (precmd hooks, shell aliases...).
;;
;;  cwd.el provides Emacs integration with `cwd'. When the global
;;  `cwd-minor-mode' is active, changes in the `default-directory' of the
;;  current buffer are sent to `cwd'. The cwd can also be manually set to
;;  `default-directory' via the command `cwd-set'.
;;
;; In addition, Lisp code can get the current cwd by calling `cwd-get'. The
;; function `cwd-find-file' is provided as an example application.
;;
;;; Code:

(defvar cwd-set-on-focus nil
  "Non-nil means set the cwd when an Emacs frame gains/loses focus.
Setting this will ensure that the cwd follows Emacs as closely as possible.")

(defvar cwd-program "cwdfilemanager"
  "The program to call in order to set/read the cwd.")
(defvar cwd-read-arg nil
  "Argument to pass `cwd-program' to read the cwd.")
(defvar cwd-write-arg "-w"
  "Argument to pass `cwd-program' to set the cwd.")

(defvar cwd--current-hook-transient nil
  "The current self-removing function on a hook.")

(defvar cwd--last-default-directory nil
  "Previous value of `default-directory'.")

;;;###autoload
(define-minor-mode cwd-minor-mode
  "Global minor mode to keep `default-directory' in sync with `cwd'."
  :global t
  (if cwd-minor-mode
      (progn
        (setq cwd--last-default-directory default-directory)
        (add-hook 'window-selection-change-functions #'cwd--set-if-necessary)
        (add-hook 'window-buffer-change-functions #'cwd--set-if-necessary)
        (when cwd-set-on-focus
          (add-function :after after-focus-change-function #'cwd--handle-focus-event)))
    (remove-hook 'window-selection-change-functions #'cwd--set-if-necessary)
    (remove-hook 'window-buffer-change-functions #'cwd--set-if-necessary)
    (remove-function after-focus-change-function #'cwd--handle-focus-event)))

;;;###autoload
(defun cwd-set (&rest _)
  "Set the cwd to `default-directory' by calling `cwd-program'."
  (interactive)
  (cwd--call-process cwd-write-arg default-directory))

;;;###autoload
(defun cwd-get ()
  "Get the cwd from `cwd-program'."
  (cwd--call-process cwd-read-arg))

;;;###autoload
(defun cwd-find-file (arg)
  "Find file starting from the cwd.
ARG will suppress this behavior and make it start from the current
`default-directory'."
  (interactive "P")
  (let ((default-directory (if arg default-directory (cwd-get))))
    (call-interactively #'find-file)))

(defun cwd--set-if-necessary (&rest _)
  "Set the cwd unless the minibuffer is currently selected."
  (unless (equal default-directory cwd--last-default-directory)
    (setq cwd--last-default-directory default-directory)
    (setq cwd--minibuffer-original-buffer nil)
    (cwd-set)))

(defun cwd--call-process (&optional &rest args)
  "Call `cwd-program' with ARGS; return stdout."
  (with-temp-buffer
    (let* ((res (apply #'call-process cwd-program nil t nil (remq nil args)))
           (out (string-trim (buffer-string))))
      (cond
       ((and (numberp res) (> res 0))
        (message "cwd(%d): %s" res out))
       ((stringp res)
        (message "cwd: terminated with signal %s" res))
       (t out)))))

(defmacro cwd--add-hook-transient (hook function &optional depth local)
  "Like `add-hook', but the function unhooks itself after it is called."
  (declare (indent 1))
  (let ((sym (make-symbol
              (concat (format "%s" function) "#cwd--transient"))))
    `(progn
       (defun ,sym ()
         (remove-hook ,hook ',sym ,local)
         (setq cwd--current-hook-transient nil)
         (funcall ,function))
       (add-hook ,hook ',sym ,depth ,local)
       (setq cwd--current-hook-transient ,hook))))

(defun cwd--handle-focus-event ()
  "Schedule `cwd-set' to run after the next interactive command.
This is done by adding it to `post-command-hook', and having it remove itself
from the hook after running."
  (unless cwd--current-hook-transient
    (cwd--add-hook-transient 'post-command-hook
      #'cwd-set)))

(provide 'cwd)
;;; cwd.el ends here
