
;;; -*- lexical-binding: t -*-

;; Customisations
(add-to-list 'load-path "~/.emacs.d/customisations")

(load "editing.el")
(load "ui.el")
(load "misc.el")

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
