;;; rainbow-fart.el --- Encourage when you programming -*- lexical-binding: t; -*-

;;; Time-stamp: <2020-06-18 23:35:28 stardiviner>

;; Authors: stardiviner <numbchild@gmail.com>
;; Package-Requires: ((emacs "25.1"))
;; Package-Version: 0.1
;; Keywords: tools
;; homepage: https://github.com/stardiviner/emacs-rainbow-fart

;; rainbow-fart is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; rainbow-fart is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:



;;; Code:

(defgroup rainbow-fart nil
  "rainbow-fart-mode customize group."
  :prefix "rainbow-fart-"
  :group 'rainbow-fart)

(defcustom rainbow-fart-voice-alist
  '(("defun" . ("function.mp3" "function_01.mp3" "function_02.mp3" "function_03.mp3"))
    ("defn" . ("function.mp3" "function_01.mp3" "function_02.mp3" "function_03.mp3"))
    ("fn" . ("function.mp3" "function_01.mp3" "function_02.mp3" "function_03.mp3"))
    ("lambda" . ("function.mp3" "function_01.mp3" "function_02.mp3" "function_03.mp3"))
    ("function" . ("function.mp3" "function_01.mp3" "function_02.mp3" "function_03.mp3"))
    ("->" . ("arrow_function_01.mp3"))
    ("->>" . ("arrow_function_01.mp3"))
    ("if" . ("if_01.mp3" "if_02.mp3" "if_03.mp3"))
    ("while" . ("if_01.mp3" "if_02.mp3" "if_03.mp3"))
    ("when" . ("if_01.mp3" "if_02.mp3" "if_03.mp3"))
    ("until" . ("if_01.mp3" "if_02.mp3" "if_03.mp3"))
    ("for" . ("for_01.mp3" "for_02.mp3" "for_03.mp3"))
    ("loop" . ("for_01.mp3" "for_02.mp3" "for_03.mp3"))
    ("await" . ("await_01.mp3" "await_02.mp3" "await_03.mp3"))
    ("promise" . ("await_01.mp3" "await_02.mp3" "await_03.mp3"))
    ("catch" . ("catch_01.mp3" "catch_02.mp3" "catch_03.mp3"))
    ("import" . ("import_01.mp3" "import_02.mp3"))
    (":import" . ("import_01.mp3" "import_02.mp3"))
    (":require" . ("import_01.mp3" "import_02.mp3"))
    ("require" . ("import_01.mp3" "import_02.mp3"))
    ("load" . ("import_01.mp3" "import_02.mp3"))
    ("load-file" . ("import_01.mp3" "import_02.mp3"))
    ("v-html" . ("v_html_01.mp3"))
    ("fuck" . ("fuck_pm_01.mp3" "fuck_pm_02.mp3"))
    ("shit" . ("fuck_pm_01.mp3" "fuck_pm_02.mp3"))
    ("damn" . ("fuck_pm_01.mp3" "fuck_pm_02.mp3"))
    ;; TODO time voices
    ;; TODO `flycheck' support
    ("info" . ())
    ("warning" . ())
    ("error" . ()))
  "An alist of pairs of programming language keywords and voice filenames."
  :type 'alist
  :safe #'listp
  :group 'rainbow-fart)

(defcustom rainbow-fart-voice-directory
  (concat (file-name-directory (or load-file-name buffer-file-name))
          "voices/voice-chinese-default/")
  "The directory of voices."
  :type 'string
  :safe #'stringp
  :group 'rainbow-fart)

(defvar rainbow-fart--playing nil
  "The status of rainbow-fart playing.")

(defun rainbow-fart--play (keyword)
  "A private function to play voice for matched KEYWORD."
  (unless rainbow-fart--playing
    (when-let ((files (cdr (assoc keyword rainbow-fart-voice-alist))))
      (let ((file (nth (random (length files)) files)))
        (setq rainbow-fart--playing t)
        (let ((file-path (when (file-exists-p (concat rainbow-fart-voice-directory file))
                           (concat rainbow-fart-voice-directory file)))
              (command (cond
                        ;; ((executable-find "aplay") "aplay")
                        ((executable-find "mpg123") "mpg123")
                        ((executable-find "mplayer") "mplayer")
                        ((executable-find "mpv") "mpv"))))
          (make-process :name "rainbow-fart"
                        :command `(,command ,file-path)
                        :buffer "*rainbow-fart*"
                        :sentinel (lambda (proc event) (setq rainbow-fart--playing nil))))))))

(defun rainbow-fart--post-self-insert ()
  "A hook function on `post-self-insert-hook' to play audio."
  (let* ((prefix (thing-at-point 'symbol)))
    (rainbow-fart--play prefix)))

(defun rainbow-fart--linter-display-error (err)
  "Play voice for `flycheck-error' ERR."
  (let ((level (flycheck-error-level err)))
    (rainbow-fart--play level)))

(defun rainbow-fart--linter-display-errors (errors)
  "A function to report ERRORS used as replacement of linter like `flycheck' and `flymake'."
  (rainbow-fart--play
   (mapc #'rainbow-fart--linter-display-error
         (seq-uniq
          (seq-mapcat #'flycheck-related-errors errors)))))

(define-minor-mode rainbow-fart-mode
  "A minor mode add an encourager when you programming."
  :init-value nil
  :lighter " rainbow-fart "
  :group 'rainbow-fart
  (if rainbow-fart-mode
      (progn
        (add-hook 'post-self-insert-hook #'rainbow-fart--post-self-insert t t)
        (advice-add (buffer-local-value 'flycheck-display-errors-function (current-buffer))
                    :before 'rainbow-fart--linter-display-errors))
    (remove-hook 'post-self-insert-hook #'rainbow-fart--post-self-insert t)
    (advice-remove (buffer-local-value 'flycheck-display-errors-function (current-buffer))
                   'rainbow-fart--linter-display-errors)))



(provide 'rainbow-fart)

;;; rainbow-fart.el ends here
