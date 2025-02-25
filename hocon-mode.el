;;; hocon-mode.el --- major mode for hocon config file -*- lexical-binding: t -*-

;; Copyright (C) 2019 Xuqing Jia

;; Author: Xuqing Jia <amazingjxq@gmail.com>
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;;; Code:
(defvar hocon-mode-syntax-table nil "Syntax table for `hocon-mode'.")

(setq hocon-mode-syntax-table
      (let ((synTable (make-syntax-table)))
        (modify-syntax-entry ?# "<" synTable)
        (modify-syntax-entry ?\n ">" synTable)
        (modify-syntax-entry ?/ ". 12" synTable)
        synTable))

(defconst hocon-keyword-re
  (regexp-opt '("true" "false"))
  "Regexp matching any Hocon keyword.")

(defvar hocon-mode-font-lock-keywords nil "First element for `font-lock-defaults'.")

(setq hocon-mode-font-lock-keywords
      `((,hocon-keyword-re . font-lock-keyword-face)
        ("\\([^=:{}\n]*\\)=?:?\\s-*\n*{" . (1 font-lock-type-face))
        ("\\([^\n.]*\\)=" . (1 font-lock-variable-name-face))
        ("\\([^.\n=]+\\)\\." . (1 font-lock-type-face))
        ))

(defun calculate-hocon-indent ()
  "Set and return current indention.

RGX-OPEN-ITEM - match beggining of the item, array or object, ignore comments.
RGX-CLOSE-ITEM - match finishing of the item, array or object, ignore comments."
  (let ((rgx-open-item "^.*[{[]\\s-*\\([//#].+\\)?$")
        (rgx-close-item "^.*[]}]\\s-*?,?\\s-*?\\([//#].+\\)?$"))
    (beginning-of-line)
    (if (bobp)
        (indent-line-to 0)
      (let ((new-indent nil)
            (not-indented t))
        (if (looking-at rgx-close-item)
            (save-excursion
              (while not-indented
                (forward-line -1)
                (cond
                 ((looking-at rgx-close-item)
                  (progn
                    (setq new-indent (- (current-indentation) 2))
                    (setq not-indented nil)))
                 ((looking-at rgx-open-item)
                  (progn
                    (setq new-indent (current-indentation))
                    (setq not-indented nil)))
                 ((bobp)
                  (progn (setq not-indented nil))))))
          (save-excursion
            (while not-indented
              (forward-line -1)
              (cond ((looking-at rgx-close-item)
                     (progn
                       (setq new-indent (current-indentation))
                       (setq not-indented nil)))
                    ((looking-at rgx-open-item)
                     (progn
                       (setq new-indent (+ (current-indentation) 2))
                       (setq not-indented nil)))
                    ((bobp) (setq not-indented nil))))))
        new-indent))))

(defun hocon-indent-line ()
  "Indent line for hocon."
  (interactive)
  (let ((pos (- (point-max) (point)))
        (new-indent (calculate-hocon-indent)))
    (if new-indent
        (progn
          (indent-line-to new-indent)))
    (goto-char (- (point-max) pos))))

;;;###autoload
(define-derived-mode hocon-mode prog-mode "HOCON"
  "Major mode for editing HOCON(Human-Optimized Config Object Notation)…"
  (set (make-local-variable 'font-lock-defaults) '(hocon-mode-font-lock-keywords))
  (setq-local indent-line-function 'hocon-indent-line))

(provide 'hocon-mode)
;;; hocon-mode.el ends here
