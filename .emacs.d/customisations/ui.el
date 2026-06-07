;;; -*- lexical-binding: t -*-

;; These customizations change the way emacs looks and disable/enable
;; some user interface elements. Some useful customizations are
;; commented out, and begin with the line "CUSTOMIZE". These are more
;; a matter of preference and may require some fiddling to match your
;; preferences

;; Turn off the menu bar at the top of each frame because it's distracting
(menu-bar-mode -1)

;; Show line numbers
;(global-linum-mode)

;(column-number-mode 1)


;; 1. Enable line numbers globally
(global-display-line-numbers-mode t)

;; Apply 24-bit colour faces in graphical frames and in truecolor terminals.
;; (display-color-cells) returns 16777216 when the terminal supports truecolor;
;; ensure COLORTERM=truecolor is set in the environment for this to work.
(when (or (display-graphic-p)
          (>= (display-color-cells) 16777216))
  (custom-set-faces
   '(line-number ((t (:foreground "#5c6370"
                      :background "#21252b"
                      :slant normal
                      :weight normal))))
   '(line-number-current-line ((t (:foreground "#abb2bf"
                                   :background "#2c313a"
                                   :weight bold))))))

;; 3. Better Demarcation & UX
(setq-default 
 ;; Ensure the gutter has at least 3 characters of space to avoid "shaking"
 display-line-numbers-width 2
 ;; Don't shrink the gutter if you scroll to a section with fewer lines
 display-line-numbers-grow-only t)



;; dark terminal colours
(setq frame-background-mode 'dark)


